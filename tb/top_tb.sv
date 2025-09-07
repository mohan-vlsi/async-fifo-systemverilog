//tbcode
----


`timescale 1ns/1ps

// ------------------------
// Interface
// ------------------------
interface fifo_if #(parameter DATA_WIDTH=8)
(
  input  logic wr_clk,
  input  logic rd_clk,
  input  logic rst
);
  logic                  wr_en;
  logic [DATA_WIDTH-1:0] wdata;
  logic                  wr_error;

  logic                  rd_en;
  logic [DATA_WIDTH-1:0] rdata;
  logic                  rd_error;

  logic                  full;
  logic                  empty;
endinterface

// ------------------------
// Transactions
// ------------------------
class wr_tx;
  rand bit                  wr_en;
  rand bit [7:0]            wdata;
       bit                  full;
       bit                  wr_error;
  function void print();
    $display("[%0t][WR_TX] en=%0b data=%0d full=%0b werr=%0b",
             $time, wr_en, wdata, full, wr_error);
  endfunction
endclass

class rd_tx;
  rand bit                  rd_en;
       bit [7:0]            rdata;
       bit                  empty;
       bit                  rd_error;
  function void print();
    $display("[%0t][RD_TX] en=%0b data=%0d empty=%0b rerr=%0b",
             $time, rd_en, rdata, empty, rd_error);
  endfunction
endclass

// ------------------------
// Common shared stuff
// ------------------------
class fifo_common;
  static string  testname = "random";
  static int     wr_count = 40;
  static int     rd_count = 40;

  // gen -> bfm
  static mailbox gen2wr = new();
  static mailbox gen2rd = new();

  // mon -> sbd (only accepted ops)
  static mailbox wr2sbd = new(); // send only when wr_en && !full
  static mailbox rd2sbd = new(); // send only when rd_en && !empty

  static int match;
  static int mismatches;
endclass

// ------------------------
// Generators
// ------------------------
class wr_gen;
  wr_tx tx;
  task run();
    case (fifo_common::testname)
      "test_wr","full","overflow","random","smoke": write_many(fifo_common::wr_count);
      default: write_many(fifo_common::wr_count);
    endcase
  endtask

  task write_many(int n);
    repeat (n) begin
      tx = new();
      assert(tx.randomize() with { wr_en == 1; }); // always attempt
      fifo_common::gen2wr.put(tx);
      tx.print();
    end
  endtask
endclass

class rd_gen;
  rd_tx tx;
  task run();
    case (fifo_common::testname)
      "test_rd","empty","underflow","random","smoke": read_many(fifo_common::rd_count);
      default: read_many(fifo_common::rd_count);
    endcase
  endtask

  task read_many(int n);
    repeat (n) begin
      tx = new();
      assert(tx.randomize() with { rd_en == 1; });
      fifo_common::gen2rd.put(tx);
      tx.print();
    end
  endtask
endclass

// ------------------------
// BFMs (Drivers)
// ------------------------
class wr_bfm;
  virtual fifo_if vif;
  task run();
    vif = top_tb.pif;
    forever begin
      wr_tx tx; fifo_common::gen2wr.get(tx);
      @(posedge vif.wr_clk);
      vif.wr_en <= tx.wr_en;
      vif.wdata <= tx.wdata;
      @(posedge vif.wr_clk);
      // capture status back for logs only
      tx.full     = vif.full;
      tx.wr_error = vif.wr_error;
      // deassert
      vif.wr_en   <= 0;
      vif.wdata   <= '0;
    end
  endtask
endclass

class rd_bfm;
  virtual fifo_if vif;
  task run();
    vif = top_tb.pif;
    forever begin
      rd_tx tx; fifo_common::gen2rd.get(tx);
      @(posedge vif.rd_clk);
      vif.rd_en <= tx.rd_en;
      @(posedge vif.rd_clk);
      tx.rdata   = vif.rdata;
      tx.empty   = vif.empty;
      tx.rd_error= vif.rd_error;
      vif.rd_en  <= 0;
    end
  endtask
endclass

// ------------------------
// Monitors (accepted ops only)
// ------------------------
class wr_mon;
  virtual fifo_if vif;
  task run();
    vif = top_tb.pif;
    forever begin
      @(posedge vif.wr_clk);
      if (vif.wr_en && !vif.full) begin
        wr_tx tx = new();
        tx.wr_en    = vif.wr_en;
        tx.wdata    = vif.wdata;
        tx.full     = vif.full;
        tx.wr_error = vif.wr_error;
        fifo_common::wr2sbd.put(tx); // accepted write only
      end
    end
  endtask
endclass

class rd_mon;
  virtual fifo_if vif;
  task run();
    vif = top_tb.pif;
    forever begin
      @(posedge vif.rd_clk);
      if (vif.rd_en && !vif.empty) begin
        rd_tx tx = new();
        tx.rd_en    = vif.rd_en;
        tx.rdata    = vif.rdata;
        tx.empty    = vif.empty;
        tx.rd_error = vif.rd_error;
        fifo_common::rd2sbd.put(tx); // accepted read only
      end
    end
  endtask
endclass

// ------------------------
// Agents
// ------------------------
class wr_agent;
  wr_gen gen; wr_bfm bfm; wr_mon mon;
  task run(); gen=new(); bfm=new(); mon=new();
    fork gen.run(); bfm.run(); mon.run(); join_none;
  endtask
endclass

class rd_agent;
  rd_gen gen; rd_bfm bfm; rd_mon mon;
  task run(); gen=new(); bfm=new(); mon=new();
    fork gen.run(); bfm.run(); mon.run(); join_none;
  endtask
endclass

// ------------------------
// Scoreboard (queue model)
// ------------------------
class fifo_sbd;
  bit [7:0] model_q[$];

  task run();
    fork
      // writer stream: push expected
      forever begin
        wr_tx w; fifo_common::wr2sbd.get(w);
        model_q.push_back(w.wdata);
      end

      // reader stream: pop & compare
      forever begin
        rd_tx r; fifo_common::rd2sbd.get(r);
        if (model_q.size() == 0) begin
          $display("[%0t][SBD] ERROR: Read with empty model!", $time);
          fifo_common::mismatches++;
        end else begin
          bit [7:0] exp = model_q.pop_front();
          if (exp === r.rdata) begin
            fifo_common::match++;
            $display("[%0t][SBD] MATCH exp=%0d got=%0d", $time, exp, r.rdata);
          end else begin
            fifo_common::mismatches++;
            $display("[%0t][SBD] MISMATCH exp=%0d got=%0d", $time, exp, r.rdata);
          end
        end
      end
    join_none
  endtask
endclass

// ------------------------
// Environment
// ------------------------
class fifo_env;
  wr_agent wra; rd_agent rda; fifo_sbd sbd;
  task run();
    wra=new(); rda=new(); sbd=new();
    fork wra.run(); rda.run(); sbd.run(); join_none;
  endtask
endclass

// ------------------------
// TOP TB
// ------------------------
module top_tb;

  // Clocks & reset
  logic wr_clk=0, rd_clk=0, rst=1;

  // Interface
  fifo_if #(8) pif(.wr_clk(wr_clk), .rd_clk(rd_clk), .rst(rst));

  // DUT
  fifo_async #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) dut (
    .wr_clk_i (wr_clk),
    .rd_clk_i (rd_clk),
    .rst_i    (rst),

    .wr_en_i  (pif.wr_en),
    .wdata_i  (pif.wdata),
    .full_o   (pif.full),
    .wr_error_o(pif.wr_error),

    .rd_en_i  (pif.rd_en),
    .rdata_o  (pif.rdata),
    .empty_o  (pif.empty),
    .rd_error_o(pif.rd_error)
  );

  // Env
  fifo_env env = new();

  // Clocks: async rates
  always #5  wr_clk = ~wr_clk;  // 100 MHz
  always #7  rd_clk = ~rd_clk;  // ~71.4 MHz

  // Reset
  initial begin
    rst = 1;
    repeat (4) @(posedge wr_clk);
    rst = 0;
  end

  // Configure via +testname=xxx +wr_count=N +rd_count=M (optional)
  initial begin
    string t;
    if ($value$plusargs("testname=%s", t)) begin
      fifo_common::testname = t;
    end
  end
    initial begin
    integer wcnt, rcnt;
    if ($value$plusargs("wr_count=%d", wcnt)) fifo_common::wr_count = wcnt;
    if ($value$plusargs("rd_count=%d", rcnt)) fifo_common::rd_count = rcnt;
    $display("[CFG] testname=%s wr_count=%0d rd_count=%0d",
             fifo_common::testname, fifo_common::wr_count, fifo_common::rd_count);
  end
  // Start env and stop sim
  initial begin
    env.run();

    // let it run; tweak as needed
    #20000;
    $display("====================================================");
    $display("RESULT: matches=%0d mismatches=%0d",
             fifo_common::match, fifo_common::mismatches);
    $display("====================================================");
    $finish;
  end

  // Waves for VCS (VCD)
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, top_tb);
  end

endmodule
