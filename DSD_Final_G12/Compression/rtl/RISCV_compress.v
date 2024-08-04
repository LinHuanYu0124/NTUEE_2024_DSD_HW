`include "alu.v"
`include "control.v"
`include "decoder.v"
`include "register.v"
`include "forward.v"
`include "address_alignment.v"
`include "decompressor.v"

module RISCV_Pipeline (
    clk, 
    rst_n,	
    ICACHE_ren,
    ICACHE_wen,
    ICACHE_addr,
    ICACHE_wdata,
    ICACHE_stall,
    ICACHE_rdata,
    DCACHE_ren,
    DCACHE_wen,
    DCACHE_addr,
    DCACHE_wdata,
    DCACHE_stall,
    DCACHE_rdata,
    PC
);

//==== input/output definition ============================
    input          clk;
    input          rst_n;
//----------I cache interface-------		
    output	       ICACHE_ren;
	output	       ICACHE_wen;
	output	[29:0] ICACHE_addr;
	output	[31:0] ICACHE_wdata;
	input	       ICACHE_stall;
	input	[31:0] ICACHE_rdata;
//----------D cache interface-------
	output reg	       DCACHE_ren;
	output reg         DCACHE_wen;
	output reg	[29:0] DCACHE_addr;
	output reg  [31:0] DCACHE_wdata;
	input	       DCACHE_stall;
	input	[31:0] DCACHE_rdata;
//--------------PC-----------------
	output	[31:0] PC;

//==== wire/reg definition ================================

// instruction
reg [31:0] IF_inst, ID_inst;

// PC
reg [31:0] IF_PC, PC_add4, PC_add2, PC_jal, PC_jalr, PC_nxt;
reg [31:0] ID_PC, ID_PC_nxt, ID_PC_add, ID_PC_add_nxt;
reg [31:0] EX_PC_add, EX_PC_add_nxt;
reg [31:0] ME_PC_add, ME_PC_add_nxt, WB_PC_add;

// RF
reg [31:0] WB_wdata;
reg [31:0] ID_rdata1, EX_rdata1;
reg [31:0] ID_rdata2, EX_rdata2, ME_rdata2;
reg [4:0]  ID_rd,     EX_rd,     ME_rd,      WB_rd;

reg [4:0]  ID_rs1,    EX_rs1, EX_rs1_nxt;
reg [4:0]  ID_rs2,    EX_rs2, EX_rs2_nxt;

reg [31:0] EX_rdata1_nxt;
reg [31:0] EX_rdata2_nxt, ME_rdata2_nxt;
reg [4:0]  EX_rd_nxt,     ME_rd_nxt;


// immediate
reg [31:0] ID_imm, EX_imm, EX_imm_nxt;

// control signals
reg [3:0] ID_aluop,       EX_aluop;
reg       ID_alusrc,      EX_alusrc;
reg       ID_beq;
reg       ID_bne;
reg       ID_jal;
reg       ID_jalr;
reg       EX_jump,  EX_jump_nxt, ME_jump, ME_jump_nxt, WB_jump, WB_jump_nxt;   
reg       ID_mem_read,    EX_mem_read,   ME_mem_read;
reg       ID_mem_write,   EX_mem_write,  ME_mem_write;
reg       ID_reg_write,   EX_reg_write,  ME_reg_write,  WB_reg_write;

reg [3:0] EX_aluop_nxt;
reg       EX_alusrc_nxt;
reg       EX_mem_read_nxt,   ME_mem_read_nxt;
reg       EX_mem_write_nxt,  ME_mem_write_nxt;
reg       EX_reg_write_nxt,  ME_reg_write_nxt;

// alu inout
reg [31:0] alu_in_a, alu_in_b;
reg [31:0] EX_alu_out, ME_alu_out, ME_alu_out_nxt, WB_alu_out;

// pass down data
reg [31:0] ME_data_out, WB_data_out;

// branch, jal, jalr control
reg equal, branch, jump;

// NOP instruction
localparam NOP = 32'b000000000000_00000_000_00000_0010011;

// Load use condition
reg Loaduse;
always@(*) Loaduse = (EX_mem_read & ((EX_rd == ID_rs1) | (EX_rd == ID_rs2))) ;

// Forwarding control signals
wire [1:0] forward_a, forward_b, forward_c, forward_d;

reg forward_stall;
always@(*) forward_stall = (forward_c == 2'b11) | (forward_d == 2'b11);


// compressed ISA
wire [31:0] inst, inst_decomp;
wire addr_align_stall;
wire compressed;

//==================== IF stage =======================

// ICACHE control 
// assign ICACHE_addr = IF_PC[31:2];
assign ICACHE_ren = 1'b1;
assign ICACHE_wen = 1'b0;
assign ICACHE_wdata = 32'b0;
assign PC = IF_PC;


address_alignment addr_align (
    .clk(clk),
    .rst_n(rst_n),
    .pc(IF_PC),
    .i_cache_data(ICACHE_rdata),
    .i_cache_stall(ICACHE_stall),
    .addr(ICACHE_addr),
    .data(inst),
    .stall(addr_align_stall),
    .compression(compressed)
);

Decompressor decompressor (
    .inst_in(inst),
    .inst_out(inst_decomp)
);

// fetch instruction
always@(*) begin
    if(addr_align_stall | DCACHE_stall | Loaduse | forward_stall) 
        IF_inst = ID_inst;
    else if(jump)                    
        IF_inst = NOP;
    else
        IF_inst = inst_decomp;
end

// PC selection 
always@(*) begin
    PC_add4 = IF_PC + 4;
    PC_add2 = IF_PC + 2;
    ID_PC_nxt = IF_PC;
    ID_PC_add_nxt = compressed ? PC_add2 : PC_add4;
    if(addr_align_stall | DCACHE_stall | Loaduse | forward_stall) begin
        PC_nxt = PC;
        ID_PC_nxt = ID_PC;
        ID_PC_add_nxt = ID_PC_add;
    end
    else if(jump) begin
        PC_nxt = ID_jalr ? PC_jalr : PC_jal;
    end
    else begin
        PC_nxt = compressed ? PC_add2 : PC_add4;
    end
end


// sequential (IF/ID)
always@(posedge clk) begin
    if(~rst_n) begin
        ID_inst <= 0;
        IF_PC   <= 0;
        ID_PC   <= 0;
        ID_PC_add <= 0;
    end
    else begin
        ID_inst <= IF_inst;
        IF_PC   <= PC_nxt;
        ID_PC   <= ID_PC_nxt;
        ID_PC_add <= ID_PC_add_nxt;
    end
end

//==================== ID stage =======================
wire [31:0] rdata1, rdata2;
// register file
register RF(
    .clk(clk),
    .rst_n(rst_n), 
    .wen(WB_reg_write),
    .rd(WB_rd), 
    .rs1(ID_rs1), 
    .rs2(ID_rs2),
    .w_data(WB_wdata), 
    .r_data1(rdata1), 
    .r_data2(rdata2)
);

wire [31:0] imm;
wire [4:0]  rs1, rs2, rd;
// instruction decoder
Decoder decoder(
    .inst(ID_inst), 
    .imm(imm),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd)
);


always@(*) begin
    equal = (ID_rdata1 == ID_rdata2);
    branch = (ID_beq & equal) | (ID_bne & ~equal);
    jump = ID_jal | ID_jalr | branch;
end

// calculate PC for (jal | branch) and jalr
always@(*) begin
    PC_jal  = ID_PC + ID_imm;
    PC_jalr = ID_rdata1 + ID_imm;
end

wire [3:0] aluop;
wire alusrc;
wire beq;
wire bne;
wire jal;
wire jalr;
wire mem_read;
wire mem_write;
wire reg_write;

// control unit
Control control(
    .inst(ID_inst),
    .aluop(aluop),
    .alusrc(alusrc),
    .beq(beq),
    .bne(bne),
    .jal(jal),
    .jalr(jalr),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .reg_write(reg_write)
);

always@(*) begin
    // forwarding in ID stage
    case(forward_c)
    2'b10:   ID_rdata1 = ME_data_out;
    2'b01:   ID_rdata1 = WB_wdata;
    // 2'b11:   ID_rdata1 = 0; // handled by forward_stall
    default: ID_rdata1 = rdata1;
    endcase
    case(forward_d)
    2'b10:   ID_rdata2 = ME_data_out;
    2'b01:   ID_rdata2 = WB_wdata;
    // 2'b11:   ID_rdata2 = 0;
    default: ID_rdata2 = rdata2;
    endcase  

    ID_imm = imm;
    ID_rs1 = rs1;
    ID_rs2 = rs2;
    ID_rd = rd;
    ID_aluop = aluop;

    ID_alusrc = alusrc;
    ID_beq = beq;
    ID_bne = bne;
    ID_jal = jal;
    ID_jalr = jalr;
    ID_mem_read = mem_read;
    ID_mem_write = mem_write;
    ID_reg_write = reg_write;
end


always@(*)begin
    if(DCACHE_stall) begin
        EX_aluop_nxt      = EX_aluop;
        EX_alusrc_nxt     = EX_alusrc;
        EX_mem_read_nxt   = EX_mem_read;
        EX_mem_write_nxt  = EX_mem_write;
        EX_reg_write_nxt  = EX_reg_write;

        EX_imm_nxt        = EX_imm;
        EX_rd_nxt         = EX_rd;
        EX_rdata1_nxt     = EX_rdata1;
        EX_rdata2_nxt     = EX_rdata2;
        EX_PC_add_nxt     = EX_PC_add;

        EX_rs1_nxt        = EX_rs1;
        EX_rs2_nxt        = EX_rs2;

        EX_jump_nxt       = EX_jump;
    end

    else if(addr_align_stall | Loaduse | forward_stall) begin
        EX_aluop_nxt      = 0;
        EX_alusrc_nxt     = 0;
        EX_mem_read_nxt   = 0;
        EX_mem_write_nxt  = 0;
        EX_reg_write_nxt  = 0;

        EX_imm_nxt        = 0;
        EX_rd_nxt         = 0;
        EX_rdata1_nxt     = 0;
        EX_rdata2_nxt     = 0;
        EX_PC_add_nxt     = 0;

        EX_rs1_nxt        = 0;
        EX_rs2_nxt        = 0;

        EX_jump_nxt       = 0;
    end
    else begin
        EX_aluop_nxt      = ID_aluop;
        EX_alusrc_nxt     = ID_alusrc;
        EX_mem_read_nxt   = ID_mem_read;
        EX_mem_write_nxt  = ID_mem_write;
        EX_reg_write_nxt  = ID_reg_write;

        EX_imm_nxt        = ID_imm;
        EX_rd_nxt         = ID_rd;
        EX_rdata1_nxt     = ID_rdata1;
        EX_rdata2_nxt     = ID_rdata2;
        EX_PC_add_nxt     = ID_PC_add;

        EX_rs1_nxt        = ID_rs1;
        EX_rs2_nxt        = ID_rs2;

        EX_jump_nxt       = jump;
    end

end

// sequential (ID/EX)
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
       
    end
    else begin
        EX_aluop      <= EX_aluop_nxt;
        EX_alusrc     <= EX_alusrc_nxt;
        EX_mem_read   <= EX_mem_read_nxt;
        EX_mem_write  <= EX_mem_write_nxt;
        EX_reg_write  <= EX_reg_write_nxt;

        EX_imm        <= EX_imm_nxt;
        EX_rd         <= EX_rd_nxt;
        EX_rdata1     <= EX_rdata1_nxt;
        EX_rdata2     <= EX_rdata2_nxt;
        EX_PC_add     <= EX_PC_add_nxt;

        EX_rs1        <= EX_rs1_nxt;
        EX_rs2        <= EX_rs2_nxt;

        EX_jump       <= EX_jump_nxt;

    end
end

//==================== EX stage =======================

// forwarding unit
Forward forward(
    .EX_reg_write(EX_reg_write),
    .EX_rd(EX_rd),
    .ME_reg_write(ME_reg_write),
    .ME_rd(ME_rd),
    .WB_reg_write(WB_reg_write),
    .WB_rd(WB_rd),
    .ID_rs1(ID_rs1),
    .ID_rs2(ID_rs2),
    .EX_rs1(EX_rs1),
    .EX_rs2(EX_rs2),
    .forward_a(forward_a),
    .forward_b(forward_b),
    .forward_c(forward_c),
    .forward_d(forward_d)
);

// alu

// forwarding in EX stage (select alu input source)
always@(*)begin
    case(forward_a)
    2'b01:   alu_in_a = WB_wdata;
    2'b00:   alu_in_a = EX_rdata1;
    default: alu_in_a = ME_data_out;
    endcase

    if(EX_alusrc==1'b0) alu_in_b = EX_imm;
    else begin
        case(forward_b)
        2'b01:   alu_in_b = WB_wdata;
        2'b00:   alu_in_b = EX_rdata2;
        default: alu_in_b = ME_data_out;
        endcase
    end     
end

wire [31:0] alu_out;
ALU alu(
    .aluop(EX_aluop),
    .in_a(alu_in_a),
    .in_b(alu_in_b),
    .out(alu_out)
);

always@(*) begin
    EX_alu_out = alu_out;
end

//stall
always@(*)begin
    if(DCACHE_stall)begin
        ME_alu_out_nxt    = ME_alu_out;
        ME_rdata2_nxt     = ME_rdata2;
        ME_rd_nxt         = ME_rd;
        ME_mem_read_nxt   = ME_mem_read;
        ME_mem_write_nxt  = ME_mem_write;
        ME_reg_write_nxt  = ME_reg_write;
        ME_PC_add_nxt     = ME_PC_add;

        ME_jump_nxt = ME_jump;

    end
    else begin
        ME_alu_out_nxt    = EX_alu_out;
        ME_rdata2_nxt     = EX_rdata2;
        ME_rd_nxt         = EX_rd;
        ME_mem_read_nxt   = EX_mem_read;
        ME_mem_write_nxt  = EX_mem_write;
        ME_reg_write_nxt  = EX_reg_write;
        ME_PC_add_nxt     = EX_PC_add;

        ME_jump_nxt = EX_jump;

    end
end

// sequential (EX/ME)
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

    end
    else begin
        ME_alu_out    <= ME_alu_out_nxt;
        ME_rdata2     <= ME_rdata2_nxt;
        ME_rd         <= ME_rd_nxt;
        ME_mem_read   <= ME_mem_read_nxt;
        ME_mem_write  <= ME_mem_write_nxt;
        ME_reg_write  <= ME_reg_write_nxt;

        ME_jump       <= ME_jump_nxt;
        ME_PC_add     <= ME_PC_add_nxt;

    end
end

//==================== ME stage =======================

// DCACHE control
always@(*) begin
    DCACHE_ren = ME_mem_read;
    DCACHE_wen = ME_mem_write;
    DCACHE_addr = ME_alu_out[31:2];
    // convert to little endian before write
    DCACHE_wdata = {ME_rdata2[7:0], ME_rdata2[15:8], ME_rdata2[23:16], ME_rdata2[31:24]};
    // pass down data
    ME_data_out = ME_mem_read ? {DCACHE_rdata[7:0], DCACHE_rdata[15:8], DCACHE_rdata[23:16], DCACHE_rdata[31:24]} : ME_alu_out;
end

// sequential (ME/WB)
always@(posedge clk) begin
    if(~rst_n | DCACHE_stall) begin
        WB_rd         <= 0;
        WB_reg_write  <= 0;
        WB_data_out   <= 0;
        WB_alu_out    <= 0;

        WB_jump       <= 0;
        WB_PC_add     <= 0;
    end
    else begin
        WB_rd         <= ME_rd;
        WB_reg_write  <= ME_reg_write;
        WB_data_out   <= ME_data_out;
        WB_alu_out    <= ME_alu_out;

        WB_jump       <= ME_jump;
        WB_PC_add     <= ME_PC_add ;
    end
end

//==================== WB stage =======================

// select write back data
always@(*) begin
    WB_wdata = WB_jump ? WB_PC_add : WB_data_out;
end

endmodule