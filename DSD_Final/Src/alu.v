module ALU(
    input       [3:0]   aluop,
    input       [31:0]  a_i,
    input       [31:0]  b_i,
    output reg  [31:0]  out_o
);


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
        ADD:     out_o = $signed(a_i) + $signed(b_i);
        SUB:     out_o = $signed(a_i) - $signed(b_i);
        SLL:     out_o = a_i << $signed(b_i);
        SLT:     out_o = $signed(a_i) < $signed(b_i);
        XOR:     out_o = a_i ^ b_i;
        SRL:     out_o = a_i >> $signed(b_i);
        SRA:     out_o = $signed(a_i) >>> $signed(b_i);
        OR :     out_o = a_i | b_i;
        default: out_o = a_i & b_i;
    endcase
end

endmodule