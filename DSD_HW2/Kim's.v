// Your SingleCycle RISC-V code

module CHIP (
    clk,
    rst_n,

    // for mem_D
    mem_wen_D,
    mem_addr_D,
    mem_wdata_D,
    mem_rdata_D,

    // for mem_I
    mem_addr_I,
    mem_rdata_I
);

    input         clk, rst_n ;

    // for mem_D
    output        mem_wen_D  ;  // mem_wen_D is high, CHIP writes data to D-mem; else, CHIP reads data from D-mem
    output [31:0] mem_addr_D ;  // the specific address to fetch/store data 
    output [31:0] mem_wdata_D;  // data writing to D-mem 
    input  [31:0] mem_rdata_D;  // data reading from D-mem

    // for mem_I
    output [31:0] mem_addr_I ;  // the fetching address of next instruction
    input  [31:0] mem_rdata_I;  // instruction reading from I-mem


    // Wires and Registers  ---------------------------------------------------------------------

    // input buffer
    wire [31:0] i_mem_rdata_D;
    wire [31:0] i_mem_rdata_I;

    assign i_mem_rdata_D = {mem_rdata_D[7:0], mem_rdata_D[15:8], mem_rdata_D[23:16], mem_rdata_D[31:24]};
    assign i_mem_rdata_I = {mem_rdata_I[7:0], mem_rdata_I[15:8], mem_rdata_I[23:16], mem_rdata_I[31:24]};

    // output buffer
    reg [31:0] PC, PC_nxt;

    // Reg_file output wire 
    wire [31:0] Write_data, Read_data1, Read_data2;

    // Control output wire
    wire        Branch;
    wire        Jump_JALR;
    wire        Jump_JAL;
    wire       	MemRead;
    wire [1:0]  MemtoReg;
    wire       	MemWrite;
    wire       	ALUSrc;
    wire       	RegWrite;
    wire [2:0] 	ALUOp;

    // Imm_Gen output wire
    wire [31:0] imm;

    // ALU_control output wire
    wire [3:0] 	ALU_control;

    // MUX_ALUSrc output wire
    wire [31:0] ALU_data2;

    // ALU output wire
    wire [31:0] 	o_data;
    wire            o_zero;

    // PC_Adder output wire
    wire [31:0] PC_nxt_result;

    // Continuous Assignment --------------------------------------------------------------------

    assign mem_addr_I = PC; 
    assign mem_addr_D = o_data;                         
    assign mem_wdata_D = {Read_data2[7:0], Read_data2[15:8], Read_data2[23:16], Read_data2[31:24]};                                    
    assign mem_wen_D = MemWrite;

    // Submoddules ------------------------------------------------------------------------------

    Reg_file reg0(               
        .clk    (clk),             
        .rst_n  (rst_n),         

        .rs1    (i_mem_rdata_I[19:15]),//RS1addr                
        .rs2    (i_mem_rdata_I[24:20]),//RS2addr                
        .rd     (i_mem_rdata_I[11:7]),//MEM_WB_RDaddr                 
        .wen    (RegWrite),//RegWrite          
        .wdata  (Write_data),//RDdata   

        .rdata1 (Read_data1),//RS1data           
        .rdata2 (Read_data2)//RS2data
    );

    Control control(
        .i_Opcode         (i_mem_rdata_I[6:0]),//Opcode

        .o_ALUOp          (ALUOp)//ALUOp
        .o_ALUSrc         (ALUSrc),//ALUSrc
        .o_RegWrite       (RegWrite),//RegWrite
        .o_MemtoReg       (MemtoReg),//MemtoReg
        .o_MemRead        (MemRead),//MemRead
        .o_MemWrite       (MemWrite),//MemWrite
        .o_Branch         (Branch),//Branch
        .o_Jump_JAL       (Jump_JAL),//Jal
        .o_Jump_JALR      (Jump_JALR),//Jalr
    );

    Imm_Gen imm_gen(
        .i_inst (i_mem_rdata_I),
        .o_imm  (imm)//Imm_o
    );
    
    ALU_control alu_control(
        .i_ALUOp       (ALUOp),
        .i_funct3      (i_mem_rdata_I[14:12]),
        .i_funct7      (i_mem_rdata_I[31:25]),
        .o_ALU_control (ALU_control)
    );
    
    PC_Adder pc_adder(
        .i_one_hot_control 	({Branch, o_zero, Jump_JALR, Jump_JAL}),
        .i_PC              	(PC),
        .i_offset          	(imm),
        .rs1                (Read_data1),
        .o_PC_nxt_temp      (PC_nxt_result)
    );
    
    MUX2 MUX2_ALUSrc(
        .i_ctrl 	(ALUSrc),
        .i_0    	(Read_data2),
        .i_1    	(imm),
        .o_data 	(ALU_data2)//ForwardAdata
    );

    MUX3 MUX3_MemtoReg( 
        .i_ctrl       	(MemtoReg),
        .i_ALU_result 	(o_data),//data
        .i_MEM_data   	(i_mem_rdata_D),//mem_rdata_D_layout
        .i_PC_plus_four (PC+4),
        .o_data       	(Write_data)
    );
    
    ALU u_ALU(
        .i_A     	( Read_data1 ),
        .i_B     	( ALU_data2 ),
        .i_inst  	( ALU_control ),
        .o_data  	( o_data   ),
        .o_zero  	( o_zero   )
    );

    // Combinational ---------------------------------------------------------------------------

    always @(*) begin
        PC_nxt = PC_nxt_result;
    end

    // Sequential ------------------------------------------------------------------------------

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= 32'h00000000;
        end else begin
            PC <= PC_nxt;
        end
    end
