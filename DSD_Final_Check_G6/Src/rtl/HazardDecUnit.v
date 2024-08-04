module Hazard_Detection
(
    EX_WriteRegDest_i,
    MEM_WriteRegDest_i,
    EX_MemRead_w,
    MEM_MemRead_w,
    ID_RegSrc1_i,
    ID_RegSrc2_i,
    ID_Branch_i,
    ID_inst_i,
    NoOp_o,
    IF_ID_Write_o,
    PCWrite_o
);

input [4:0] EX_WriteRegDest_i, MEM_WriteRegDest_i, ID_RegSrc1_i, ID_RegSrc2_i;
input EX_MemRead_w, MEM_MemRead_w;
input [6:0] ID_Branch_i;
input [31:0] ID_inst_i;
output NoOp_o, IF_ID_Write_o, PCWrite_o;

reg NoOp_r, IF_ID_Write_r, PCWrite_r;
wire EX_flush;

assign EX_flush = (EX_MemRead_w) & ((EX_WriteRegDest_i == ID_RegSrc1_i) | (EX_WriteRegDest_i == ID_RegSrc2_i));
// assign branch_flush = ((ID_Branch_i == 7'b1100011) & ((ID_inst_i[11:7] == ID_RegSrc1_i) | (ID_inst_i[11:7] == ID_RegSrc2_i)));

assign NoOp_o = NoOp_r;
assign IF_ID_Write_o = IF_ID_Write_r;
assign PCWrite_o = PCWrite_r;

always @(*) begin 
    if (EX_flush) begin
        NoOp_r = 1'b1;
        IF_ID_Write_r = 1'b0;
        PCWrite_r = 1'b0;
    end else begin
        NoOp_r = 1'b0;
        IF_ID_Write_r = 1'b1;
        PCWrite_r = 1'b1;
    end
end

endmodule