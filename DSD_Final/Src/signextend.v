module Sign_Extend (
    input   [31:0]  inst_i,
    output  [31:0]  imm_o
);

    reg [31:0] imm;
    assign imm_o = imm;
        
    always @(*) begin
        if (inst_i[3]) begin
            imm = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
        end else if ((!inst_i[5] | inst_i[2])) begin
            imm = {{21{inst_i[31]}}, inst_i[30:20]};
        end else if ((inst_i[6])) begin
            imm = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
        end else begin
            imm = {{21{inst_i[31]}}, inst_i[30:25], inst_i[11:7]};
        end

        // case(inst_i[6:0])
        //     7'b0100011 : begin  // S-type SW
        //         imm_o = {{21{inst_i[31]}}, inst_i[30:25], inst_i[11:7]};
        //     end

        //     7'b1101111 : begin  // UJ-type JAL
        //         imm_o = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
        //     end

        //     7'b1100011 : begin  // SB-type BEQ, BNE
        //         imm_o = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
        //     end

        //     7'b0000011 : begin  // I-type LW, ADDI, ANDI, ORI, XORI, SLTI, 
        //         imm_o = {{21{inst_i[31]}}, inst_i[30:20]};
        //     end

        //     7'b0010011 : begin  // I-type ADDI, ANDI, ORI, XORI, SLTI
        //         imm_o = {{21{inst_i[31]}}, inst_i[30:20]};
        //     end

        //     7'b1100111 : begin  // I-type JALR
        //         imm_o = {{21{inst_i[31]}}, inst_i[30:20]};
        //     end

        //     default : begin     // R-type
        //         imm_o = 32'b0;
        //     end
        // endcase
    end
endmodule