endmodule

module Reg_file (clk, rst_n, wen, rs1, rs2, rd, wdata, rdata1, rdata2);
    
    input clk, rst_n, wen;
    input [31:0] wdata;    
    input [4:0] rs1, rs2, rd;

    output [31:0] rdata1, rdata2;

    reg [31:0] mem [0:31];     
    reg [31:0] mem_nxt [0:31];  

    integer i;

    assign rdata1 = mem[rs1];   
    assign rdata2 = mem[rs2];   

    always @(*) begin
        for (i=0; i<31; i=i+1) 
            mem_nxt[i] = (wen && (rd == i)) ? wdata : mem[i]; 
    end  

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= 0;   // X0 stores constant 0
            for (i=1; i<31; i=i+1) begin
                case(i)
                    32'd2: mem[i] <= 32'hbffffff0;  // X2 stores stack pointer
                    32'd3: mem[i] <= 32'h10008000;  // X3 stores global pointer
                    default: mem[i] <= 32'h0;
                endcase
            end
        end
        else begin
            mem[0] <= 0;
            for (i=1; i<31; i=i+1)
                mem[i] <= mem_nxt[i];
        end       
    end
endmodule

module Control (i_Opcode, o_Branch, o_MemRead, o_MemtoReg, o_ALUOp, o_MemWrite, o_ALUSrc, o_RegWrite, o_Jump_JALR, o_Jump_JAL);
    input [6:0] i_Opcode;
    output o_MemRead, o_MemWrite, o_ALUSrc, o_RegWrite, o_Jump_JALR, o_Jump_JAL, o_Branch;
    output [1:0] o_MemtoReg; 
    output reg [2:0] o_ALUOp;

    assign o_MemRead = (i_Opcode == 7'b0000011) ? 1'b1 : 1'b0; // lw
    assign o_MemtoReg[0] = (i_Opcode == 7'b0000011) ? 1'b1 : 1'b0; // lw
    assign o_MemtoReg[1] = (i_Opcode == 7'b1101111 || i_Opcode == 7'b1100111) ? 1'b1 : 1'b0; // jal || jalr
    assign o_MemWrite = (i_Opcode == 7'b0100011) ? 1'b1 : 1'b0; // sw
    assign o_ALUSrc = (i_Opcode == 7'b0000011 || i_Opcode == 7'b1100111 || i_Opcode == 7'b1101111 || i_Opcode == 7'b0100011) ? 1'b1 : 1'b0; // lw || jalr || jal || sw
    assign o_RegWrite = (i_Opcode != 7'b0100011 && i_Opcode != 7'b1100011) ? 1'b1 : 1'b0; // !sw & !branch
    assign o_Branch = (i_Opcode == 7'b1100011) ? 1'b1 : 1'd0; // branch
    assign o_Jump_JALR = (i_Opcode == 7'b1100111) ? 1'b1 : 1'b0; // jalr
    assign o_Jump_JAL  = (i_Opcode == 7'b1101111) ? 1'b1 : 1'b0; // jal

    always @(*) begin
        case(i_Opcode)

            7'b0110011 : begin  // R-type : ADD, SUB, OR, SLT
                o_ALUOp = 3'b000;
            end

            7'b1100111 : begin  // I-type : JALR
                o_ALUOp = 3'b010;
            end 

            7'b0000011 : begin  // I-type : LW
                o_ALUOp = 3'b010;
            end 

            7'b0100011 : begin  // S-type : SW
                o_ALUOp = 3'b010;
            end

            7'b1100011 : begin  // SB-type : BEQ
                o_ALUOp = 3'b011;
            end

            7'b1101111 : begin  // UJ-type : JAL  
                o_ALUOp = 3'b100;
            end

            default : begin   
                o_ALUOp = 3'b111;
            end

        endcase
    end
endmodule

module ALU_control (i_ALUOp, i_funct3, i_funct7, o_ALU_control);
    input [2:0] i_ALUOp;
    input [2:0] i_funct3;
    input [6:0] i_funct7;
    output reg [3:0] o_ALU_control;

    always @(*) begin
        case(i_ALUOp)

            3'b000 : begin   // R-type 
                case(i_funct3)
                    3'b000 : begin
                        case(i_funct7)
                            7'b0000000 : begin
                                o_ALU_control = 4'd0; // ALU: add
                            end

                            7'b0100000 : begin
                                o_ALU_control = 4'd1; // ALU: subtract
                            end

                            default : begin
                                o_ALU_control = 4'b1111;
                            end
                        endcase
                    end

                    3'b010: begin
                        o_ALU_control = 4'd4;  //ALU: SLT
                    end

                    3'b111 : begin
                        o_ALU_control = 4'd2;  // ALU: AND
                    end

                    3'b110 : begin
                        o_ALU_control = 4'd3;  // ALU: OR
                    end  

                    default : begin
                        o_ALU_control = 4'b1111;
                    end
                endcase
            end

            3'b010 : begin   // I-type: LW, JALR  S-type: SW -> ALU: add
                o_ALU_control = 4'd0;
            end

            3'b011 : begin   // SB-type -> ALU: subtract 
                o_ALU_control = 4'd1;
            end

            3'b100 : begin   // UJ-type: JAL -> ALU: add
                o_ALU_control = 4'd0;
            end

            default : begin
                o_ALU_control = 4'b1111;
            end

        endcase
    end
endmodule

module Imm_Gen (i_inst, o_imm);
    input [31:0] i_inst;
    output reg [31:0] o_imm;

    always @(*) begin
        case(i_inst[6:0])
            7'b0100011 : begin  // S-type sw
                o_imm = {{20{i_inst[31]}}, i_inst[31:25], i_inst[11:7]};
            end

            7'b1101111 : begin  // UJ-type jal
                o_imm = {{11{i_inst[31]}},i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0};
            end

            7'b1100011 : begin  // SB-type branch
                o_imm = {{19{i_inst[31]}}, i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
            end

            7'b0000011 : begin  // I-type lw
                o_imm = {{20{i_inst[31]}}, i_inst[31:20]};
            end

            7'b1100111 : begin  // I-type jalr
                o_imm = {{20{i_inst[31]}}, i_inst[31:20]};
            end

            default : begin     // R-type
                o_imm = 32'b0;
            end
        endcase
    end
endmodule

module ALU (i_A, i_B, i_inst, o_data, o_zero);
    input  [31:0]   i_A;     // input operand A
    input  [31:0]   i_B;     // input operand B
    input  [3:0]    i_inst;  // instruction

    output reg [31:0] o_data;  // output value
    output o_zero;
    
    
    //operation modes
    parameter ADD  = 4'd0;
    parameter SUB  = 4'd1;
    parameter AND  = 4'd2;
    parameter OR   = 4'd3;
    parameter SLT  = 4'd4;

    assign o_zero = (i_A == i_B) ? 1'b1 : 1'b0; 

    always @(*) begin
        case(i_inst)
            ADD: begin
                o_data = $signed(i_A) + $signed(i_B);
            end

            SUB: begin
                o_data = $signed(i_A) - $signed(i_B);
            end

            AND: begin
                o_data = i_A & i_B;
            end

            OR: begin
                o_data = i_A | i_B;
            end

            SLT: begin
                o_data = ($signed(i_A) < $signed(i_B)) ? 32'b1 : 32'b0;
            end

            default: begin
                o_data = i_A;
            end
        endcase
    end
endmodule

module MUX2 (i_ctrl, i_0, i_1, o_data);
    input i_ctrl;
    input [31:0] i_0, i_1;
    output [31:0] o_data;

    assign o_data = i_ctrl ? i_1 : i_0;
endmodule

module MUX3 (i_ctrl, i_MEM_data, i_ALU_result, i_PC_plus_four, o_data);
    input [1:0] i_ctrl; //memtoreg
    input [31:0] i_MEM_data, i_ALU_result, i_PC_plus_four;
    output reg [31:0] o_data; //writedata

    always @(*) begin
        case(i_ctrl)  // i_ctrl[0]: LW  i_ctrl[1]: JAL JALR
            2'b00: begin //not lw or jal or jalr
                o_data = i_ALU_result;//alu output
            end

            2'b01: begin //lw
                o_data = i_MEM_data;
            end

            2'b10: begin //jal or jalr
                o_data = i_PC_plus_four;
            end

            default : begin
                o_data = i_ALU_result;
            end
        endcase
    end
endmodule

module PC_Adder (i_one_hot_control, i_PC, i_offset, rs1, o_PC_nxt_temp);
    input [3:0] i_one_hot_control;  //{Branch, o_zero, Jump_JALR, Jump_JAL}
    input [31:0] i_PC, i_offset, rs1;
    output reg [31:0] o_PC_nxt_temp;

    wire jal, jalr;
    wire zero;
    wire branch;

    assign jal = i_one_hot_control[0];
    assign jalr = i_one_hot_control[1];
    assign zero = i_one_hot_control[2];
    assign branch = i_one_hot_control[3];

    always@(*)begin
        if (jal) begin
            o_PC_nxt_temp = i_PC + i_offset;
        end else if (jalr) begin
            o_PC_nxt_temp = rs1 + i_offset;
        end else if (branch) begin
            if (zero == 1'b1) begin
                o_PC_nxt_temp = i_PC + i_offset;
            end else begin
                o_PC_nxt_temp = i_PC + 32'd4;
            end
        end else begin
            o_PC_nxt_temp = i_PC + 32'd4;
        end
    end
endmodule
