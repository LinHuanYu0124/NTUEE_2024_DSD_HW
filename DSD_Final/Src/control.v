module Control(
    input   [31:0]  inst_i,
    output  [3:0]   aluop_o,
    output          alusrc_o,
    output          beq_o,
    output          bne_o,
    output          jal_o,
    output          jalr_o,
    output          mem_read_o,
    output          mem_write_o,
    output          reg_write_o,
    output          mul_o
);

    wire branch;
    assign branch = inst_i[6] & !inst_i[2];

    // alu control
    assign aluop_o[3] = inst_i[14];
    assign aluop_o[2] = inst_i[13] & inst_i[4];
    assign aluop_o[1] = inst_i[12];
    assign aluop_o[0] = inst_i[30] & (inst_i[14:12] == 3'b101 | alusrc_o);

    assign alusrc_o = (inst_i[5:4] == 2'b11) ? 1'b1 : 1'b0; // rtype -> choose rs2, else -> choose imm
    assign beq_o = branch & !inst_i[12];
    assign bne_o = branch & inst_i[12];
    assign jal_o = inst_i[3];
    assign jalr_o = inst_i[2] & !inst_i[3];
    assign mem_read_o = !inst_i[5] & !inst_i[4];
    assign mem_write_o = (inst_i[6:4] == 3'b010);
    assign reg_write_o = !(inst_i[5] & !inst_i[4] & !inst_i[2]);
    assign mul_o = inst_i[25] & (inst_i[5:4] == 2'b11);

/* operations
        30 |14 |13 |12 | 5 | 4 | aluop_o
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