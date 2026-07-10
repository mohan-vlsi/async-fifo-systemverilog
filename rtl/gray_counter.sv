module gray_counter #(
    parameter PTR_WIDTH = 5
)(
    input  logic [PTR_WIDTH-1:0] bin,
    output logic [PTR_WIDTH-1:0] gray
);

    always_comb begin
        gray = (bin >> 1) ^ bin;
    end

endmodule
