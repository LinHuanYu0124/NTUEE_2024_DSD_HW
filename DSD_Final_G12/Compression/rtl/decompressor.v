module Decompressor (
    inst_in,
    inst_out
);
      
input  [31:0] inst_in;
output [31:0] inst_out;

reg    [31:0] decompressed;
reg     [1:0] op;
reg     [2:0] funct3, f3;
reg     [4:0] rs1, rs2, rd;

//decompressor

assign inst_out = decompressed;

always@(*)begin
    op = inst_in[1:0];
    funct3 = inst_in[15:13];
end

always@(*)begin
    case(op)
        2'd0: begin
            rs1 = {2'b01,inst_in[9:7]};
            rs2 = {2'b01,inst_in[4:2]};
            rd =  {2'b01,inst_in[4:2]};;
            f3 = 3'd2;
            if(funct3[2]) // C.SW
                decompressed = {5'd0,inst_in[5],inst_in[12],rs2,rs1,f3,inst_in[11:10],inst_in[6],2'd0,7'd35};
            else // C.LW
                decompressed = {5'd0,inst_in[5],inst_in[12:10],inst_in[6],2'd0,rs1,f3,rd,7'd3};

        end

        2'd1: begin
            rs1 = inst_in[11:7];
            rs2 = inst_in[11:7];
            rd  = inst_in[11:7];
            f3  = funct3;
            case(funct3[1:0])
                2'd0: begin // NOP ADDI ANDI SRLI SRAI
                    if(funct3[2]) begin
                        rs1 = {2'b01,inst_in[9:7]};
                        rs2 = {2'b01,inst_in[9:7]};
                        rd  = {2'b01,inst_in[9:7]};
                        f3  = {1'b1, inst_in[11], 1'b1};
                        if(inst_in[11]) 
                            decompressed = {{7{inst_in[12]}},inst_in[6:2],rs1, f3 ,rd,7'd19};
                        else
                            decompressed = {inst_in[11:10], 5'd0, inst_in[6:2], rs1, f3, rd,7'd19};
                    end
                    else begin
                        rs1 = inst_in[11:7];
                        rs2 = inst_in[11:7];
                        rd  = inst_in[11:7];
                        f3  = funct3;
                        decompressed = {{7{inst_in[12]}},inst_in[6:2],rs1,3'b000,rd,7'd19};
                    end
                    
                end
                2'd1: begin//C.JAL & J
                    rd = {4'd0, ~funct3[2]};
                    decompressed = {inst_in[12],inst_in[8],inst_in[10:9],inst_in[6],inst_in[7],inst_in[2],inst_in[11],inst_in[5:3],{9{inst_in[12]}},rd,7'd111};
                end
                default: begin // C.BEQZ & BNEZ
                    rs1 = {2'b01, inst_in[9:7]};
                    f3 = {2'd0, funct3[0]};
                    decompressed = {{4{inst_in[12]}},inst_in[6:5],inst_in[2],5'd0,rs1,f3,inst_in[11:10],inst_in[4:3],inst_in[12],7'd99};
                end
            endcase
        end

        2'd2: begin
            rs1 = inst_in[11:7];
            rs2 = inst_in[6:2];
            rd = inst_in[11:7];
            f3 = {2'd0, ~funct3[2]};
            if(funct3[2] == 0) // C.SLLI
                decompressed = {7'd0,inst_in[12],inst_in[6:2],rs1,f3,rd,7'd19};
            else if(rs2 == 5'd0) // C.JALR & JR
                decompressed = {12'd0,rs1,f3,4'd0,inst_in[12],7'd103};
            else begin // C.ADD & MV
                rs1 = inst_in[12] ? rd : 5'd0; 
                decompressed = {7'd0,rs2,rs1,f3,rd,7'd51};
            end
        end
        default: begin
            rs1 = 5'd0;
            rs2 = 5'd0;
            rd = 5'd0;
            f3 = 3'd0;
            decompressed = inst_in;
        end

    endcase
end

endmodule