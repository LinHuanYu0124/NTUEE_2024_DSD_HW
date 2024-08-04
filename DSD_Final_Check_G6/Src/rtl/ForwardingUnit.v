module FordwardingUnit 
(
    MEM_RegWrite_i,
    MEM_RegDest_i,
    WB_RegWrite_i,
    WB_RegDest_i,
    EX_RegWrite_i,
    EX_RegDest_i,
    ID_RegSrc1_i,
    ID_RegSrc2_i,
    EX_RegSrc1_i,
    EX_RegSrc2_i,
    ID_ForwardA_o,
    ID_ForwardB_o,
    EX_ForwardA_o,
    EX_ForwardB_o
);

    input MEM_RegWrite_i, WB_RegWrite_i, EX_RegWrite_i;
    input [4:0] MEM_RegDest_i, WB_RegDest_i, EX_RegDest_i, ID_RegSrc1_i, ID_RegSrc2_i, EX_RegSrc1_i, EX_RegSrc2_i;
    output [1:0] ID_ForwardA_o, ID_ForwardB_o, EX_ForwardA_o, EX_ForwardB_o;

    reg [1:0] ID_ForwardA_r, ID_ForwardB_r, EX_ForwardA_r, EX_ForwardB_r;

    assign EX_ForwardA_o = EX_ForwardA_r;
    assign EX_ForwardB_o = EX_ForwardB_r;
    assign ID_ForwardA_o = ID_ForwardA_r;
    assign ID_ForwardB_o = ID_ForwardB_r;

    always @(*) begin
        EX_ForwardA_r = 2'b00;

        if (MEM_RegWrite_i & (MEM_RegDest_i != 0) & (MEM_RegDest_i == EX_RegSrc1_i)) begin
            EX_ForwardA_r = 2'b10; 
        end else if (WB_RegWrite_i & (WB_RegDest_i != 0) & (WB_RegDest_i == EX_RegSrc1_i)) begin
            EX_ForwardA_r = 2'b01;
        end

        EX_ForwardB_r = 2'b00;

        if (MEM_RegWrite_i & (MEM_RegDest_i != 0) & (MEM_RegDest_i == EX_RegSrc2_i)) begin
            EX_ForwardB_r = 2'b10; 
        end else if (WB_RegWrite_i & (WB_RegDest_i != 0) & (WB_RegDest_i == EX_RegSrc2_i)) begin
            EX_ForwardB_r = 2'b01;
        end

        ID_ForwardA_r = 2'b00;

        if (EX_RegWrite_i & (EX_RegDest_i != 0) & (EX_RegDest_i == ID_RegSrc1_i)) begin
            ID_ForwardA_r = 2'b10; 
        end else if (MEM_RegWrite_i & (MEM_RegDest_i != 0) & (MEM_RegDest_i == ID_RegSrc1_i)) begin
            ID_ForwardA_r = 2'b01;
        end

        ID_ForwardB_r = 2'b00;

        if (EX_RegWrite_i & (EX_RegDest_i != 0) & (EX_RegDest_i == ID_RegSrc2_i)) begin
            ID_ForwardB_r = 2'b10; 
        end else if (MEM_RegWrite_i & (MEM_RegDest_i != 0) & (MEM_RegDest_i == ID_RegSrc2_i)) begin
            ID_ForwardB_r = 2'b01;
        end
    end

endmodule
