module Control(
    inst,
    aluop,
    alusrc,
    beq,
    bne,
    jal,
    jalr,
    mem_read,
    mem_write,
    reg_write
    // mem_to_reg
);

input [31:0] inst;
output [3:0] aluop;
output alusrc;
output reg beq;
output reg bne;
output reg jal;
output reg jalr;
output reg mem_read;
output reg mem_write;
output reg reg_write;
// output reg mem_to_reg;


// wire [6:0] opcode;
// assign opcode = inst [6:0];

reg branch;
always@(*)begin
    jal = inst[3];
    jalr = inst[2] & !inst[3];
    mem_read = !inst[5] & !inst[4];
    mem_write = (inst[6:4] == 3'b010);
    branch = inst[6] & !inst[2];
    beq = branch & !inst[12];
    bne = branch & inst[12];
    // reg_write = !(branch | mem_write);
    reg_write = !(inst[5] & !inst[4] & !inst[2]);


    /*
    case(inst[6:2])
        5'b01100 : begin  // r-type (add/sub/and/or/xor/slt)
            beq = 1'b0;
            bne = 1'b0;
            jal = 1'b0;
            jalr = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 1'b0;
        end  
        5'b00100 : begin  // i-type (addi/andi/ori/xori/slli/srai/srli/slti/nop)
            beq = 1'b0;
            bne = 1'b0;
            jal = 1'b0;
            jalr = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 1'b0;
        end 
        5'b00000 : begin  // i-type (lw)
            beq = 1'b0;
            bne = 1'b0;
            jal = 1'b0;
            jalr = 1'b0;
            mem_read = 1'b1;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 1'b1;
        end 
        5'b01000 : begin  // s-type (sw)
            beq = 1'b0;
            bne = 1'b0;
            jal = 1'b0;
            jalr = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b1;
            reg_write = 1'b0;
            mem_to_reg = 1'b0;
        end  
        5'b11000 : begin  // b-type (beq/bne)
            jal = 1'b0;
            jalr = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b0;
            mem_to_reg = 1'b0;
            if(inst[14:12]==3'b000) begin
                beq = 1'b1;
                bne = 1'b0;
            end
            else begin
                beq = 1'b0;
                bne = 1'b1;
            end
        end
        5'b11011 : begin  // j-type (jal)
            beq = 1'b0;
            bne = 1'b0;
            jal = 1'b1;
            jalr = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b1;
            // mem_to_reg = 1'b0;
        end  
        5'b11001 : begin  // i-type (jalr)
            beq = 1'b0;
            bne = 1'b0;
            jal = 1'b0;
            jalr = 1'b1;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b1;
            mem_to_reg = 1'b0;
        end  
        default : begin
            beq = 1'b0;
            bne = 1'b0;
            jal = 1'b0;
            jalr = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            reg_write = 1'b0;
            mem_to_reg = 1'b0;
        end
        endcase

        */
end

// alu control
assign aluop[3] = inst[14];
assign aluop[2] = inst[13] & inst[4];
assign aluop[1] = inst[12];
assign aluop[0] = inst[30] & (inst[14:12] == 3'b101 | alusrc);
assign alusrc = (inst[5:4] == 2'b11) ? 1 : 0; // rtype -> choose rs2, else -> choose imm

/* operations
        30 |14 |13 |12 | 5 | 4 | aluop
lw       ?   0   1   0   0   0   0000
sw       ?   0   1   0   1   0   0000
addi     ?   0   0   0   0   1   0000
slli     ?   0   0   1   0   1   0010
slti     ?   0   1   0   0   1   0100
xori     ?   1   0   0   0   1   1000
srli     0   1   0   1   0   1   1010
srai     1   1   0   1   0   1   1011 
ori      ?   1   1   0   0   1   1100
andi     ?   1   1   1   0   1   1110
add      0   0   0   0   1   1   0000
sub      1   0   0   0   1   1   0001
slt      0   0   1   0   1   1   0100
xor      0   1   0   0   1   1   1000
or       0   1   1   0   1   1   1100
and      0   1   1   1   1   1   1110
*/

endmodule