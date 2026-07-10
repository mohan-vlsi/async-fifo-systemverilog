module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  logic                     wclk,
    input  logic                     wrst_n,
    input  logic                     winc,
    input  logic [DATA_WIDTH-1:0]    wdata,

    input  logic                     rclk,
    input  logic                     rrst_n,
    input  logic                     rinc,

    output logic [DATA_WIDTH-1:0]    rdata,
    output logic                     wfull,
    output logic                     rempty
);

    //----------------------------------------------------
    // Internal Signals
    //----------------------------------------------------

    // Gray-coded pointers
    logic [ADDR_WIDTH:0] wptr, rptr;

    // Binary pointers
    logic [ADDR_WIDTH:0] wbin, rbin;

    // Synchronized Gray pointers
    logic [ADDR_WIDTH:0] wq2_rptr;
    logic [ADDR_WIDTH:0] rq2_wptr;

    // Synchronized resets
    logic wsrst_n;
    logic rsrst_n;

    //----------------------------------------------------
    // Reset Synchronizers
    //----------------------------------------------------

    reset_sync w_reset_sync (
        .clk    (wclk),
        .arst_n (wrst_n),
        .srst_n (wsrst_n)
    );

    reset_sync r_reset_sync (
        .clk    (rclk),
        .arst_n (rrst_n),
        .srst_n (rsrst_n)
    );

    //----------------------------------------------------
    // Pointer Synchronizers
    //----------------------------------------------------

    sync_ff #(
        .WIDTH(ADDR_WIDTH+1)
    ) sync_r2w (
        .clk   (wclk),
        .rst_n (wsrst_n),
        .din   (rptr),
        .dout  (wq2_rptr)
    );

    sync_ff #(
        .WIDTH(ADDR_WIDTH+1)
    ) sync_w2r (
        .clk   (rclk),
        .rst_n (rsrst_n),
        .din   (wptr),
        .dout  (rq2_wptr)
    );

    //----------------------------------------------------
    // Write Pointer and Full Logic
    //----------------------------------------------------

    wptr_full #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) write_ptr (
        .wclk     (wclk),
        .wrst_n   (wsrst_n),
        .winc     (winc),
        .wq2_rptr (wq2_rptr),
        .wfull    (wfull),
        .wptr     (wptr),
        .wbin     (wbin)
    );

    //----------------------------------------------------
    // Read Pointer and Empty Logic
    //----------------------------------------------------

    rptr_empty #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) read_ptr (
        .rclk     (rclk),
        .rrst_n   (rsrst_n),
        .rinc     (rinc),
        .rq2_wptr (rq2_wptr),
        .rempty   (rempty),
        .rptr     (rptr),
        .rbin     (rbin)
    );

    //----------------------------------------------------
    // FIFO Memory
    //----------------------------------------------------

    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mem (
        .wclk  (wclk),
        .w_en  (winc && !wfull),
        .waddr (wbin[ADDR_WIDTH-1:0]),
        .wdata (wdata),

        .rclk  (rclk),
        .r_en  (rinc && !rempty),
        .raddr (rbin[ADDR_WIDTH-1:0]),
        .rdata (rdata)
    );

endmodule
