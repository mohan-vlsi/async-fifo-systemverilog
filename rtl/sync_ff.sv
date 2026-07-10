module sync_ff #(
    parameter WIDTH = 5
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);

    logic [WIDTH-1:0] sync1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync1 <= '0;
            dout  <= '0;
        end
        else begin
            sync1 <= din;
            dout  <= sync1;
        end
    end

endmodule
