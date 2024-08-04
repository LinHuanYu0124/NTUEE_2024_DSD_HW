module IDEXreg 
(
    clk_i,
    rst_i,
    Flush_i,
    RegWrite_i, RegWrite_o,
    MemtoReg_i, MemtoReg_o,
    MemRead_i, MemRead_o,
    MemWrite_i, MemWrite_o,
    ALUOp_i, ALUOp_o,
    ALUSrc_i, ALUSrc_o,
    Branch_i, Branch_o,
    Jump_JAL_i, Jump_JAL_o,
    ReadData1_i, ReadData1_o,
    ReadData2_i, ReadData2_o,
    Immediate_i, Immediate_o,
    Funct3_i, Funct3_o,
    Funct7_i, Funct7_o,
    RegSrc1_i, RegSrc1_o,
    RegSrc2_i, RegSrc2_o,
    WriteRegDest_i, WriteRegDest_o,
    opcode_i, opcode_o,
    PC_i, PC_o,
    ID_EX_write_i
);

// I/O
input clk_i, rst_i;
input Flush_i;
input RegWrite_i, MemRead_i, MemWrite_i, ALUSrc_i, Branch_i, Jump_JAL_i;
input [1:0] MemtoReg_i;
input [2:0] ALUOp_i;
input [31:0] ReadData1_i, ReadData2_i, Immediate_i;
input [2:0] Funct3_i;
input [6:0] Funct7_i;
input [4:0] RegSrc1_i, RegSrc2_i;
input [4:0] WriteRegDest_i;
input opcode_i;
input [31:0] PC_i;
input ID_EX_write_i;

output RegWrite_o, MemRead_o, MemWrite_o, ALUSrc_o, Branch_o, Jump_JAL_o;
output [1:0] MemtoReg_o;
output [2:0] ALUOp_o;
output [31:0] ReadData1_o, ReadData2_o, Immediate_o;
output [2:0] Funct3_o;
output [6:0] Funct7_o;
output [4:0] RegSrc1_o, RegSrc2_o;
output [4:0] WriteRegDest_o;
output opcode_o;
output [31:0] PC_o;

// registers and wires
wire RegWrite_w, MemRead_w, MemWrite_w, ALUSrc_w, Branch_w, Jump_JAL_w;
wire [1:0] MemtoReg_w;
wire [2:0] ALUOp_w;
wire [31:0] ReadData1_w, ReadData2_w, Immediate_w;
wire [2:0] Funct3_w;
wire [6:0] Funct7_w;
wire [4:0] RegSrc1_w, RegSrc2_w;
wire [4:0] WriteRegDest_w;
wire opcode_w;
wire [31:0] PC_w;

reg RegWrite_r, MemRead_r, MemWrite_r, ALUSrc_r, Branch_r, Jump_JAL_r;
reg [1:0] MemtoReg_r;
reg [2:0] ALUOp_r;
reg [31:0] ReadData1_r, ReadData2_r, Immediate_r;
reg [2:0] Funct3_r;
reg [6:0] Funct7_r;
reg [4:0] RegSrc1_r, RegSrc2_r;
reg [4:0] WriteRegDest_r;
reg opcode_r;
reg [31:0] PC_r;

// output assignment
assign RegWrite_o = RegWrite_r;
assign MemtoReg_o = MemtoReg_r;
assign MemRead_o = MemRead_r;
assign MemWrite_o = MemWrite_r;
assign ALUSrc_o = ALUSrc_r;
assign ALUOp_o = ALUOp_r;
assign Branch_o = Branch_r;
assign ReadData1_o = ReadData1_r;
assign ReadData2_o = ReadData2_r;
assign Immediate_o = Immediate_r;
assign Funct3_o = Funct3_r;
assign Funct7_o = Funct7_r;
assign RegSrc1_o = RegSrc1_r;
assign RegSrc2_o = RegSrc2_r;
assign WriteRegDest_o = WriteRegDest_r;
assign opcode_o = opcode_r;
assign PC_o = PC_r;
assign Jump_JAL_o = Jump_JAL_r;

assign RegWrite_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? RegWrite_i : RegWrite_r;
assign MemtoReg_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? MemtoReg_i : MemtoReg_r;
assign MemRead_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? MemRead_i : MemRead_r;
assign MemWrite_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? MemWrite_i : MemWrite_r;
assign ALUSrc_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? ALUSrc_i : ALUSrc_r;
assign ALUOp_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? ALUOp_i : ALUOp_r;
assign Branch_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? Branch_i : Branch_r;
assign ReadData1_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? ReadData1_i : ReadData1_r;
assign ReadData2_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? ReadData2_i : ReadData2_r;
assign Immediate_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? Immediate_i : Immediate_r;
assign Funct3_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? Funct3_i : Funct3_r;
assign Funct7_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? Funct7_i : Funct7_r;
assign RegSrc1_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? RegSrc1_i : RegSrc1_r;
assign RegSrc2_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? RegSrc2_i : RegSrc2_r;
assign WriteRegDest_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? WriteRegDest_i : WriteRegDest_r;
assign opcode_w = (Flush_i) ? 1'b0 : ID_EX_write_i ? opcode_i : opcode_r;
assign PC_w = (Flush_i) ? 32'b0 : ID_EX_write_i ? PC_i : PC_r;
assign Jump_JAL_w = (Flush_i) ? 1'b0 : ID_EX_write_i ? Jump_JAL_i : Jump_JAL_r;

always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i) begin
        RegWrite_r <= 0;
        MemtoReg_r <= 0;
        MemRead_r <= 0;
        MemWrite_r <= 0;
        ALUSrc_r <= 0;
        ALUOp_r <= 0;
        Branch_r <= 0;
        ReadData1_r <= 0;
        ReadData2_r <= 0;
        Immediate_r <= 0;
        Funct3_r <= 0;
        Funct7_r <= 0;
        RegSrc1_r <= 0;
        RegSrc2_r <= 0;
        WriteRegDest_r <= 0;
        opcode_r <= 1'b0;
        PC_r <= 32'b0;
        Jump_JAL_r <= 1'b0;
    end
    else begin
        RegWrite_r <= RegWrite_w;
        MemtoReg_r <= MemtoReg_w;
        MemRead_r <= MemRead_w;
        MemWrite_r <= MemWrite_w;
        ALUSrc_r <= ALUSrc_w;
        ALUOp_r <= ALUOp_w;
        Branch_r <= Branch_w;
        ReadData1_r <= ReadData1_w;
        ReadData2_r <= ReadData2_w;
        Immediate_r <= Immediate_w;
        Funct3_r <= Funct3_w;
        Funct7_r <= Funct7_w;
        RegSrc1_r <= RegSrc1_w;
        RegSrc2_r <= RegSrc2_w;
        WriteRegDest_r <= WriteRegDest_w;
        opcode_r <= opcode_w;
        PC_r <= PC_w;
        Jump_JAL_r <= Jump_JAL_w;
    end
end

endmodule