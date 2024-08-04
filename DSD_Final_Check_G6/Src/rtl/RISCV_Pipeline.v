// `include "./module/ALU.v"
// `include "./module/ALUControl.v"
// `include "./module/Control.v"
// `include "./module/EX_MEM_reg.v"
// `include "./module/ForwardingUnit.v"
// `include "./module/HazardDecUnit.v"
// `include "./module/ID_comparator.v"
// `include "./module/ID_EX_reg.v"
// `include "./module/IF_ID_reg.v"
// `include "./module/MEM_WB_reg.v"
// `include "./module/MUX32.v"
// `include "./module/PC.v"
// `include "./module/Registers.v"
// `include "./module/SignExtend.v"

module RISCV_Pipeline
(
    clk, 
    rst_n,
//----------I cache interface-------		
    ICACHE_ren,
    ICACHE_wen,
    ICACHE_addr,
    ICACHE_wdata,
    ICACHE_stall,
    ICACHE_rdata,
//----------D cache interface-------
    DCACHE_ren,
    DCACHE_wen,
    DCACHE_addr,
    DCACHE_wdata,
    DCACHE_stall,
    DCACHE_rdata,
//--------------PC-----------------
    PC
);

    input clk;
    input rst_n;
//----------I cache interface-------	  
    output        ICACHE_ren;
    output        ICACHE_wen;
    output [29:0] ICACHE_addr;
    output [31:0] ICACHE_wdata;
    input         ICACHE_stall;
    input  [31:0] ICACHE_rdata;
//----------D cache interface-------
    output        DCACHE_ren;
    output        DCACHE_wen;
    output [29:0] DCACHE_addr;
    output [31:0] DCACHE_wdata;
    input         DCACHE_stall;
    input  [31:0] DCACHE_rdata;
//--------------PC-----------------
    output [31:0] PC;

// wires & registers ---------------------------------------------------------------------------

    // IF
    wire    [31:0]  pc;
    wire    [31:0]  pc_next, branch_offset_w, pc_add;

    // IF/ID
    wire    [31:0]  IF_instr_w, ID_instr_w, ID_PC_w, EX_PC_w, MEM_PC_w;
    wire            PCWrite_w;

    // ID
    wire            ID_NoOp_w, IF_ID_Write_w, ID_FlushIF, ID_FlushEX, branch;
    wire    [31:0]  ID_PC_pre_w, ID_PC_after_pre_w;
    wire            ID_Prediction_w;
    wire            ID_realBranch_w;
    wire    [31:0]  ID_RealTarget_w;
    wire    [31:0]  ID_RS1_branch, ID_RS2_branch;

    // ID/EX
    wire            ID_RegWrite_w, EX_RegWrite_w, MEM_RegWrite_w, WB_RegWrite_w;
    wire    [1:0]   ID_MemtoReg_w, EX_MemtoReg_w, MEM_MemtoReg_w, WB_MemtoReg_w;
    wire            ID_MemRead_w, EX_MemRead_w, MEM_MemRead_w;
    wire            ID_MemWrite_w, EX_MemWrite_w, MEM_MemWrite_w;
    wire    [2:0]   ID_ALUOp_w, EX_ALUOp_w;
    wire            ID_ALUSrc_w, EX_ALUSrc_w;
    wire            ID_Branch_w, EX_Branch_w;
    wire            ID_Jump_JALR_w, EX_Jump_JALR_w;
    wire            ID_Jump_JAL_w, EX_Jump_JAL_w;

    wire    [31:0]  EX_Ttarget_w, EX_NTtarget_w;
    wire    [31:0]  ID_RS1data_w, EX_RS1data_w;
    wire    [31:0]  ID_RS2data_w, EX_RS2data_w;
    wire    [31:0]  IF_imme_w, ID_imme_w, EX_imme_w;
    wire    [4:0]   EX_WriteRegDest_w, MEM_WriteRegDest_w, WB_WriteRegDest_w;
    wire            EX_opcode_w;

    // EX
    wire    [2:0]   EX_Funct3_w;
    wire    [6:0]   EX_Funct7_w;
    wire    [4:0]   EX_RegSrc1_w, EX_RegSrc2_w;
    wire    [31:0]  EX_ALUdata1_w, EX_ALUdata2_w;
    wire    [3:0]   EX_ALUSignal_w;
    wire            EX_ALUZero_w, EX_ALUnotZero_w;
    wire    [1:0]   ForwardA_w, ForwardB_w;
    wire    [31:0]  EX_RS2data_AfterForwarding_w, MEM_MemWriteData_w;
    wire    [31:0]  EX_BeqorBne;    // 0: beq, 1: bne

    wire    [1:0]   ID_ForwardA_w, ID_ForwardB_w, EX_ForwardA_w, EX_ForwardB_w;
    
    // EX/MEM
    wire    [31:0]  EX_ALUResult_w, MEM_MemAddr_w;
    
    // MEM
    
    // MEM/WB
    wire    [31:0]  MEM_MemReadData_w, WB_MemReadData_w, WB_ALUResult_w;
    
    // WB
    wire    [31:0]  WB_RegWriteData_w1, WB_RegWriteData_w2;
    wire    [31:0]  WB_PC_w;
    wire    [31:0]  jalr_pc;
    wire    [31:0]  JALR_RS1;

    reg ICACHE_ren_r, ICACHE_ren_w; 
    wire [31:0] I_instruction, D_readdata, D_writedata;

    assign I_instruction = {ICACHE_rdata[7:0], ICACHE_rdata[15:8], ICACHE_rdata[23:16], ICACHE_rdata[31:24]};
    assign D_readdata = {DCACHE_rdata[7:0], DCACHE_rdata[15:8], DCACHE_rdata[23:16], DCACHE_rdata[31:24]};
    assign D_writedata = {MEM_MemWriteData_w[7:0], MEM_MemWriteData_w[15:8], MEM_MemWriteData_w[23:16], MEM_MemWriteData_w[31:24]};

