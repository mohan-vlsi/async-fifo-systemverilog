//design code 
---

// Parameterized Asynchronous FIFO (Gray pointers + 2-flop synchronizers)
// Depth = 2**ADDR_WIDTH

`timescale 1ns/1ps

module fifo_async #(
  parameter int DATA_WIDTH = 8,
  parameter int ADDR_WIDTH = 4  // depth=16 by default
)(
  input  logic                    wr_clk_i,
  input  logic                    rd_clk_i,
  input  logic                    rst_i,        // async, active-high

  // write side
  input  logic                    wr_en_i,
  input  logic [DATA_WIDTH-1:0]   wdata_i,
  output logic                    full_o,
  output logic                    wr_error_o,   // pulse when write attempted while full

  // read side
  input  logic                    rd_en_i,
  output logic [DATA_WIDTH-1:0]   rdata_o,
  output logic                    empty_o,
  output logic                    rd_error_o    // pulse when read attempted while empty
);

  localparam int DEPTH = 1 << ADDR_WIDTH;

  // Memory
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Binary pointers include 1 extra MSB for wrap (ADDR_WIDTH+1 bits)
  logic [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_bin_n;
  logic [ADDR_WIDTH:0] rd_ptr_bin, rd_ptr_bin_n;

  // Gray-coded pointers
  logic [ADDR_WIDTH:0] wr_ptr_gray, wr_ptr_gray_n;
  logic [ADDR_WIDTH:0] rd_ptr_gray, rd_ptr_gray_n;

  // Crossed-domain synchronized Gray pointers (2-flop sync)
  logic [ADDR_WIDTH:0] rd_ptr_gray_w1, rd_ptr_gray_w2; // into wr domain
  logic [ADDR_WIDTH:0] wr_ptr_gray_r1, wr_ptr_gray_r2; // into rd domain

  // ---------------------------
  // Helpers
  // ---------------------------
  function automatic [ADDR_WIDTH:0] bin2gray (input [ADDR_WIDTH:0] b);
    bin2gray = (b >> 1) ^ b;
  endfunction

  // ---------------------------
  // Write domain
  // ---------------------------
  // Next-state computation
  wire do_write = wr_en_i && !full_o;
  assign wr_ptr_bin_n  = wr_ptr_bin + (do_write ? 1 : 0);
  assign wr_ptr_gray_n = bin2gray(wr_ptr_bin_n);

  // Register write-side stuff
  always_ff @(posedge wr_clk_i or posedge rst_i) begin
    if (rst_i) begin
      wr_ptr_bin  <= '0;
      wr_ptr_gray <= '0;
      wr_error_o  <= 1'b0;
      full_o      <= 1'b0;
    end else begin
      // Write to memory when allowed
      if (do_write) begin
        mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wdata_i;
      end
      wr_ptr_bin  <= wr_ptr_bin_n;
      wr_ptr_gray <= wr_ptr_gray_n;

      // Error pulse on illegal write attempt
      wr_error_o  <= (wr_en_i && full_o);

      // Update FULL flag using "invert MSBs" test on next write pointer
      // FULL when next wr Gray equals rd Gray (synced) with MSBs inverted
      full_o <= (wr_ptr_gray_n ==
                 {~rd_ptr_gray_w2[ADDR_WIDTH:ADDR_WIDTH-1],
                   rd_ptr_gray_w2[ADDR_WIDTH-2:0]});
    end
  end

  // Synchronize read Gray pointer into write domain (2 flop)
  always_ff @(posedge wr_clk_i or posedge rst_i) begin
    if (rst_i) begin
      rd_ptr_gray_w1 <= '0;
      rd_ptr_gray_w2 <= '0;
    end else begin
      rd_ptr_gray_w1 <= rd_ptr_gray;
      rd_ptr_gray_w2 <= rd_ptr_gray_w1;
    end
  end

  // ---------------------------
  // Read domain
  // ---------------------------
  // Next-state computation
  wire do_read = rd_en_i && !empty_o;
  assign rd_ptr_bin_n  = rd_ptr_bin + (do_read ? 1 : 0);
  assign rd_ptr_gray_n = bin2gray(rd_ptr_bin_n);

  // Register read-side stuff
  always_ff @(posedge rd_clk_i or posedge rst_i) begin
    if (rst_i) begin
      rd_ptr_bin  <= '0;
      rd_ptr_gray <= '0;
      rdata_o     <= '0;
      rd_error_o  <= 1'b0;
      empty_o     <= 1'b1; // FIFO is empty after reset
    end else begin
      // Registered read data on successful read
      if (do_read) begin
        rdata_o <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
      end
      rd_ptr_bin  <= rd_ptr_bin_n;
      rd_ptr_gray <= rd_ptr_gray_n;

      // Error pulse on illegal read attempt
      rd_error_o  <= (rd_en_i && empty_o);

      // Update EMPTY flag: empty when next rd Gray equals synced wr Gray
      empty_o <= (rd_ptr_gray_n == wr_ptr_gray_r2);
    end
  end

  // Synchronize write Gray pointer into read domain (2 flop)
  always_ff @(posedge rd_clk_i or posedge rst_i) begin
    if (rst_i) begin
      wr_ptr_gray_r1 <= '0;
      wr_ptr_gray_r2 <= '0;
    end else begin
      wr_ptr_gray_r1 <= wr_ptr_gray;
      wr_ptr_gray_r2 <= wr_ptr_gray_r1;
    end
  end

endmodule


