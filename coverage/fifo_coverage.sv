module fifo_coverage
(
    input logic wclk,
    input logic rclk,
    input logic wrst_n,
    input logic rrst_n,

    input logic winc,
    input logic rinc,

    input logic wfull,
    input logic rempty
);

    //-----------------------------------------
    // Write Domain Coverage
    //-----------------------------------------

    covergroup write_cg @(posedge wclk);

        option.per_instance = 1;

        WRITE_ENABLE : coverpoint winc;

        FIFO_FULL : coverpoint wfull;

        WRITE_X_FULL : cross WRITE_ENABLE, FIFO_FULL;

    endgroup

    //-----------------------------------------
    // Read Domain Coverage
    //-----------------------------------------

    covergroup read_cg @(posedge rclk);

        option.per_instance = 1;

        READ_ENABLE : coverpoint rinc;

        FIFO_EMPTY : coverpoint rempty;

        READ_X_EMPTY : cross READ_ENABLE, FIFO_EMPTY;

    endgroup

    //-----------------------------------------
    // Constructor
    //-----------------------------------------

    write_cg wr_cov = new();

    read_cg rd_cov = new();

endmodule
