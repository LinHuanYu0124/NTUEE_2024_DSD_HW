module ALU_Control (
    Funct7_i,
    Funct3_i,
    ALUOp_i,
    opcode_i,
    ALUSignal_o
);

    input [6:0] Funct7_i;
    input [2:0] Funct3_i;
    input [2:0] ALUOp_i;
    input  opcode_i;

    output [3:0] ALUSignal_o;

    localparam  ADD = 4'd0;
    localparam  SUB = 4'd1;
    localparam  AND = 4'd2;
    localparam  OR  = 4'd3;
    localparam  SLT = 4'd4;
    localparam  MUL = 4'd5;
    localparam  XOR = 4'd6;
    localparam  SL = 4'd7;
    localparam  SRA = 4'd8;
    localparam  SRL = 4'd9;

    reg [3:0] ALUSignal_r;

    assign ALUSignal_o = ALUSignal_r;

    always @(*) begin   
        case (ALUOp_i) // synopsys full_case
            3'b000: begin
                case ({ Funct7_i, Funct3_i }) // synopsys full_case
                    // R-type 
                    10'b0000000100: begin  // XOR, 
                        ALUSignal_r = XOR;
                    end

                    10'b0000000000: begin  // ADD, 
                        ALUSignal_r = ADD;
                    end

                    10'b0100000000: begin  // SUB, 
                        ALUSignal_r = SUB;
                    end

                    10'b0000001000: begin
                        ALUSignal_r = MUL;
                    end

                    10'b0000000111: begin  // AND, 
                        ALUSignal_r = AND;
                    end

                    10'b0000000110: begin  // OR
                        ALUSignal_r = OR;
                    end

                    10'b0000000010: begin
                        ALUSignal_r = SLT; // SLT, 
                    end
                endcase
            end

            3'b001: begin 
                case(Funct3_i) // synopsys full_case
                    3'b000: begin
                        ALUSignal_r = ADD;  // ADDI, JALR,
                    end

                    3'b010: begin
                        if (opcode_i) begin
                            ALUSignal_r = SLT;  // SLTI, 
                        end else begin
                            ALUSignal_r = ADD;  // LW, SW,
                        end
                    end

                    3'b101: begin
                        if (Funct7_i[5]) begin
                            ALUSignal_r = SRA; // SRAI, 
                        end else begin
                            ALUSignal_r = SRL; // SRLI, 
                        end
                    end

                    3'b111: begin
                        ALUSignal_r = AND;  // ANDI, 
                    end

                    3'b110: begin
                        ALUSignal_r = OR;   // ORI, 
                    end

                    3'b100: begin
                        ALUSignal_r = XOR;  // XORI,
                    end

                    3'b001: begin
                        ALUSignal_r = SL;   // SLLI,
                    end
                endcase
            end

            3'b011 : begin
                ALUSignal_r = ADD;  // JAL
            end
        endcase
    end
    
endmodule