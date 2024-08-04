module Decompressor (
    input   [31:0]  inst_i,
    output  [31:0]  inst_o,
    output          compress_o
);

    reg    [31:0] inst;

    wire     [1:0] c_op_code;
    wire     [2:0] c_func3;

    reg     [4:0] rs1, rs2, rd;

    assign inst_o = inst;
    assign compress_o = (c_op_code != 2'b11);

    assign c_op_code = inst_i[1:0];
    assign c_func3 = inst_i[15:13];

    always@(*)begin

        case(c_op_code)
            2'b00: begin
                rs1 = {2'b01,inst_i[9:7]};
                rs2 = {2'b01,inst_i[4:2]};
                rd =  {2'b01,inst_i[4:2]};

                if (c_func3[2]) begin // SW
                    inst = {5'd0, inst_i[5], inst_i[12], rs2, rs1, 3'b010, inst_i[11:10], inst_i[6], 2'b0, 7'b0100011};
                end else begin// LW
                    inst = {5'd0, inst_i[5], inst_i[12:10], inst_i[6], 2'b0, rs1, 3'b010, rd, 7'b0000011};
                end
            end

            2'b01: begin
                case(c_func3[1:0])
                    2'b00: begin
                        if(c_func3[2]) begin
                            rs1 = {2'b01,inst_i[9:7]};
                            rs2 = {2'b01,inst_i[9:7]};
                            rd  = {2'b01,inst_i[9:7]};

                            if(inst_i[11]) begin // ANDI 
                                inst = {{7{inst_i[12]}}, inst_i[6:2], rs1, 3'b111 ,rd, 7'b0010011};
                            end else begin // SRLI SRAI
                                inst = {inst_i[11:10], 4'd0, inst_i[12], inst_i[6:2], rs1, 3'b101, rd, 7'b0010011};
                            end
                        end else begin // Nc_op_code ADDI 
                            rs1 = inst_i[11:7];
                            rd  = inst_i[11:7];

                            inst = {{7{inst_i[12]}}, inst_i[6:2], rs1, 3'b000, rd, 7'b0010011};
                        end
                        
                    end

                    2'b01: begin//JAL J
                        rd = {4'd0, ~c_func3[2]};

                        inst = {inst_i[12], inst_i[8], inst_i[10:9], inst_i[6], inst_i[7], inst_i[2], inst_i[11], inst_i[5:3], {9{inst_i[12]}}, rd, 7'b1101111};
                    end

                    default: begin // BEQZ & BNEZ
                        rs1 = {2'b01, inst_i[9:7]};

                        inst = {{4{inst_i[12]}}, inst_i[6:5], inst_i[2], 5'd0, rs1, {2'd0, c_func3[0]}, inst_i[11:10], inst_i[4:3], inst_i[12], 7'b1100011};
                    end
                endcase
            end

            2'b10: begin
                rs1 = inst_i[11:7];
                rs2 = inst_i[6:2];
                rd = inst_i[11:7];

                if(c_func3[2] == 0) begin // SLLI
                    inst = {6'b0, inst_i[12], inst_i[6:2], rs1, {2'b0, ~c_func3[2]}, rd, 7'b0010011};
                end else begin
                    if (rs2 == 5'd0) begin // JALR & JR
                        rd = {4'd0, inst_i[12]};

                        inst = {12'd0, rs1, 3'b000, rd, 7'b1100111};
                    end else begin // ADD & MV
                        rs1 = inst_i[12] ? rd : 5'd0; 
                        
                        inst = {7'd0, rs2, rs1, 3'b000, rd, 7'b0110011};
                    end
                end
            end
            
            default: begin
                inst = inst_i;
            end

        endcase
    end

endmodule