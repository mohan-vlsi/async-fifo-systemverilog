module rptr_empty #(
    parameter ADDR_WIDTH = 4
)(
    input  logic                     rclk,
    input  logic                     rrst_n,
    input  logic                     rinc,
    input  logic [ADDR_WIDTH:0]      rq2_wptr,

    output logic                     rempty,
    output logic [ADDR_WIDTH:0]      rptr,
    output logic [ADDR_WIDTH:0]      rbin
);

    logic [ADDR_WIDTH:0] rbinnext;
    logic [ADDR_WIDTH:0] rgraynext;
    logic                rempty_val;

    //-----------------------------
    // Binary Pointer Increment
    //-----------------------------
    assign rbinnext = rbin + (rinc & ~rempty);

    //-----------------------------
    // Binary -> Gray
    //-----------------------------
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;

    //-----------------------------
    // Empty Detection
    //-----------------------------
    assign rempty_val = (rgraynext == rq2_wptr);

    //-----------------------------
    // Sequential Logic
    //-----------------------------
    always_ff @(posedge rclk or negedge rrst_n)
    begin
        if(!rrst_n)
        begin
            rbin   <= '0;
            rptr   <= '0;
            rempty <= 1'b1;
        end
        else
        begin
            rbin   <= rbinnext;
            rptr   <= rgraynext;
            rempty <= rempty_val;
        end
    end

endmodule
