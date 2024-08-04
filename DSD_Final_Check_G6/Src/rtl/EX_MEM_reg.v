module EXMEMreg 
(
    clk_i,
    rst_i,
    RegWrite_i, RegWrite_o,
    MemtoReg_i, MemtoReg_o,
    MemRead_i, MemRead_o,
    MemWrite_i, MemWrite_o,
    ALUResult_i, ALUResult_o,
    MemWriteData_i, MemWriteData_o,
    WriteRegDest_i, WriteRegDest_o,
    PC_i, PC_o,
    EX_MEM_write_i
);

// I/O
input clk_i, rst_i;
input RegWrite_i, MemRead_i, MemWrite_i;
input [1:0] MemtoReg_i;
input [31:0] ALUResult_i, MemWriteData_i;
input [4:0] WriteRegDest_i;
input [31:0] PC_i;
input EX_MEM_write_i;

output RegWrite_o, MemRead_o, MemWrite_o;
output [1:0] MemtoReg_o;
output [31:0] ALUResult_o, MemWriteData_o;
output [4:0] WriteRegDest_o;
output [31:0] PC_o;

// registers and wires
reg RegWrite_r, MemRead_r, MemWrite_r;
reg [1:0] MemtoReg_r;
reg [31:0] ALUResult_r, MemWriteData_r;
reg [4:0] WriteRegDest_r;
reg [31:0] PC_r;

wire RegWrite_w, MemRead_w, MemWrite_w;
wire [1:0] MemtoReg_w;
wire [31:0] ALUResult_w, MemWriteData_w;
wire [4:0] WriteRegDest_w;
wire [31:0] PC_w;

// output assignment
assign RegWrite_o = RegWrite_r;
assign MemtoReg_o = MemtoReg_r;
assign MemRead_o = MemRead_r;
assign MemWrite_o = MemWrite_r;
assign ALUResult_o = ALUResult_r;
assign MemWriteData_o = MemWriteData_r;
assign WriteRegDest_o = WriteRegDest_r;
assign PC_o = PC_r;

assign RegWrite_w = EX_MEM_write_i ? RegWrite_i : RegWrite_r;
assign MemtoReg_w = EX_MEM_write_i ? MemtoReg_i : MemtoReg_r;
assign MemRead_w = EX_MEM_write_i ? MemRead_i : MemRead_r;
assign MemWrite_w = EX_MEM_write_i ? MemWrite_i : MemWrite_r;
assign ALUResult_w = EX_MEM_write_i ? ALUResult_i : ALUResult_r;
assign MemWriteData_w = EX_MEM_write_i ? MemWriteData_i : MemWriteData_r;
assign WriteRegDest_w = EX_MEM_write_i ? WriteRegDest_i : WriteRegDest_r;
assign PC_w = EX_MEM_write_i ? PC_i : PC_r;

always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i) begin
        RegWrite_r <= 0;
        MemtoReg_r <= 0;
        MemRead_r <= 0;
        MemWrite_r <= 0;
        ALUResult_r <= 0;
        MemWriteData_r <= 0;
        WriteRegDest_r <= 0;
        PC_r <= 32'b0;
    end
    else begin
        RegWrite_r <= RegWrite_w;
        MemtoReg_r <= MemtoReg_w;
        MemRead_r <= MemRead_w;
        MemWrite_r <= MemWrite_w;
        ALUResult_r <= ALUResult_w;
        MemWriteData_r <= MemWriteData_w;
        WriteRegDest_r <= WriteRegDest_w;
        PC_r <= PC_w;
    end
end

endmodule