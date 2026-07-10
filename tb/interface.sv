interface fifo_if #(parameter DATA_WIDTH = 8);

    //-----------------------------------------
    // Clock Signals
    //-----------------------------------------
    logic wclk;
    logic rclk;

    //-----------------------------------------
    // Reset Signals
    //-----------------------------------------
    logic wrst_n;
    logic rrst_n;

    //-----------------------------------------
    // Write Interface
    //-----------------------------------------
    logic                     winc;
    logic [DATA_WIDTH-1:0]    wdata;
    logic                     wfull;

    //-----------------------------------------
    // Read Interface
    //-----------------------------------------
    logic                     rinc;
    logic [DATA_WIDTH-1:0]    rdata;
    logic                     rempty;

endinterface
