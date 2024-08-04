module Control (
    opcode_i,
    NoOp_i,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    Branch_o,
    Jump_JALR_o,
    Jump_JAL_o
);

    // Ports
    input   [6:0]   opcode_i;
    input           NoOp_i;

    output          RegWrite_o;
    output  [1:0]   MemtoReg_o;
    output          MemRead_o;
    output          MemWrite_o;
    output  [2:0]   ALUOp_o;
    output          ALUSrc_o;
    output          Branch_o;
    output          Jump_JALR_o;
    output          Jump_JAL_o;

    wire             RegWrite_r;
    wire     [1:0]   MemtoReg_r;
    wire             MemRead_r;
    wire             MemWrite_r;
    reg     [2:0]   ALUOp_r;
    wire             ALUSrc_r;
    wire             Branch_r;
    wire             Jump_JALR_r;
    wire             Jump_JAL_r;

    assign RegWrite_o = NoOp_i ? 1'b0: RegWrite_r;
    assign MemtoReg_o = NoOp_i ? 2'b0: MemtoReg_r;
    assign MemRead_o = NoOp_i ? 1'b0: MemRead_r;
    assign MemWrite_o = NoOp_i ? 1'b0: MemWrite_r;
    assign ALUOp_o = NoOp_i ? 3'b0: ALUOp_r;
    assign ALUSrc_o = NoOp_i ? 1'b0: ALUSrc_r;
    assign Branch_o = NoOp_i ? 1'b0: Branch_r;
    assign Jump_JALR_o = NoOp_i ? 1'b0: Jump_JALR_r;
    assign Jump_JAL_o = NoOp_i ? 1'b0: Jump_JAL_r;

    assign MemRead_r = (opcode_i == 7'b0000011) ? 1'b1 : 1'b0; // lw
    assign MemtoReg_r[0] = (opcode_i == 7'b0000011) ? 1'b1 : 1'b0; // lw
    assign MemtoReg_r[1] = (opcode_i == 7'b1101111 || opcode_i == 7'b1100111) ? 1'b1 : 1'b0; // jal || jalr
    assign MemWrite_r = (opcode_i == 7'b0100011) ? 1'b1 : 1'b0; // sw
    assign ALUSrc_r = (opcode_i == 7'b0000011 || opcode_i == 7'b1100111 || opcode_i == 7'b1101111 || opcode_i == 7'b0100011 || opcode_i == 7'b0010011) ? 1'b1 : 1'b0; // lw || jalr || jal || sw || SLLI || SRAI || SRLI
    assign RegWrite_r = (opcode_i != 7'b0100011 && opcode_i != 7'b1100011) ? 1'b1 : 1'b0; // !sw & !branch
    assign Branch_r = (opcode_i == 7'b1100011) ? 1'b1 : 1'd0; // branch
    assign Jump_JALR_r = (opcode_i == 7'b1100111) ? 1'b1 : 1'b0; // jalr
    assign Jump_JAL_r = (opcode_i == 7'b1101111) ? 1'b1 : 1'b0; // jal


    always @(*) begin
        case(opcode_i) // synopsys full_case

            7'b0110011 : begin  // R-type : ADD, SUB, OR, SLT, AND, XOR, SLT 
                ALUOp_r = 3'b000;
            end

            7'b1100111 : begin  // I-type : JALR
                ALUOp_r = 3'b001;
            end 

            7'b0000011 : begin  // I-type : LW
                ALUOp_r = 3'b001;
            end 

            7'b0010011 : begin  // I-type ADDI, ANDI, OR, XORI, SLLI, SRAI, SRLI, SLTI
                ALUOp_r = 3'b001;
            end

            7'b0100011 : begin  // S-type : SW
                ALUOp_r = 3'b001;
            end


            7'b1101111 : begin  // UJ-type : JAL  
                ALUOp_r = 3'b011;
            end

        endcase
    end
    
endmodule