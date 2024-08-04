module ID_comparator(
    RS1data_i,
    RS2data_i,
    ID_Branch_i,
    func3_i,
    Branch_o
);
    input [31:0] RS1data_i, RS2data_i;
    input ID_Branch_i;
    input func3_i;
    output Branch_o;

    wire BNE, BEQ;
    assign BNE = (ID_Branch_i) & func3_i & (RS1data_i != RS2data_i);
    assign BEQ = (ID_Branch_i) & !func3_i & (RS1data_i == RS2data_i);

    assign Branch_o = BEQ | BNE;
endmodule