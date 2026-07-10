module wptr_full #(
    parameter ADDR_WIDTH = 4
)(
    input  logic                     wclk,
    input  logic                     wrst_n,
    input  logic                     winc,
    input  logic [ADDR_WIDTH:0]      wq2_rptr,

    output logic                     wfull,
    output logic [ADDR_WIDTH:0]      wptr,
    output logic [ADDR_WIDTH:0]      wbin
);

    logic [ADDR_WIDTH:0] wbinnext;
    logic [ADDR_WIDTH:0] wgraynext;
    logic                wfull_val;

    //-----------------------------
    // Binary Pointer Increment
    //-----------------------------
    assign wbinnext = wbin + (winc & ~wfull);

    //-----------------------------
    // Binary -> Gray
    //-----------------------------
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;

    //-----------------------------
    // Full Detection
    //-----------------------------
    assign wfull_val =
            (wgraynext ==
            {~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1],
              wq2_rptr[ADDR_WIDTH-2:0]});

    //-----------------------------
    // Sequential Logic
    //-----------------------------
    always_ff @(posedge wclk or negedge wrst_n)
    begin
        if(!wrst_n)
        begin
            wbin  <= '0;
            wptr  <= '0;
            wfull <= 1'b0;
        end
        else
        begin
            wbin  <= wbinnext;
            wptr  <= wgraynext;
            wfull <= wfull_val;
        end
    end

endmodule