// output assignment -----------------------------------------------------------
    assign ICACHE_ren = 1'b1;
    assign ICACHE_wen = 1'b0;
    assign ICACHE_addr = pc[31:2];
    assign ICACHE_wdata = 32'b0;

    assign DCACHE_ren = MEM_MemRead_w;
    assign DCACHE_wen = MEM_MemWrite_w;
    assign DCACHE_addr = MEM_MemAddr_w[31:2];
    assign DCACHE_wdata = D_writedata;

// Combi Logic -----------------------------------------------------------------

// IF stage
PC_unit PCunit(
    .clk_i(clk),
    .rst_i(rst_n),
    .PCWrite_i((PCWrite_w & !ICACHE_stall & !DCACHE_stall) | branch),
    .pc_i(pc_next),
    .pc_o(pc)
);

MUX3_32 MUX_JALR_PC(
    .I0_i(EX_ALUResult_w),
    .I1_i(EX_PC_w),
    .I2_i(JALR_RS1),
    .sel_i({(EX_WriteRegDest_w != I_instruction[19:15]), (EX_Jump_JAL_w && (EX_WriteRegDest_w == I_instruction[19:15]))}),
    .MuxOut_o(jalr_pc)
);


MUX4_32 ID_MUX_A1 (
    .I0_i(pc+4),
    .I1_i(pc+IF_imme_w),
    .I2_i(jalr_pc+IF_imme_w),
    .I3_i(ID_PC_w+ID_imme_w),
    .sel_i({((I_instruction[6:0] == 7'b1100111) | branch), ((I_instruction[6:0] == 7'b1101111) | branch)}),
    .MuxOut_o(pc_next)
);


// ==================
// =    IF/ID reg   =
// ==================
IFIDreg IF_ID (
    .clk_i(clk),
    .rst_i(rst_n),
    .IF_ID_Write_i(IF_ID_Write_w & !DCACHE_stall),
    .flush_i(branch),
    .Instr_i(I_instruction),    .Instr_o(ID_instr_w),
    .imm_i(IF_imme_w),          .imm_o(ID_imme_w),
    .PC_i(pc),                  .PC_o(ID_PC_w)
);

// ID stage
Control Control(
    .opcode_i(ID_instr_w[6:0]),
    .NoOp_i(ID_NoOp_w), 
    .RegWrite_o(ID_RegWrite_w),
    .MemtoReg_o(ID_MemtoReg_w),
    .MemRead_o(ID_MemRead_w),
    .MemWrite_o(ID_MemWrite_w),
    .ALUOp_o(ID_ALUOp_w),
    .ALUSrc_o(ID_ALUSrc_w),
    .Branch_o(ID_Branch_w),
    .Jump_JALR_o(ID_Jump_JALR_w),
    .Jump_JAL_o(ID_Jump_JAL_w)
);

Registers Registers(
    .clk_i(clk),
    .rst_i(rst_n),
    .RS1addr_i(ID_instr_w[19:15]),
    .RS2addr_i(ID_instr_w[24:20]),
    .JALR_RS1addr_i(I_instruction[19:15]),
    .RDaddr_i(WB_WriteRegDest_w),
    .RDdata_i(WB_RegWriteData_w2),
    .RegWrite_i(WB_RegWrite_w),
    .RS1data_o(ID_RS1data_w),
    .RS2data_o(ID_RS2data_w),
    .JALR_RS1data_o(JALR_RS1)
);

