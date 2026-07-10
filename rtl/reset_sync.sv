module reset_sync (
    input  logic clk,
    input  logic arst_n,   // Asynchronous active-low reset
    output logic srst_n    // Synchronized active-low reset
);

    logic sync_ff1, sync_ff2;

    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end
        else begin
            sync_ff1 <= 1'b1;
            sync_ff2 <= sync_ff1;
        end
    end

    assign srst_n = sync_ff2;

endmodule
