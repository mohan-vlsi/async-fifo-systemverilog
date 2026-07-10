`timescale 1ns/1ps

module top_tb;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    //-----------------------------------------
    // Interface
    //-----------------------------------------

    fifo_if #(DATA_WIDTH) vif();

    //-----------------------------------------
    // DUT
    //-----------------------------------------

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (

        .wclk(vif.wclk),
        .wrst_n(vif.wrst_n),
        .winc(vif.winc),
        .wdata(vif.wdata),

        .rclk(vif.rclk),
        .rrst_n(vif.rrst_n),
        .rinc(vif.rinc),

        .rdata(vif.rdata),
        .wfull(vif.wfull),
        .rempty(vif.rempty)

    );
fifo_assertions assertions_inst
(
    .wclk   (vif.wclk),
    .rclk   (vif.rclk),

    .wrst_n (vif.wrst_n),
    .rrst_n (vif.rrst_n),

    .winc   (vif.winc),
    .rinc   (vif.rinc),

    .wfull  (vif.wfull),
    .rempty (vif.rempty)
);
    //-----------------------------------------
    // Test
    //-----------------------------------------

    test t;

    //-----------------------------------------
    // Write Clock
    //-----------------------------------------

    initial begin
        vif.wclk = 0;
        forever #5 vif.wclk = ~vif.wclk;
    end

    //-----------------------------------------
    // Read Clock
    //-----------------------------------------

    initial begin
        vif.rclk = 0;
        forever #7 vif.rclk = ~vif.rclk;
    end

    //-----------------------------------------
    // Reset
    //-----------------------------------------

    initial begin

        vif.wrst_n = 0;
        vif.rrst_n = 0;

        vif.winc = 0;
        vif.rinc = 0;
        vif.wdata = 0;

        #20;

        vif.wrst_n = 1;
        vif.rrst_n = 1;

    end

    //-----------------------------------------
    // Test Start
    //-----------------------------------------

    initial begin

        t = new(vif);

        wait(vif.wrst_n && vif.rrst_n);

        t.run();

    end

    //-----------------------------------------
    // Simulation End
    //-----------------------------------------

    initial begin

        #5000;

        $display("--------------------------------");
        $display(" Simulation Completed ");
        $display("--------------------------------");

        $finish;

    end

endmodule
