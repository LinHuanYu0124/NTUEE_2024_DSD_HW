module ALU(
    aluop,
    in_a,
    in_b,
    out
);

input [3:0] aluop;
input [31:0] in_a;
input [31:0] in_b;
output reg [31:0] out;


localparam ADD = 4'b0000;
localparam SUB = 4'b0001;
localparam SLL = 4'b0010;
localparam SLT = 4'b0100;
localparam XOR = 4'b1000;
localparam SRL = 4'b1010;
localparam SRA = 4'b1011;
localparam OR  = 4'b1100;
localparam AND = 4'b1110;


always@(*) begin

    case(aluop)
    ADD:     out = $signed(in_a) + $signed(in_b);
    SUB:     out = $signed(in_a) - $signed(in_b);
    SLL:     out = in_a << in_b[4:0];
    SLT:     out = $signed(in_a) < $signed(in_b) ? 1 : 0;
    XOR:     out = in_a ^ in_b;
    SRL:     out = in_a >> in_b[4:0];
    SRA:     out = $signed(in_a) >>> in_b[4:0];
    OR :     out = in_a | in_b;
    default: out = in_a & in_b;

    endcase
end

endmodule