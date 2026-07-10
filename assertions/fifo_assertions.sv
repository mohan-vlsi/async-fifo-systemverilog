module fifo_assertions
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

    //---------------------------------------------------------
    // 1. Write should not occur when FIFO is Full
    //---------------------------------------------------------

    property no_write_when_full;

        @(posedge wclk)
        disable iff(!wrst_n)
        wfull |-> !winc;

    endproperty

    assert property(no_write_when_full)
        else
        $error("ASSERTION FAILED : Write attempted when FIFO is FULL");



    //---------------------------------------------------------
    // 2. Read should not occur when FIFO is Empty
    //---------------------------------------------------------

    property no_read_when_empty;

        @(posedge rclk)
        disable iff(!rrst_n)
        rempty |-> !rinc;

    endproperty

    assert property(no_read_when_empty)
        else
        $error("ASSERTION FAILED : Read attempted when FIFO is EMPTY");



    //---------------------------------------------------------
    // 3. FIFO should be Empty after Reset
    //---------------------------------------------------------

    property empty_after_reset;

        @(posedge rclk)
        !rrst_n |=> rempty;

    endproperty

    assert property(empty_after_reset)
        else
        $error("ASSERTION FAILED : FIFO not empty after reset");



    //---------------------------------------------------------
    // 4. FIFO should not be Full after Reset
    //---------------------------------------------------------

    property not_full_after_reset;

        @(posedge wclk)
        !wrst_n |=> !wfull;

    endproperty

    assert property(not_full_after_reset)
        else
        $error("ASSERTION FAILED : FIFO full immediately after reset");

endmodule
