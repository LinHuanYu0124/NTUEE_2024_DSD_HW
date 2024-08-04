`include "./alu.v"
`include "./control.v"
`include "./register.v"
`include "./forwarding.v"
`include "./addr_align.v"
`include "./decompressor.v"
`include "./signextend.v"
`include "./wallace_mul.v"
// `include "./booth_mul.v"
// `include "./dadda_mul.v"
`include "./bpu.v"

module RISCV_Pipeline (
    input           clk, 
    input           rst_n,	
//----------I cache interface-------	
    output          ICACHE_ren,
    output          ICACHE_wen,
    output  [29:0]  ICACHE_addr,
    output  [31:0]  ICACHE_wdata,
    input           ICACHE_stall,
    input   [31:0]  ICACHE_rdata,
//----------D cache interface-------
    output          DCACHE_ren,
    output          DCACHE_wen,
    output  [29:0]  DCACHE_addr,
    output  [31:0]  DCACHE_wdata,
    input           DCACHE_stall,
    input   [31:0]  DCACHE_rdata,
//--------------PC-----------------
    output  [31:0]  PC
);


//==== wire/reg definition ================================

reg     [31:0]  ID_inst;
wire    [31:0]  IF_inst;
wire    [2:0]   PC_increment;

reg     [31:0]  IF_PC, PC_nxt, ID_PC, ID_PC_add, EX_PC_add, ME_PC_add, WB_PC_add;
wire    [31:0]  PC_1, PC_2, IF_PC_branch, IF_PC_add, PC_jal, PC_jalr;

wire            IF_stall, IF_flush, ID_flush;

// register
wire    [31:0]  WB_wdata;
reg     [31:0]  ID_rdata1, ID_rdata2, EX_rdata1, EX_rdata2, ME_rdata2;
reg     [4:0]   EX_rd, ME_rd, WB_rd;
wire    [4:0]   ID_rd, ID_rs1, ID_rs2;
wire    [31:0]  rs1_data, rs2_data;

reg     [4:0]   EX_rs1, EX_rs2;

// immediate
reg     [31:0]  EX_imm;
wire    [31:0]  ID_imm;

// control signals
wire    [3:0]   ID_aluop;
wire            ID_alusrc, ID_beq, ID_bne, ID_jal, ID_jalr, ID_mem_read, ID_mem_write, ID_reg_write, ID_mul;

reg     [3:0]   EX_aluop;
reg             EX_alusrc, EX_jump, ME_jump, WB_jump, EX_mem_read, ME_mem_read, EX_mem_write, ME_mem_write, EX_reg_write, ME_reg_write, WB_reg_write, EX_mul, ME_mul, WB_mul;

wire    [31:0]  WB_data_temp;

// alu inout
reg     [31:0]  alu_in_a, alu_in_b;
wire    [31:0]  EX_alu_out, MUL_result;
reg     [31:0]  ME_alu_out, WB_alu_out;

reg     [31:0]  WB_data_out;
wire    [31:0]  ME_data_out;
reg     [31:0]  alu_out;

wire            equal, branch, jump;

wire            Loaduse;

wire    [1:0]   EX_forward_1, EX_forward_2, ID_forward_1, ID_forward_2;
wire            forward_stall;

wire            ID_pred_wrong;
wire            IF_pred_result;
reg             ID_pred_result;

wire    [31:0]  I_cache_data, inst_decomp;
wire            addr_align_stall;
wire            compress;

// output assignment -----------------------------------------------------------
assign ICACHE_ren = 1'b1;
assign ICACHE_wen = 1'b0;
assign ICACHE_wdata = 32'b0;
assign DCACHE_ren = ME_mem_read;
assign DCACHE_wen = ME_mem_write;
assign DCACHE_addr = ME_alu_out[31:2];
assign DCACHE_wdata = {ME_rdata2[7:0], ME_rdata2[15:8], ME_rdata2[23:16], ME_rdata2[31:24]};
assign PC = IF_PC;

// --------------------------------------------------------------------------------
assign Loaduse = (EX_mem_read & ((EX_rd == ID_rs1) | (EX_rd == ID_rs2)));

Addr_Align addr_align (
    .clk(clk),
    .rst_n(rst_n),
    .pc_i(IF_PC),
    .I_cache_data_i(ICACHE_rdata),
    .I_cache_stall_i(ICACHE_stall),
    .I_cache_addr_o(ICACHE_addr),
    .I_chche_data_o(I_cache_data),
    .I_cache_stall_o(addr_align_stall)
);

Decompressor decompressor (
    .inst_i(I_cache_data),
    .inst_o(inst_decomp),
    .compress_o(compress)
);

BPU bpu(
    .clk(clk),
    .rst_n(rst_n),
    .IF_branch_i(IF_inst[6] & !IF_inst[2]),
    .ID_branch_i(ID_beq | ID_bne),
    .stall_i(addr_align_stall | DCACHE_stall | Loaduse| forward_stall),
    .wrong_i(ID_pred_wrong),
    .taken_o(IF_pred_result)
);

assign PC_1 = IF_pred_result ? IF_PC_branch : IF_PC_add;
assign PC_2 = ID_pred_result ? ID_PC_add : PC_jal;

// ----------------- PC reg ---------------------------
always @(*) begin
    casez ({IF_stall, jump, ID_pred_wrong})
        3'b1zz: begin
            PC_nxt = PC;
        end

        3'b01z: begin
            PC_nxt = ID_jalr ? PC_jalr : PC_jal;
        end

        3'b001: begin
            PC_nxt = PC_2;
        end

        default: begin
            PC_nxt = PC_1;
        end
    endcase
end

always@(posedge clk) begin
    if(~rst_n) begin
        IF_PC   <= 0;
    end else begin
        IF_PC   <= PC_nxt;
    end
end

//==================== IF stage =======================
assign IF_stall = addr_align_stall | DCACHE_stall | Loaduse | forward_stall;
assign ID_pred_wrong = branch != ID_pred_result;
assign IF_flush = jump | ID_pred_wrong;

localparam NOP = 32'b000000000000_00000_000_00000_0010011;
assign IF_inst = IF_stall ? ID_inst : IF_flush ? NOP : inst_decomp; // fetch instruction

assign PC_increment = compress ? 3'd2 : 3'd4;

assign IF_PC_add = IF_PC + PC_increment;

assign IF_PC_branch = IF_PC + { {20{IF_inst[31]}}, IF_inst[7], IF_inst[30:25], IF_inst[11:8], 1'b0 };

// IF/ID reg
always@(posedge clk) begin
    if(~rst_n) begin
        ID_inst <= 0;
        ID_PC   <= 0;
        ID_PC_add <= 0;
        ID_pred_result <= 0;
    end else begin
        ID_inst <= IF_inst;
        ID_PC   <= IF_stall ? ID_PC : IF_PC;
        ID_PC_add <= IF_stall ? ID_PC_add : IF_PC_add;
        ID_pred_result <= IF_stall ? ID_pred_result : IF_pred_result;
    end
end

//==================== ID stage =======================

Register register(
    .clk(clk),
    .rst_n(rst_n), 
    .wen_i(WB_reg_write),
    .rd_i(WB_rd), 
    .rs1_i(ID_rs1), 
    .rs2_i(ID_rs2),
    .rd_data_i(WB_wdata), 
    .rs1_data_o(rs1_data), 
    .rs2_data_o(rs2_data)
);

assign ID_rd = ID_inst[11:7];
assign ID_rs1 = ID_inst[19:15];
assign ID_rs2 = ID_inst[24:20];

Sign_Extend sign_extend(
    .inst_i(ID_inst),
    .imm_o(ID_imm)
);

assign PC_jal  = ID_PC + ID_imm; // PC for (jal | branch)
assign PC_jalr = ID_rdata1 + ID_imm; // PC for jalr

Control control(
    .inst_i(ID_inst),
    .aluop_o(ID_aluop),
    .alusrc_o(ID_alusrc),
    .beq_o(ID_beq),
    .bne_o(ID_bne),
    .jal_o(ID_jal),
    .jalr_o(ID_jalr),
    .mem_read_o(ID_mem_read),
    .mem_write_o(ID_mem_write),
    .reg_write_o(ID_reg_write),
    .mul_o(ID_mul)
);

always@(*) begin 
    case(ID_forward_1)  
        2'b00:   ID_rdata1 = rs1_data;
        2'b01:   ID_rdata1 = WB_wdata;
        default: ID_rdata1 = ME_alu_out;
    endcase

    case(ID_forward_2)
        2'b00:   ID_rdata2 = rs2_data;
        2'b01:   ID_rdata2 = WB_wdata;
        default: ID_rdata2 = ME_alu_out;
    endcase 
end

assign equal = (ID_rdata1 == ID_rdata2);
assign branch = (ID_beq & equal) | (ID_bne & ~equal);
assign jump = ID_jal | ID_jalr;

assign ID_flush = addr_align_stall | Loaduse | forward_stall;

// ID/EX reg 
always@(posedge clk) begin
    if(~rst_n) begin
        EX_aluop      <= 0;
        EX_alusrc     <= 0;
        EX_mem_read   <= 0;
        EX_mem_write  <= 0;
        EX_reg_write  <= 0;
        EX_imm        <= 0;
        EX_rd         <= 0;
        EX_rdata1     <= 0;
        EX_rdata2     <= 0;
        EX_PC_add     <= 0;
        EX_rs1        <= 0;
        EX_rs2        <= 0;
        EX_jump       <= 0;
        EX_mul        <= 0;
    end else begin
        EX_aluop      <= DCACHE_stall ? EX_aluop : ID_flush ? 0 : ID_aluop;
        EX_alusrc     <= DCACHE_stall ? EX_alusrc : ID_flush ? 0 : ID_alusrc;
        EX_mem_read   <= DCACHE_stall ? EX_mem_read : ID_flush ? 0 : ID_mem_read;
        EX_mem_write  <= DCACHE_stall ? EX_mem_write : ID_flush ? 0 : ID_mem_write;
        EX_reg_write  <= DCACHE_stall ? EX_reg_write : ID_flush ? 0 : ID_reg_write;
        EX_imm        <= DCACHE_stall ? EX_imm : ID_flush ? 0 : ID_imm;
        EX_rd         <= DCACHE_stall ? EX_rd : ID_flush ? 0 : ID_rd;
        EX_rdata1     <= DCACHE_stall ? EX_rdata1 : ID_flush ? 0 : ID_rdata1;
        EX_rdata2     <= DCACHE_stall ? EX_rdata2 : ID_flush ? 0 : ID_rdata2;
        EX_PC_add     <= DCACHE_stall ? EX_PC_add : ID_flush ? 0 : ID_PC_add;
        EX_rs1        <= DCACHE_stall ? EX_rs1 : ID_flush ? 0 : ID_rs1;
        EX_rs2        <= DCACHE_stall ? EX_rs2 : ID_flush ? 0 : ID_rs2;
        EX_jump       <= DCACHE_stall ? EX_jump : ID_flush ? 0 : jump;
        EX_mul        <= DCACHE_stall ? EX_mul : ID_flush ? 0 : ID_mul;
    end
end

// ---------------------------------------------------------

Forwarding forward(
    .EX_reg_write_i(EX_reg_write),
    .EX_rd_i(EX_rd),
    .ME_reg_write_i(ME_reg_write),
    .ME_rd_i(ME_rd),
    .WB_reg_write_i(WB_reg_write),
    .WB_rd_i(WB_rd),
    .ID_rs1_i(ID_rs1),
    .ID_rs2_i(ID_rs2),
    .EX_rs1_i(EX_rs1),
    .EX_rs2_i(EX_rs2),
    .EX_forward_1_o(EX_forward_1),
    .EX_forward_2_o(EX_forward_2),
    .ID_forward_1_o(ID_forward_1),
    .ID_forward_2_o(ID_forward_2),
    .forward_stall_o(forward_stall)
);

//==================== EX stage =======================
always@(*)begin
    case(EX_forward_1)
        2'b00:   alu_in_a = EX_rdata1;
        2'b01:   alu_in_a = WB_wdata;
        default: alu_in_a = ME_alu_out;
    endcase

    if(EX_alusrc==1'b0) begin
        alu_in_b = EX_imm;
    end else begin
        case(EX_forward_2)
            2'b00:   alu_in_b = EX_rdata2;
            2'b01:   alu_in_b = WB_wdata;
            default: alu_in_b = ME_alu_out;
        endcase
    end     
end

ALU alu(
    .aluop(EX_aluop),
    .a_i(alu_in_a),
    .b_i(alu_in_b),
    .out_o(EX_alu_out)
);

MUL_TOP mulunit(
    .clk(clk),
    .rst_n(rst_n),
    .A(alu_in_a),
    .B(alu_in_b),
    .Out(MUL_result)
);

// booth_multiplier_32bit_pipeline mulunit(
//     .clk(clk),
//     .rst_n(rst_n),
//     .A(alu_in_a),
//     .B(alu_in_b),
//     .Out(MUL_result)
// );

dadda_32 dadda_mul(
    .clk(clk),
    .rst_n(rst_n),
    .A(alu_in_a),
    .B(alu_in_b),
    .Out(MUL_result)
);

// EX/MEM reg
always@(posedge clk) begin
    if(~rst_n ) begin
        ME_alu_out    <= 0;
        ME_rdata2     <= 0;
        ME_rd         <= 0;
        ME_mem_read   <= 0;
        ME_mem_write  <= 0;
        ME_reg_write  <= 0;
        ME_jump       <= 0;
        ME_PC_add     <= 0;
        ME_mul        <= 0;
    end else begin
        ME_alu_out    <= DCACHE_stall ? ME_alu_out : EX_alu_out;
        ME_rdata2     <= DCACHE_stall ? ME_rdata2 : EX_rdata2;
        ME_rd         <= DCACHE_stall ? ME_rd : EX_rd;
        ME_mem_read   <= DCACHE_stall ? ME_mem_read : EX_mem_read;
        ME_mem_write  <= DCACHE_stall ? ME_mem_write : EX_mem_write;
        ME_reg_write  <= DCACHE_stall ? ME_reg_write : EX_reg_write;
        ME_jump       <= DCACHE_stall ? ME_jump : EX_jump;
        ME_PC_add     <= DCACHE_stall ? ME_PC_add : EX_PC_add;
        ME_mul        <= DCACHE_stall ? ME_mul : EX_mul;
    end
end

//==================== MEM stage =======================
assign ME_data_out = ME_mem_read ? {DCACHE_rdata[7:0], DCACHE_rdata[15:8], DCACHE_rdata[23:16], DCACHE_rdata[31:24]} : ME_alu_out;

// MEM/WB reg
always@(posedge clk) begin
    if(~rst_n) begin
        WB_rd         <= 0;
        WB_reg_write  <= 0;
        WB_data_out   <= 0;
        WB_alu_out    <= 0;
        WB_mul        <= 0;
        WB_jump       <= 0;
        WB_PC_add     <= 0;
    end
    else begin
        WB_rd         <= ME_rd;
        WB_reg_write  <= ME_reg_write;
        WB_data_out   <= ME_data_out;
        WB_alu_out    <= MUL_result;
        WB_mul        <= ME_mul;
        WB_jump       <= ME_jump;
        WB_PC_add     <= ME_PC_add ;
    end
end

//==================== WB stage =======================
assign WB_data_temp = WB_mul ? WB_alu_out : WB_data_out;
assign WB_wdata = WB_jump ? WB_PC_add : WB_data_temp;

endmodule