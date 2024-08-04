module MEMWBreg 
(
    clk_i,
    rst_i,
    RegWrite_i, RegWrite_o,
    MemtoReg_i, MemtoReg_o,
    MemAddr_i, MemAddr_o,
    MemReadData_i, MemReadData_o, 
    WriteRegDest_i, WriteRegDest_o,
    PC_i, PC_o
);

// I/O
input clk_i, rst_i;
input RegWrite_i;
input [1:0] MemtoReg_i;
input [31:0] MemAddr_i, MemReadData_i;
input [4:0] WriteRegDest_i;
input [31:0] PC_i;

output RegWrite_o;
output [1:0] MemtoReg_o;
output [31:0] MemAddr_o, MemReadData_o;
output [4:0] WriteRegDest_o;
output [31:0] PC_o;

// registers and wires
reg RegWrite_r;
reg [1:0] MemtoReg_r;
reg [31:0] MemAddr_r, MemReadData_r;
reg [4:0] WriteRegDest_r;
reg [31:0] PC_r;


// output assignment
assign RegWrite_o = RegWrite_r;
assign MemtoReg_o = MemtoReg_r;
assign MemAddr_o = MemAddr_r;
assign MemReadData_o = MemReadData_r;
assign WriteRegDest_o = WriteRegDest_r;
assign PC_o = PC_r;


always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i) begin
        RegWrite_r <= 0;
        MemtoReg_r <= 0;
        MemAddr_r <= 0;
        MemReadData_r <= 0;
        WriteRegDest_r <= 0;
        PC_r <= 32'b0;
    end
    else begin
        RegWrite_r <= RegWrite_i;
        MemtoReg_r <= MemtoReg_i;
        MemAddr_r <= MemAddr_i;
        MemReadData_r <= MemReadData_i;
        WriteRegDest_r <= WriteRegDest_i;
        PC_r <= PC_i;
    end
end

endmodule