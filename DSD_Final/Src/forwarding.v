module Forwarding(
    input           EX_reg_write_i,
    input   [4:0]   EX_rd_i,
    input           ME_reg_write_i,
    input   [4:0]   ME_rd_i,
    input           WB_reg_write_i,
    input   [4:0]   WB_rd_i,

    input   [4:0]   ID_rs1_i,
    input   [4:0]   ID_rs2_i,

    input   [4:0]   EX_rs1_i,
    input   [4:0]   EX_rs2_i,

    output  [1:0]   EX_forward_1_o,
    output  [1:0]   EX_forward_2_o,
    output  [1:0]   ID_forward_1_o,
    output  [1:0]   ID_forward_2_o,

    output          forward_stall_o
);

    wire ME_flag, WB_flag, EX_flag;

    assign ME_flag = (ME_reg_write_i && ME_rd_i != 0);
    assign WB_flag = (WB_reg_write_i && WB_rd_i != 0);
    assign EX_flag = (EX_reg_write_i && EX_rd_i != 0);

    assign EX_forward_1_o[1] = (ME_flag && (ME_rd_i == EX_rs1_i));
    assign EX_forward_1_o[0] = (WB_flag && (WB_rd_i == EX_rs1_i));

    assign EX_forward_2_o[1] = (ME_flag && (ME_rd_i == EX_rs2_i));
    assign EX_forward_2_o[0] = (WB_flag && (WB_rd_i == EX_rs2_i));


    assign ID_forward_1_o[1] = (ME_flag && (ME_rd_i == ID_rs1_i));
    assign ID_forward_1_o[0] = (WB_flag && (WB_rd_i == ID_rs1_i));

    assign ID_forward_2_o[1] = (ME_flag && (ME_rd_i == ID_rs2_i));
    assign ID_forward_2_o[0] = (WB_flag && (WB_rd_i == ID_rs2_i));

    assign forward_stall_o = EX_flag && ((EX_rd_i == ID_rs1_i) | (EX_rd_i == ID_rs2_i));


endmodule