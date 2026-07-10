module bin2gray #(
    parameter WIDTH = 5
)(
    input  logic [WIDTH-1:0] bin,
    output logic [WIDTH-1:0] gray
);

    assign gray = (bin >> 1) ^ bin;

endmodule
