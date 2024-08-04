module Forward(
    EX_reg_write,
    EX_rd,
    ME_reg_write,
    ME_rd,
    WB_reg_write,
    WB_rd,
    ID_rs1,
    ID_rs2,
    EX_rs1,
    EX_rs2,
    forward_a,
    forward_b,
    forward_c,
    forward_d,
    forward_stall
);

input            EX_reg_write, ME_reg_write, WB_reg_write;
input      [4:0] EX_rd,        ME_rd,        WB_rd;
input      [4:0] ID_rs1, ID_rs2, EX_rs1, EX_rs2;
output reg [1:0] forward_a, forward_b, forward_c, forward_d;
output reg forward_stall;

reg flag_1, flag_2, flag_3, flag_4;
always @(*) begin
    forward_a = 2'b00;
    forward_b = 2'b00;
    forward_c = 2'b00;
    forward_d = 2'b00;

    flag_1 = (ME_reg_write && ME_rd!=0);
    flag_2 = (WB_reg_write && WB_rd!=0);
    flag_3 = (EX_reg_write && EX_rd!=0);


    forward_stall = flag_3 && (EX_rd==ID_rs1 | EX_rd==ID_rs2);
    

    // if     (ME_reg_write && ME_rd!=0) begin
    //     forward_a[1] = ME_rd==EX_rs1;
    //     forward_b[1] = ME_rd==EX_rs2;
    //     // forward_c[1] = ME_rd==ID_rs1;
    //     // forward_d[1] = ME_rd==ID_rs2;
    // end
    // else if (WB_reg_write && WB_rd!=0) begin
    //     forward_a[0] = WB_rd==EX_rs1;
    //     forward_b[0] = WB_rd==EX_rs2;
    //     // forward_c[0] = WB_rd==ID_rs1;
    //     // forward_d[0] = WB_rd==ID_rs2;
    // end

    // // else if (EX_reg_write && EX_rd!=0) begin
    // //     if (EX_rd==ID_rs1) begin
    // //         // flag_c = 1;
    // //         forward_c = 2'b11;
    // //     end
    // //     if (EX_rd==ID_rs2) begin
    // //         // flag_d = 1;
    // //         forward_d = 2'b11;
    // //     end
    // // end


    forward_a[1] = (flag_1 && ME_rd==EX_rs1);
    forward_a[0] = (flag_2 && WB_rd==EX_rs1);

    forward_b[1] = (flag_1 && ME_rd==EX_rs2);
    forward_b[0] = (flag_2 && WB_rd==EX_rs2);


    forward_c[1] = (flag_1 && ME_rd==ID_rs1);
    forward_c[0] = (flag_2 && WB_rd==ID_rs1);

    forward_d[1] = (flag_1 && ME_rd==ID_rs2);
    forward_d[0] = (flag_2 && WB_rd==ID_rs2);


    /*
    forward_c[1] = (flag_3 && EX_rd==ID_rs1) | (flag_1 && ME_rd==ID_rs1);
    forward_c[0] = (flag_3 && EX_rd==ID_rs1) | (flag_2 && WB_rd==ID_rs1 && !(flag_1 && ME_rd==ID_rs1));

    forward_d[1] = (flag_3 && EX_rd==ID_rs2) | (flag_1 && ME_rd==ID_rs2);
    forward_d[0] = (flag_3 && EX_rd==ID_rs2) | (flag_2 && WB_rd==ID_rs2 && !(flag_1 && ME_rd==ID_rs2));
    */
    
    // if     (flag_1 && ME_rd==EX_rs1) forward_a = 2'b10;
    // else if(flag_2 && WB_rd==EX_rs1) forward_a = 2'b01;
    // else forward_a = 2'b00;

    // //forward_b
    // if     (flag_1 && ME_rd==EX_rs2) forward_b = 2'b10;
    // else if(flag_2 && WB_rd==EX_rs2) forward_b = 2'b01;
    // else forward_b = 2'b00;

    // //forward_c
    // if     (flag_1 && ME_rd==ID_rs1) forward_c = 2'b10;
    // else if(flag_2 && WB_rd==ID_rs1) forward_c = 2'b01;
    // else if(flag_3 && EX_rd==ID_rs1) forward_c = 2'b11;
    // else forward_c = 2'b00;

    // //forward_d
    // if     (flag_1 && ME_rd==ID_rs2) forward_d = 2'b10;
    // else if(flag_2 && WB_rd==ID_rs2) forward_d = 2'b01;
    // else if(flag_3 && EX_rd==ID_rs2) forward_d = 2'b11;
    // else forward_d = 2'b00;




    // //forward_a
    // if     (ME_reg_write==1'b1 && ME_rd!=0 && ME_rd==EX_rs1) forward_a = 2'b10;
    // else if(WB_reg_write==1'b1 && WB_rd!=0 && WB_rd==EX_rs1) forward_a = 2'b01;
    // else forward_a = 2'b00;

    // //forward_b
    // if     (ME_reg_write==1'b1 && ME_rd!=0 && ME_rd==EX_rs2) forward_b = 2'b10;
    // else if(WB_reg_write==1'b1 && WB_rd!=0 && WB_rd==EX_rs2) forward_b = 2'b01;
    // else forward_b = 2'b00;

    // //forward_c
    // if     (ME_reg_write==1'b1 && ME_rd!=0 && ME_rd==ID_rs1) forward_c = 2'b10;
    // else if(WB_reg_write==1'b1 && WB_rd!=0 && WB_rd==ID_rs1) forward_c = 2'b01;
    // else if(EX_reg_write==1'b1 && EX_rd!=0 && EX_rd==ID_rs1) forward_c = 2'b11;
    // else forward_c = 2'b00;

    // //forward_d
    // if     (ME_reg_write==1'b1 && ME_rd!=0 && ME_rd==ID_rs2) forward_d = 2'b10;
    // else if(WB_reg_write==1'b1 && WB_rd!=0 && WB_rd==ID_rs2) forward_d = 2'b01;
    // else if(EX_reg_write==1'b1 && EX_rd!=0 && EX_rd==ID_rs2) forward_d = 2'b11;
    // else forward_d = 2'b00;


end



endmodule