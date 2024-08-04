module CHIP(clk,
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

//  ========== reg / wire ==========
    
    // ======== Input Buffer ========
    wire [31:0] mem_rdata_D_layout;
    wire [31:0] mem_rdata_I_layout;

    // ========== Control ==========
    wire     [6:0]      Opcode;
    wire     [2:0]      ALUOp;
    wire                ALUSrc;
    wire                RegWrite;
    wire     [1:0]      MemtoReg;
    wire                MemRead;
    wire                MemWrite;
    wire                Branch;
    wire                Jal;
    wire                Jalr;

    // ========= Registers =========
    wire     [4:0]      _oaddr;
    wire     [4:0]      RS1addr;
    wire     [4:0]      RS2addr;
    wire     [4:0]      RDaddr;
    wire     [31:0]     RDdata;
    wire     [31:0]     RS1data;
    wire     [31:0]     RS2data;
    wire     [4:0]      MEM_WB_RDaddr;
    
    // ========== Imm Gen ==========
    wire     [31:0]     Imm_i;
    wire     [31:0]     Imm_o;

    // ============ ALU ============
    wire     [3:0]      ALUCtrl;
    wire     [31:0]     ALUdata_i;
    wire     [31:0]     ALUdata_o;
    wire     [31:0]     data;
    wire                zero;

    wire     [9:0]      funct;

    // ====== Forwarding Unit ======
    wire     [31:0]     ForwardAdata;

    wire     [3:0]      one_hot_control;         

    // ======= Output Buffer =======
    reg [31:0] PC_r;
    reg [31:0] PC_w;

    wire     [31:0]     PC_result;

// =========== assign ===========
    assign Opcode           = mem_rdata_I_layout[6:0];
    assign RS1addr          = mem_rdata_I_layout[19:15];
    assign RS2addr          = mem_rdata_I_layout[24:20];
    assign MEM_WB_RDaddr    = mem_rdata_I_layout[11:7];

    assign funct            = {mem_rdata_I_layout[31:25],mem_rdata_I_layout[14:12]};

    assign Imm_i            = mem_rdata_I_layout;

    assign mem_rdata_D_layout = {mem_rdata_D[7:0], mem_rdata_D[15:8], mem_rdata_D[23:16], mem_rdata_D[31:24]};
    assign mem_rdata_I_layout = {mem_rdata_I[7:0], mem_rdata_I[15:8], mem_rdata_I[23:16], mem_rdata_I[31:24]};

    assign one_hot_control   = {Branch, zero, Jalr, Jal};

    assign mem_addr_I = PC_r;
    assign mem_addr_D = data;
    assign mem_wdata_D = {RS2data[7:0], RS2data[15:8], RS2data[23:16], RS2data[31:24]};                                    
    assign mem_wen_D = MemWrite;


    Register Register(
        .clk         (clk),
        .rst_n       (rst_n),

        .RS1addr_i   (RS1addr),
        .RS2addr_i   (RS2addr),
        .RDaddr_i    (MEM_WB_RDaddr),
        .RegWrite_i  (RegWrite),
        .RDdata_i    (RDdata),

        .RS1data_o   (RS1data),
        .RS2data_o   (RS2data)
    );

    Control Control(
        .Op_i       (Opcode),

        .ALUOp_o    (ALUOp),
        .ALUSrc_o   (ALUSrc),
        .RegWrite_o (RegWrite),
        .MemtoReg_o (MemtoReg),
        .MemRead_o  (MemRead),
        .MemWrite_o (MemWrite),
        .Branch_o   (Branch),
        .Jal_o      (Jal),
        .Jalr_o     (Jalr)
    );

    Imm_Gen Imm_Gen(
        .Imm_i(Imm_i),
        .Imm_o(Imm_o)
    );

    ALU_Control ALU_Control(
        .ALUOp_i    (ALUOp),
        .funct_i    (funct),
        .ALUCtrl_o  (ALUCtrl)
    );


    Adder PC_Add(
        .one_hot_control_i   (one_hot_control),
        .PC_i                (PC_r),
        .offest_i            (Imm_o),
        .rs1_o               (RS1data),
        .PC_next_temp_o      (PC_result)
    );

    MUX2 MUX2_ALUSrc(
        .select_i(ALUSrc),
        .data1_i(RS2data),
        .data2_i(Imm_o),
        .data_o(ForwardAdata)
    );

    MUX3 MUX3_MemtoReg(
        .select_i(MemtoReg),
        .data1_i(data),
        .data2_i(mem_rdata_D_layout),
        .data3_i(PC_r+4),
        .data_o(RDdata)
    );

    ALU ALU(
        .data1_i    (RS1data),
        .data2_i    (ForwardAdata),
        .ALUCtrl_i  (ALUCtrl),
        .data_o     (data),
        .zero_o     (zero)
    );

    // =========== Combinational ===========
    always @(*) begin
        PC_w    =   PC_result;
    end

    // ============= Sequential =============
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC_r    <=  0;
        end
        else    begin
            PC_r    <=  PC_w;
        end
    end

endmodule


// Modules --------------------------------------------

module Control(
    Op_i,
    ALUOp_o,
    ALUSrc_o,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    Branch_o,
    Jal_o,
    Jalr_o
    );

    // Ports
    input   [6:0]       Op_i;
    output  [2:0]       ALUOp_o;
    output              ALUSrc_o;
    output              RegWrite_o;
    output  [1:0]       MemtoReg_o;
    output              MemRead_o;
    output              MemWrite_o;
    output              Branch_o;
    output              Jal_o;
    output              Jalr_o;


    assign MemRead_o     = (Op_i == 7'b0000011) ? 1'b1 : 1'b0; 
    assign MemtoReg_o[0] = (Op_i == 7'b0000011) ? 1'b1 : 1'b0; 
    assign MemtoReg_o[1] = (Op_i == 7'b1101111 || Op_i == 7'b1100111) ? 1'b1 : 1'b0;
    assign MemWrite_o    = (Op_i == 7'b0100011) ? 1'b1 : 1'b0; 

    assign ALUSrc_o = (Op_i == 7'b0000011 || 
                        Op_i == 7'b1100111 || 
                        Op_i == 7'b1101111 || 
                        Op_i == 7'b0100011) ? 1'b1 : 1'b0; 

    assign ALUOp_o =    (Op_i == 7'b0110011) ? 3'b000: 
                        (Op_i == 7'b1100111) ? 3'b010: 
                        (Op_i == 7'b0000011) ? 3'b010: 
                        (Op_i == 7'b0100011) ? 3'b010: 
                        (Op_i == 7'b1100011) ? 3'b011: 
                        (Op_i == 7'b1101111) ? 3'b100: 
                        3'b111;
    
    assign RegWrite_o    = (Op_i != 7'b0100011 && Op_i != 7'b1100011) ? 1'b1 : 1'b0;

    assign Branch_o      = (Op_i == 7'b1100011) ? 1'b1 : 1'b0;
    assign Jalr_o        = (Op_i == 7'b1100111) ? 1'b1 : 1'b0;
    assign Jal_o         = (Op_i == 7'b1101111) ? 1'b1 : 1'b0;

endmodule

module Register (
    clk,
    rst_n,
    RS1addr_i,
    RS2addr_i,
    RDaddr_i,
    RegWrite_i,
    RDdata_i,
    RS1data_o,
    RS2data_o
    );
    // Ports
    input           clk;
    input           rst_n;
    input           RegWrite_i;
    input  [4:0]    RS1addr_i;
    input  [4:0]    RS2addr_i;
    input  [4:0]    RDaddr_i;
    input  [31:0]   RDdata_i;
    output [31:0]   RS1data_o;
    output [31:0]   RS2data_o;

    //Reg
    reg [31:0] mem_r [0:31]; 
    reg [31:0] mem_w [0:31]; 

    assign RS1data_o = mem_r[RS1addr_i];
    assign RS2data_o = mem_r[RS2addr_i];

    integer i;

    always @(*) begin
        for (i = 0; i < 31; i = i + 1) begin
            mem_w[i] = (RegWrite_i && (RDaddr_i == i)) ? RDdata_i : mem_r[i];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_r[0] <= 0;
            for (i = 1; i < 31; i = i + 1) begin
                if (i == 32'd2) begin
                    mem_r[i] <= 32'hbffffff0;
                end
                else if (i == 32'd3) begin
                    mem_r[i] <= 32'h10008000;
                end
                else begin
                    mem_r[i] <= 32'h0;
                end
            end
        end
        else begin
            mem_r[0] <= 0;
            for (i = 1;i < 31 ; i = i + 1) begin
                mem_r[i] <= mem_w[i];
            end
        end
    end
    
endmodule


module ALU(
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o,
    zero_o
    );

    // Ports
    input      [31:0]       data1_i;
    input      [31:0]       data2_i;
    input      [3:0]        ALUCtrl_i;

    output reg [31:0]       data_o;
    output                  zero_o;

    assign zero_o = (data1_i == data2_i) ? 1'b1 : 1'b0;     

    always @(*) begin
        case(ALUCtrl_i)
            0: begin
                data_o = $signed(data1_i) + $signed(data2_i);
            end

            1: begin
                data_o = $signed(data1_i) - $signed(data2_i);
            end

            2: begin
                data_o = data1_i & data2_i;
            end

            3: begin
                data_o = data1_i | data2_i;
            end

            4: begin
                data_o = ($signed(data1_i) < $signed(data2_i)) ? 32'b1 : 32'b0;
            end

            default: begin
                data_o = data1_i;
            end
        endcase
    end

endmodule

module ALU_Control(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
    );

    // Ports
    input       [9:0]   funct_i;
    input       [2:0]   ALUOp_i;
    output  reg [3:0]   ALUCtrl_o;

    wire [2:0] funct3;
    wire [6:0] funct7;

    assign funct3 = funct_i[2:0];
    assign funct7 = funct_i[9:3];

    always @(*) begin
        case (ALUOp_i)
            3'b000 : begin  
                if (funct3 == 3'b000) begin
                    if (funct7 == 7'b0000000) begin
                        ALUCtrl_o = 4'd0;
                    end
                    else if (funct7 == 7'b0100000) begin
                        ALUCtrl_o = 4'd1;
                    end
                    else begin
                        ALUCtrl_o = 4'b1111;
                    end
                end
                else if (funct3 == 3'b010) begin
                    ALUCtrl_o = 4'd4;
                end
                else if (funct3 == 3'b111) begin
                    ALUCtrl_o = 4'd2;
                end
                else if (funct3 == 3'b110) begin
                    ALUCtrl_o = 4'd3;
                end
                else begin
                    ALUCtrl_o = 4'b1111;
                end
            end

            3'b010 : begin  
                ALUCtrl_o = 4'd0;
            end

            3'b011 : begin 
                ALUCtrl_o = 4'd1;
            end

            3'b100 : begin
                ALUCtrl_o = 4'd0;
            end

            default : begin
                ALUCtrl_o = 4'b1111;
            end

        endcase
    end

endmodule

module MUX2(
    data1_i,
    data2_i,
    select_i,
    data_o
    );

    // Ports
    input   [31:0]       data1_i;
    input   [31:0]       data2_i;
    input                select_i;
    output  [31:0]       data_o;

    assign data_o = (select_i == 1'b0) ? data1_i : data2_i;

endmodule

module MUX3(
    data1_i,
    data2_i,
    data3_i,
    select_i,
    data_o
    );

    // Ports
    input   [31:0]       data1_i;   //  ALU_result
    input   [31:0]       data2_i;   //  MEM_data
    input   [31:0]       data3_i;   //  PC_plus_four
    input   [1:0]        select_i;
    output  [31:0]       data_o;

    assign data_o = (select_i == 2'b00) ? data1_i : 
                    (select_i == 2'b01) ? data2_i : 
                    (select_i == 2'b10) ? data3_i : 
                    data1_i;

endmodule


module Adder (
    one_hot_control_i,
    PC_i,
    offest_i,
    rs1_o,
    PC_next_temp_o
    );

    //Port
    input [3:0] one_hot_control_i;
    input [31:0] PC_i, offest_i, rs1_o;
    output reg [31:0] PC_next_temp_o;

    always@(*)begin
        if (one_hot_control_i[0]) begin
            PC_next_temp_o = PC_i + offest_i;
        end 
        else if (one_hot_control_i[1]) begin
            PC_next_temp_o = rs1_o + offest_i;
        end 
        else if (one_hot_control_i[3]) begin
            if (one_hot_control_i[2] == 1'b1) begin
                PC_next_temp_o = PC_i + offest_i;
            end 
            else begin
                PC_next_temp_o = PC_i + 32'd4;
            end
        end 
        else begin
            PC_next_temp_o = PC_i + 32'd4;
        end
    end
    
endmodule

module Imm_Gen (
    Imm_i, Imm_o
    );
    
    //Port
    input [31:0] Imm_i;
    output reg [31:0] Imm_o;

    always @(*) begin
        if (Imm_i[6:0] == 7'b0100011) begin
            Imm_o = {{20{Imm_i[31]}}, Imm_i[31:25], Imm_i[11:7]};
        end
        else if (Imm_i[6:0] == 7'b1101111) begin
            Imm_o = {{11{Imm_i[31]}},Imm_i[31], Imm_i[19:12], Imm_i[20], Imm_i[30:21], 1'b0};
        end
        else if (Imm_i[6:0] == 7'b1100011) begin
            Imm_o = {{19{Imm_i[31]}}, Imm_i[31], Imm_i[7], Imm_i[30:25], Imm_i[11:8], 1'b0};
        end
        else if (Imm_i[6:0] == 7'b0000011 || Imm_i[6:0] == 7'b1100111) begin
            Imm_o = {{20{Imm_i[31]}}, Imm_i[31:20]};
        end
        else begin
            Imm_o = 32'b0;
        end
    end
endmodule