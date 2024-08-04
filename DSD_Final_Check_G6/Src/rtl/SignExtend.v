module Sign_Extend (
    In_i,
    Out_o
);

    input   [31:0]  In_i;
    output  [31:0]  Out_o;

    reg [31:0] imm;
    assign Out_o = imm;
        
    always @(*) begin
        case(In_i[6:0])
            7'b0100011 : begin  // S-type SW
                imm = {{20{In_i[31]}}, In_i[31:25], In_i[11:7]};
            end

            7'b1101111 : begin  // UJ-type JAL
                imm = {{11{In_i[31]}},In_i[31], In_i[19:12], In_i[20], In_i[30:21], 1'b0};
            end

            7'b1100011 : begin  // SB-type BEQ, BNE
                imm = {{19{In_i[31]}}, In_i[31], In_i[7], In_i[30:25], In_i[11:8], 1'b0};
            end

            7'b0000011 : begin  // I-type LW, ADDI, ANDI, ORI, XORI, SLTI, 
                imm = {{20{In_i[31]}}, In_i[31:20]};
            end

            7'b0010011 : begin  // I-type ADDI, ANDI, ORI, XORI, SLTI
                imm = {{20{In_i[31]}}, In_i[31:20]};
            end

            7'b1100111 : begin  // I-type JALR
                imm = {{20{In_i[31]}}, In_i[31:20]};
            end

            default : begin     // R-type
                imm = 32'b0;
            end
        endcase
    end
endmodule