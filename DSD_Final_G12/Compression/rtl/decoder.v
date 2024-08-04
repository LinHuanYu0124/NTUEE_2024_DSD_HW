module Decoder(
    inst,
    imm,
    rs1,
    rs2,
    rd
);

input [31:0] inst;
output reg [31:0] imm;
output reg [4:0] rs1, rs2, rd;

// generate immediate
always@(*) begin
    // jal
    if (inst[3]) imm = { {20{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0 };
    // I type (NOTICE: slli, srli, srai shamt = imm[4:0])
    else if (!inst[5] | inst[2]) imm = { {20{inst[31]}}, inst[31:20] };
    // beq, bne
    else if (inst[6]) imm = { {20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0 };
    // sw
    else imm =  { {20{inst[31]}}, inst[30:25], inst[11:7] };
end

always@(*) begin
    rd  = inst[11:7];
    rs1 = inst[19:15];
    rs2 = inst[24:20];
end

endmodule