Sign_Extend Sign_Extend(
    .In_i(I_instruction),
    .Out_o(IF_imme_w)
);

Hazard_Detection Hazard_Detection (
    .EX_WriteRegDest_i(EX_WriteRegDest_w),
    .MEM_WriteRegDest_i(MEM_WriteRegDest_w),
    .EX_MemRead_w(EX_MemRead_w),
    .MEM_MemRead_w(MEM_MemRead_w),
    .ID_RegSrc1_i(ID_instr_w[19:15]),
    .ID_RegSrc2_i(ID_instr_w[24:20]),
    .ID_Branch_i(I_instruction[6:0]),
    .ID_inst_i(ID_instr_w),
    .NoOp_o(ID_NoOp_w),
    .IF_ID_Write_o(IF_ID_Write_w),
    .PCWrite_o(PCWrite_w)
);

MUX3_32 ID_MUX_A (
    .I0_i(ID_RS1data_w),
    .I1_i(MEM_MemAddr_w),
    .I2_i(EX_ALUResult_w),
    .sel_i(ID_ForwardA_w),
    .MuxOut_o(ID_RS1_branch)
);

MUX3_32 ID_MUX_B (
    .I0_i(ID_RS2data_w),
    .I1_i(MEM_MemAddr_w),
    .I2_i(EX_ALUResult_w),
    .sel_i(ID_ForwardB_w),
    .MuxOut_o(ID_RS2_branch)
);

ID_comparator ID_branch(
    .RS1data_i(ID_RS1_branch),
    .RS2data_i(ID_RS2_branch),
    .ID_Branch_i(ID_Branch_w),
    .func3_i(ID_instr_w[12]),
    .Branch_o(branch)
);

// ==================
// =    ID/EX reg   =
// ==================
IDEXreg ID_EX (
    .clk_i(clk),
    .rst_i(rst_n),
    .Flush_i(1'b0),
    .RegWrite_i(ID_RegWrite_w), .RegWrite_o(EX_RegWrite_w),//
    .MemtoReg_i(ID_MemtoReg_w), .MemtoReg_o(EX_MemtoReg_w),//
    .MemRead_i(ID_MemRead_w), .MemRead_o(EX_MemRead_w),//
    .MemWrite_i(ID_MemWrite_w), .MemWrite_o(EX_MemWrite_w),//
    .ALUOp_i(ID_ALUOp_w), .ALUOp_o(EX_ALUOp_w),//
    .ALUSrc_i(ID_ALUSrc_w), .ALUSrc_o(EX_ALUSrc_w),//
    .Branch_i(ID_Branch_w), .Branch_o(EX_Branch_w),//
    .Jump_JAL_i(ID_Jump_JAL_w), .Jump_JAL_o(EX_Jump_JAL_w),//
    .ReadData1_i(ID_RS1_branch), .ReadData1_o(EX_RS1data_w),//
    .ReadData2_i(ID_RS2_branch), .ReadData2_o(EX_RS2data_w),//
    .Immediate_i(ID_imme_w), .Immediate_o(EX_imme_w),//
    .Funct3_i(ID_instr_w[14:12]), .Funct3_o(EX_Funct3_w),//
    .Funct7_i(ID_instr_w[31:25]), .Funct7_o(EX_Funct7_w),
    .RegSrc1_i(ID_instr_w[19:15]), .RegSrc1_o(EX_RegSrc1_w),
    .RegSrc2_i(ID_instr_w[24:20]), .RegSrc2_o(EX_RegSrc2_w),
    .WriteRegDest_i(ID_instr_w[11:7]), .WriteRegDest_o(EX_WriteRegDest_w),
    .opcode_i(ID_instr_w[4]), .opcode_o(EX_opcode_w),
    .PC_i(ID_PC_w+4), .PC_o(EX_PC_w),
    .ID_EX_write_i(!DCACHE_stall)

);

// EX stage
ALU ALU(
    .Data1_i(EX_ALUdata1_w),
    .Data2_i(EX_ALUdata2_w),
    .ALUSignal_i(EX_ALUSignal_w),
    .ALUResult_o(EX_ALUResult_w)
);

MUX3_32 EX_MUX_A (
    .I0_i(EX_RS1data_w),
    .I1_i(WB_RegWriteData_w2),
    .I2_i(MEM_MemAddr_w),
    .sel_i(EX_ForwardA_w),
    .MuxOut_o(EX_ALUdata1_w)
);

MUX3_32 EX_MUX_B (
    .I0_i(EX_RS2data_w),
    .I1_i(WB_RegWriteData_w2),
    .I2_i(MEM_MemAddr_w),
    .sel_i(EX_ForwardB_w),
    .MuxOut_o(EX_RS2data_AfterForwarding_w)
);

MUX2_32 MUX_ALUSrc1(
    .I0_i(EX_RS2data_AfterForwarding_w),
    .I1_i(EX_imme_w),
    .sel_i(EX_ALUSrc_w),
    .MuxOut_o(EX_ALUdata2_w)
);

ALU_Control ALU_Control(
    .Funct7_i(EX_Funct7_w),
    .Funct3_i(EX_Funct3_w),
    .ALUOp_i(EX_ALUOp_w),
    .opcode_i(EX_opcode_w),
    .ALUSignal_o(EX_ALUSignal_w)
);

FordwardingUnit FordwardingUnit (
    .MEM_RegWrite_i(MEM_RegWrite_w),
    .MEM_RegDest_i(MEM_WriteRegDest_w),
    .WB_RegWrite_i(WB_RegWrite_w),
    .WB_RegDest_i(WB_WriteRegDest_w),
    .EX_RegWrite_i(EX_RegWrite_w),
    .EX_RegDest_i(EX_WriteRegDest_w),
    .ID_RegSrc1_i(ID_instr_w[19:15]),
    .ID_RegSrc2_i(ID_instr_w[24:20]),
    .EX_RegSrc1_i(EX_RegSrc1_w),
    .EX_RegSrc2_i(EX_RegSrc2_w),
    .ID_ForwardA_o(ID_ForwardA_w),
    .ID_ForwardB_o(ID_ForwardB_w),
    .EX_ForwardA_o(EX_ForwardA_w),
    .EX_ForwardB_o(EX_ForwardB_w)
);

// ===================
// =    EX/MEM reg  ==
// ===================
EXMEMreg EX_MEMReg_w (
    .clk_i(clk),
    .rst_i(rst_n),
    .RegWrite_i(EX_RegWrite_w), .RegWrite_o(MEM_RegWrite_w),////
    .MemtoReg_i(EX_MemtoReg_w), .MemtoReg_o(MEM_MemtoReg_w),//
    .MemRead_i(EX_MemRead_w), .MemRead_o(MEM_MemRead_w),//
    .MemWrite_i(EX_MemWrite_w), .MemWrite_o(MEM_MemWrite_w),////
    .ALUResult_i(EX_ALUResult_w), .ALUResult_o(MEM_MemAddr_w),//
    .MemWriteData_i(EX_RS2data_AfterForwarding_w), .MemWriteData_o(MEM_MemWriteData_w),//
    .WriteRegDest_i(EX_WriteRegDest_w), .WriteRegDest_o(MEM_WriteRegDest_w),//
    .PC_i(EX_PC_w), .PC_o(MEM_PC_w),//
    .EX_MEM_write_i(1'b1 & !DCACHE_stall)
);
























// ==================
// =    MEM/WB reg  =
// ==================
MEMWBreg MEM_WBreg (
    .clk_i(clk),
    .rst_i(rst_n),
    .RegWrite_i(MEM_RegWrite_w), .RegWrite_o(WB_RegWrite_w),//
    .MemtoReg_i(MEM_MemtoReg_w), .MemtoReg_o(WB_MemtoReg_w),////
    .MemAddr_i(MEM_MemAddr_w), .MemAddr_o(WB_ALUResult_w),////
    .MemReadData_i(D_readdata), .MemReadData_o(WB_MemReadData_w), ////
    .WriteRegDest_i(MEM_WriteRegDest_w), .WriteRegDest_o(WB_WriteRegDest_w),////
    .PC_i(MEM_PC_w), .PC_o(WB_PC_w)////
);

// WB stage
MUX2_32 MUX_RegWriteData1(
    .I0_i(WB_ALUResult_w),
    .I1_i(WB_MemReadData_w),
    .sel_i(WB_MemtoReg_w[0]),
    .MuxOut_o(WB_RegWriteData_w1)
);

MUX2_32 MUX_RegWriteData2(
    .I0_i(WB_RegWriteData_w1),
    .I1_i(WB_PC_w),
    .sel_i(WB_MemtoReg_w[1]),
    .MuxOut_o(WB_RegWriteData_w2)
);

endmodule

