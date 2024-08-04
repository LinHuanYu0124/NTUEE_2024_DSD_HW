module MUL_TOP(
    clk,
    rst_n,
    A,
    B,
    Out
);

input clk, rst_n;
input [31:0] A;
input [31:0] B;
output [31:0] Out;

reg [31:0] p1_r;
reg [22:0] p2_r;
wire [31:0] p1_w;
wire [22:0] p2_w;
wire [31:0] mul_out;

assign Out = mul_out;

Wallace_MUL_32_p1 wallace_32_p1 (
    .A_i(A),
    .B_i(B),
    .partialSum0_o(p1_w),
    .partialSum1_o(p2_w)
);

Wallace_MUL_32_p2 wallace_32_p2 (
    .partialSum0_i(p1_r),
    .partialSum1_i(p2_r),
    .Out_o(mul_out)
);

always @(posedge clk) begin
    if(~rst_n) begin
        p1_r <= 32'b0;
        p2_r <= 32'b0;
    end else begin
        p1_r <= p1_w;
        p2_r <= p2_w;
    end
end

endmodule

// module Wallace_MUL_32 (
//     A_i,
//     B_i,
//     Out_o
//     );

//     input [31:0] A_i;
//     input [31:0] B_i;
//     output [31:0] Out_o;

//     reg [31:0] product [0:31];

//     integer i, j;
//     genvar k;

//     // assign Out_o = A_i * B_i;

//     always @(*) begin
//         for (i=0; i<32; i=i+1) begin
//             for (j=0; j<32; j=j+1) begin
//                 product[i][j] = A_i[j] & B_i[i];
//             end
//         end
//     end

//     // stage 1: 32 -> 22
//     wire [32:0] stage1 [0:21];

//     assign stage1[0][0] = product[0][0];
//     HA ha1_01( .a_i(product[0][1]), .b_i(product[1][0]), .Sum_o(stage1[0][1]), .Cout_o(stage1[1][2]) );
//     generate
//         for (k=2; k<=31; k=k+1) begin: gen_stage1_1
//             FA fa1_k( .a_i(product[0][k]), .b_i(product[1][k-1]), .c_i(product[2][k-2]), .Sum_o(stage1[0][k]), .Cout_o(stage1[1][k+1]) );
//         end
//     endgenerate

//     assign stage1[2][3] = product[3][0];
//     HA ha1_24( .a_i(product[3][1]), .b_i(product[4][0]), .Sum_o(stage1[2][4]), .Cout_o(stage1[3][5]) );
//     generate
//         for (k=5; k<=31; k=k+1) begin: gen_stage1_2
//             FA fa1_k( .a_i(product[3][k-3]), .b_i(product[4][k-4]), .c_i(product[5][k-5]), .Sum_o(stage1[2][k]), .Cout_o(stage1[3][k+1]) );
//         end
//     endgenerate

//     assign stage1[4][6] = product[6][0];
//     HA ha1_47( .a_i(product[6][1]), .b_i(product[7][0]), .Sum_o(stage1[4][7]), .Cout_o(stage1[5][8]) );
//     generate
//         for (k=8; k<=31; k=k+1) begin: gen_stage1_3
//             FA fa1_k( .a_i(product[6][k-6]), .b_i(product[7][k-7]), .c_i(product[8][k-8]), .Sum_o(stage1[4][k]), .Cout_o(stage1[5][k+1]) );
//         end
//     endgenerate

//     assign stage1[6][9] = product[9][0];
//     HA ha1_610( .a_i(product[9][1]), .b_i(product[10][0]), .Sum_o(stage1[6][10]), .Cout_o(stage1[7][11]) );
//     generate
//         for (k=11; k<=31; k=k+1) begin: gen_stage1_4
//             FA fa1_k( .a_i(product[9][k-9]), .b_i(product[10][k-10]), .c_i(product[11][k-11]), .Sum_o(stage1[6][k]), .Cout_o(stage1[7][k+1]) );
//         end
//     endgenerate

//     assign stage1[8][12] = product[12][0];
//     HA ha1_813( .a_i(product[12][1]), .b_i(product[13][0]), .Sum_o(stage1[8][13]), .Cout_o(stage1[9][14]) );
//     generate
//         for (k=14; k<=31; k=k+1) begin: gen_stage1_5
//             FA fa1_k( .a_i(product[12][k-12]), .b_i(product[13][k-13]), .c_i(product[14][k-14]), .Sum_o(stage1[8][k]), .Cout_o(stage1[9][k+1]) );
//         end
//     endgenerate

//     assign stage1[10][15] = product[15][0];
//     HA ha1_1016( .a_i(product[15][1]), .b_i(product[16][0]), .Sum_o(stage1[10][16]), .Cout_o(stage1[11][17]) );
//     generate
//         for (k=17; k<=31; k=k+1) begin: gen_stage1_6
//             FA fa1_k( .a_i(product[15][k-15]), .b_i(product[16][k-16]), .c_i(product[17][k-17]), .Sum_o(stage1[10][k]), .Cout_o(stage1[11][k+1]) );
//         end
//     endgenerate

//     assign stage1[12][18] = product[18][0];
//     HA ha1_1219( .a_i(product[18][1]), .b_i(product[19][0]), .Sum_o(stage1[12][19]), .Cout_o(stage1[13][20]) );
//     generate
//         for (k=20; k<=31; k=k+1) begin: gen_stage1_7
//             FA fa1_k( .a_i(product[18][k-18]), .b_i(product[19][k-19]), .c_i(product[20][k-20]), .Sum_o(stage1[12][k]), .Cout_o(stage1[13][k+1]) );
//         end
//     endgenerate

//     assign stage1[14][21] = product[21][0];
//     HA ha1_1422( .a_i(product[21][1]), .b_i(product[22][0]), .Sum_o(stage1[14][22]), .Cout_o(stage1[15][23]) );
//     generate
//         for (k=23; k<=31; k=k+1) begin: gen_stage1_8
//             FA fa1_k( .a_i(product[21][k-21]), .b_i(product[22][k-22]), .c_i(product[23][k-23]), .Sum_o(stage1[14][k]), .Cout_o(stage1[15][k+1]) );
//         end
//     endgenerate

//     assign stage1[16][24] = product[24][0];
//     HA ha1_1625( .a_i(product[24][1]), .b_i(product[25][0]), .Sum_o(stage1[16][25]), .Cout_o(stage1[17][26]) );
//     generate
//         for (k=26; k<=31; k=k+1) begin: gen_stage1_9
//             FA fa1_k( .a_i(product[24][k-24]), .b_i(product[25][k-25]), .c_i(product[26][k-26]), .Sum_o(stage1[16][k]), .Cout_o(stage1[17][k+1]) );
//         end
//     endgenerate

//     assign stage1[18][27] = product[27][0];
//     HA ha1_1828( .a_i(product[27][1]), .b_i(product[28][0]), .Sum_o(stage1[18][28]), .Cout_o(stage1[19][29]) );
//     generate
//         for (k=29; k<=31; k=k+1) begin: gen_stage1_10
//             FA fa1_k( .a_i(product[27][k-27]), .b_i(product[28][k-28]), .c_i(product[29][k-29]), .Sum_o(stage1[18][k]), .Cout_o(stage1[19][k+1]) );
//         end
//     endgenerate

//     assign stage1[20][31:30] = product[30][1:0];
//     assign stage1[21][31] = product[31][0];

//     // stage 2: 22 -> 15
//     wire [32:0] stage2 [0:14];

//     assign stage2[0][1:0] = stage1[0][1:0];
//     HA ha2_02( .a_i(stage1[0][2]), .b_i(stage1[1][2]), .Sum_o(stage2[0][2]), .Cout_o(stage2[1][3]) );
//     generate
//         for (k=3; k<=31; k=k+1) begin: gen_stage2_1
//             FA fa2_k( .a_i(stage1[0][k]), .b_i(stage1[1][k]), .c_i(stage1[2][k]), .Sum_o(stage2[0][k]), .Cout_o(stage2[1][k+1]) );
//         end
//     endgenerate

//     assign stage2[2][5] = stage1[3][5];
//     HA ha2_26( .a_i(stage1[3][6]), .b_i(stage1[4][6]), .Sum_o(stage2[2][6]), .Cout_o(stage2[3][7]) );
//     HA ha2_27( .a_i(stage1[3][7]), .b_i(stage1[4][7]), .Sum_o(stage2[2][7]), .Cout_o(stage2[3][8]) );
//     generate
//         for (k=8; k<=31; k=k+1) begin: gen_stage2_2
//             FA fa2_k( .a_i(stage1[3][k]), .b_i(stage1[4][k]), .c_i(stage1[5][k]), .Sum_o(stage2[2][k]), .Cout_o(stage2[3][k+1]) );
//         end
//     endgenerate

//     assign stage2[4][10:9] = stage1[6][10:9];
//     HA ha2_411( .a_i(stage1[6][11]), .b_i(stage1[7][11]), .Sum_o(stage2[4][11]), .Cout_o(stage2[5][12]) );
//     generate
//         for (k=12; k<=31; k=k+1) begin: gen_stage2_3
//             FA fa2_k( .a_i(stage1[6][k]), .b_i(stage1[7][k]), .c_i(stage1[8][k]), .Sum_o(stage2[4][k]), .Cout_o(stage2[5][k+1]) );
//         end
//     endgenerate

//     assign stage2[6][14] = stage1[9][14];
//     HA ha2_615( .a_i(stage1[9][15]), .b_i(stage1[10][15]), .Sum_o(stage2[6][15]), .Cout_o(stage2[7][16]) );
//     HA ha2_616( .a_i(stage1[9][16]), .b_i(stage1[10][16]), .Sum_o(stage2[6][16]), .Cout_o(stage2[7][17]) );
//     generate
//         for (k=17; k<=31; k=k+1) begin: gen_stage2_4
//             FA fa2_k( .a_i(stage1[9][k]), .b_i(stage1[10][k]), .c_i(stage1[11][k]), .Sum_o(stage2[6][k]), .Cout_o(stage2[7][k+1]) );
//         end
//     endgenerate

//     assign stage2[8][19:18] = stage1[12][19:18];
//     HA ha2_820( .a_i(stage1[12][20]), .b_i(stage1[13][20]), .Sum_o(stage2[8][20]), .Cout_o(stage2[9][21]) );
//     generate
//         for (k=21; k<=31; k=k+1) begin: gen_stage2_5
//             FA fa2_k( .a_i(stage1[12][k]), .b_i(stage1[13][k]), .c_i(stage1[14][k]), .Sum_o(stage2[8][k]), .Cout_o(stage2[9][k+1]) );
//         end
//     endgenerate

//     assign stage2[10][23] = stage1[15][23];
//     HA ha2_1024( .a_i(stage1[15][24]), .b_i(stage1[16][24]), .Sum_o(stage2[10][24]), .Cout_o(stage2[11][25]) );
//     HA ha2_1025( .a_i(stage1[15][25]), .b_i(stage1[16][25]), .Sum_o(stage2[10][25]), .Cout_o(stage2[11][26]) );
//     generate
//         for (k=26; k<=31; k=k+1) begin: gen_stage2_6
//             FA fa2_k( .a_i(stage1[15][k]), .b_i(stage1[16][k]), .c_i(stage1[17][k]), .Sum_o(stage2[10][k]), .Cout_o(stage2[11][k+1]) );
//         end
//     endgenerate

//     assign stage2[12][28:27] = stage1[18][28:27];
//     HA ha2_1229( .a_i(stage1[18][29]), .b_i(stage1[19][29]), .Sum_o(stage2[12][29]), .Cout_o(stage2[13][30]) );
//     generate
//         for (k=30; k<=31; k=k+1) begin: gen_stage2_7
//             FA fa2_k( .a_i(stage1[18][k]), .b_i(stage1[19][k]), .c_i(stage1[20][k]), .Sum_o(stage2[12][k]), .Cout_o(stage2[13][k+1]) );
//         end
//     endgenerate

//     assign stage2[14][31] = stage1[21][31];

//     // stage 3: 15 -> 10
//     wire [32:0] stage3 [0:9];

//     assign stage3[0][2:0] = stage2[0][2:0];
//     HA ha3_03( .a_i(stage2[0][3]), .b_i(stage2[1][3]), .Sum_o(stage3[0][3]), .Cout_o(stage3[1][4]) );
//     HA ha3_04( .a_i(stage2[0][4]), .b_i(stage2[1][4]), .Sum_o(stage3[0][4]), .Cout_o(stage3[1][5]) );
//     generate
//         for (k=5; k<=31; k=k+1) begin: gen_stage3_1
//             FA fa3_k( .a_i(stage2[0][k]), .b_i(stage2[1][k]), .c_i(stage2[2][k]), .Sum_o(stage3[0][k]), .Cout_o(stage3[1][k+1]) );
//         end
//     endgenerate

//     assign stage3[2][8:7] = stage2[3][8:7];
//     HA ha3_29( .a_i(stage2[3][9]), .b_i(stage2[4][9]), .Sum_o(stage3[2][9]), .Cout_o(stage3[3][10]) );
//     HA ha3_210( .a_i(stage2[3][10]), .b_i(stage2[4][10]), .Sum_o(stage3[2][10]), .Cout_o(stage3[3][11]) );
//     HA ha3_211( .a_i(stage2[3][11]), .b_i(stage2[4][11]), .Sum_o(stage3[2][11]), .Cout_o(stage3[3][12]) );
//     generate
//         for (k=12; k<=31; k=k+1) begin: gen_stage3_2
//             FA fa3_k( .a_i(stage2[3][k]), .b_i(stage2[4][k]), .c_i(stage2[5][k]), .Sum_o(stage3[2][k]), .Cout_o(stage3[3][k+1]) );
//         end
//     endgenerate

//     assign stage3[4][15:14] = stage2[6][15:14];
//     HA ha3_416( .a_i(stage2[6][16]), .b_i(stage2[7][16]), .Sum_o(stage3[4][16]), .Cout_o(stage3[5][17]) );
//     HA ha3_417( .a_i(stage2[6][17]), .b_i(stage2[7][17]), .Sum_o(stage3[4][17]), .Cout_o(stage3[5][18]) );
//     generate
//         for (k=18; k<=31; k=k+1) begin: gen_stage3_3
//             FA fa3_k( .a_i(stage2[6][k]), .b_i(stage2[7][k]), .c_i(stage2[8][k]), .Sum_o(stage3[4][k]), .Cout_o(stage3[5][k+1]) );
//         end
//     endgenerate

//     assign stage3[6][22:21] = stage2[9][22:21];
//     HA ha3_623( .a_i(stage2[9][23]), .b_i(stage2[10][23]), .Sum_o(stage3[6][23]), .Cout_o(stage3[7][24]) );
//     HA ha3_624( .a_i(stage2[9][24]), .b_i(stage2[10][24]), .Sum_o(stage3[6][24]), .Cout_o(stage3[7][25]) );
//     generate
//         for (k=25; k<=31; k=k+1) begin: gen_stage3_4
//             FA fa3_k( .a_i(stage2[9][k]), .b_i(stage2[10][k]), .c_i(stage2[11][k]), .Sum_o(stage3[6][k]), .Cout_o(stage3[7][k+1]) );
//         end
//     endgenerate

//     assign stage3[8][29:27] = stage2[12][29:27];
//     HA ha3_830( .a_i(stage2[12][30]), .b_i(stage2[13][30]), .Sum_o(stage3[8][30]), .Cout_o(stage3[9][31]) );
//     FA fa3_831( .a_i(stage2[12][31]), .b_i(stage2[13][31]), .c_i(stage2[14][31]), .Sum_o(stage3[8][31]) );

//     // stage 4: 10 -> 7
//     wire [32:0] stage4 [0:6];

//     assign stage4[0][3:0] = stage3[0][3:0];
//     HA ha4_04( .a_i(stage3[0][4]), .b_i(stage3[1][4]), .Sum_o(stage4[0][4]), .Cout_o(stage4[1][5]) );
//     HA ha4_05( .a_i(stage3[0][5]), .b_i(stage3[1][5]), .Sum_o(stage4[0][5]), .Cout_o(stage4[1][6]) );
//     HA ha4_06( .a_i(stage3[0][6]), .b_i(stage3[1][6]), .Sum_o(stage4[0][6]), .Cout_o(stage4[1][7]) );
//     generate
//         for (k=7; k<=31; k=k+1) begin: gen_stage4_1
//             FA fa4_k( .a_i(stage3[0][k]), .b_i(stage3[1][k]), .c_i(stage3[2][k]), .Sum_o(stage4[0][k]), .Cout_o(stage4[1][k+1]) );
//         end
//     endgenerate

//     assign stage4[2][13:10] = stage3[3][13:10];
//     HA ha4_214( .a_i(stage3[3][14]), .b_i(stage3[4][14]), .Sum_o(stage4[2][14]), .Cout_o(stage4[3][15]) );
//     HA ha4_215( .a_i(stage3[3][15]), .b_i(stage3[4][15]), .Sum_o(stage4[2][15]), .Cout_o(stage4[3][16]) );
//     HA ha4_216( .a_i(stage3[3][16]), .b_i(stage3[4][16]), .Sum_o(stage4[2][16]), .Cout_o(stage4[3][17]) );
//     generate
//         for (k=17; k<=31; k=k+1) begin: gen_stage4_2
//             FA fa4_k( .a_i(stage3[3][k]), .b_i(stage3[4][k]), .c_i(stage3[5][k]), .Sum_o(stage4[2][k]), .Cout_o(stage4[3][k+1]) );
//         end
//     endgenerate

//     assign stage4[4][23:21] = stage3[6][23:21];
//     HA ha4_424( .a_i(stage3[6][24]), .b_i(stage3[7][24]), .Sum_o(stage4[4][24]), .Cout_o(stage4[5][25]) );
//     HA ha4_425( .a_i(stage3[6][25]), .b_i(stage3[7][25]), .Sum_o(stage4[4][25]), .Cout_o(stage4[5][26]) );
//     HA ha4_426( .a_i(stage3[6][26]), .b_i(stage3[7][26]), .Sum_o(stage4[4][26]), .Cout_o(stage4[5][27]) );
//     generate
//         for (k=27; k<=31; k=k+1) begin: gen_stage4_3
//             FA fa4_k( .a_i(stage3[6][k]), .b_i(stage3[7][k]), .c_i(stage3[8][k]), .Sum_o(stage4[4][k]), .Cout_o(stage4[5][k+1]) );
//         end
//     endgenerate

//     assign stage4[6][31] = stage3[9][31];

//     // stage 5: 7 -> 5
//     wire [32:0] stage5 [0:4];

//     assign stage5[0][4:0] = stage4[0][4:0];
//     HA ha5_05( .a_i(stage4[0][5]), .b_i(stage4[1][5]), .Sum_o(stage5[0][5]), .Cout_o(stage5[1][6]) );
//     HA ha5_06( .a_i(stage4[0][6]), .b_i(stage4[1][6]), .Sum_o(stage5[0][6]), .Cout_o(stage5[1][7]) );
//     HA ha5_07( .a_i(stage4[0][7]), .b_i(stage4[1][7]), .Sum_o(stage5[0][7]), .Cout_o(stage5[1][8]) );
//     HA ha5_08( .a_i(stage4[0][8]), .b_i(stage4[1][8]), .Sum_o(stage5[0][8]), .Cout_o(stage5[1][9]) );
//     HA ha5_09( .a_i(stage4[0][9]), .b_i(stage4[1][9]), .Sum_o(stage5[0][9]), .Cout_o(stage5[1][10]) );
//     generate
//         for (k=10; k<=31; k=k+1) begin: gen_stage5_1
//             FA fa5_k( .a_i(stage4[0][k]), .b_i(stage4[1][k]), .c_i(stage4[2][k]), .Sum_o(stage5[0][k]), .Cout_o(stage5[1][k+1]) );
//         end
//     endgenerate

//     assign stage5[2][20:15] = stage4[3][20:15];
//     HA ha5_221( .a_i(stage4[3][21]), .b_i(stage4[4][21]), .Sum_o(stage5[2][21]), .Cout_o(stage5[3][22]) );
//     HA ha5_222( .a_i(stage4[3][22]), .b_i(stage4[4][22]), .Sum_o(stage5[2][22]), .Cout_o(stage5[3][23]) );
//     HA ha5_223( .a_i(stage4[3][23]), .b_i(stage4[4][23]), .Sum_o(stage5[2][23]), .Cout_o(stage5[3][24]) );
//     HA ha5_224( .a_i(stage4[3][24]), .b_i(stage4[4][24]), .Sum_o(stage5[2][24]), .Cout_o(stage5[3][25]) );
//     generate
//         for (k=25; k<=31; k=k+1) begin: gen_stage5_2
//             FA fa5_k( .a_i(stage4[3][k]), .b_i(stage4[4][k]), .c_i(stage4[5][k]), .Sum_o(stage5[2][k]), .Cout_o(stage5[3][k+1]) );
//         end
//     endgenerate
//     assign stage5[4][31] = stage4[6][31];


//     // stage 6: 5 -> 4
//     wire [32:0] stage6 [0:3];

//     assign stage6[0][5:0] = stage5[0][5:0];
//     generate
//         for (k=6; k<=14; k=k+1) begin: gen_stage6_1
//             HA ha_6_k( .a_i(stage5[0][k]), .b_i(stage5[1][k]), .Sum_o(stage6[0][k]), .Cout_o(stage6[1][k+1]) );
//         end
//         for (k=15; k<=31; k=k+1) begin: gen_stage6_2
//             FA fa_6_k( .a_i(stage5[0][k]), .b_i(stage5[1][k]), .c_i(stage5[2][k]), .Sum_o(stage6[0][k]), .Cout_o(stage6[1][k+1]) );
//         end
//     endgenerate

//     assign stage6[2][31:22] = stage5[3][31:22];
//     assign stage6[3][31] = stage5[4][31];

//     // stage 7: 4 -> 3
//     wire [32:0] stage7 [0:2];

//     assign stage7[0][6:0] = stage6[0][6:0];
//     generate
//         for (k=7; k<=21; k=k+1) begin: gen_stage7_1
//             HA ha_7_k( .a_i(stage6[0][k]), .b_i(stage6[1][k]), .Sum_o(stage7[0][k]), .Cout_o(stage7[1][k+1]) );
//         end
//         for (k=22; k<=31; k=k+1) begin: gen_stage7_2
//             FA fa_7_k( .a_i(stage6[0][k]), .b_i(stage6[1][k]), .c_i(stage6[2][k]), .Sum_o(stage7[0][k]), .Cout_o(stage7[1][k+1]) );
//         end
//     endgenerate
//     assign stage7[2][31] = stage6[3][31];

//     // stage 8: 3 -> 2
//     wire [32:0] stage8 [0:1];

//     assign stage8[0][7:0] = stage7[0][7:0];
//     generate
//         for (k=8; k<=30; k=k+1) begin: gen_stage8_1
//             HA ha_8_k( .a_i(stage7[0][k]), .b_i(stage7[1][k]), .Sum_o(stage8[0][k]), .Cout_o(stage8[1][k+1]) );
//         end
//     endgenerate
//     FA fa_8_31( .a_i(stage7[0][31]), .b_i(stage7[1][31]), .c_i(stage7[2][31]), .Sum_o(stage8[0][31]) );

//     // Output
//     assign Out_o[31:9] = stage8[0][31:9] + stage8[1][31:9];
//     assign Out_o[8:0] = stage8[0][8:0];

// endmodule

module Wallace_MUL_32_p1 (
    A_i,
    B_i,
    partialSum0_o,
    partialSum1_o
    );

    input [31:0] A_i;
    input [31:0] B_i;
    output [31:0] partialSum0_o;
    output [22:0] partialSum1_o;

    reg [31:0] product [0:31];

    integer i, j;
    genvar k;

    // assign Out_o = A_i * B_i;

    always @(*) begin
        for (i=0; i<32; i=i+1) begin
            for (j=0; j<32; j=j+1) begin
                product[i][j] = A_i[j] & B_i[i];
            end
        end
    end

    // stage 1: 32 -> 22
    wire [32:0] stage1 [0:21];

    assign stage1[0][0] = product[0][0];
    HA ha1_01( .a_i(product[0][1]), .b_i(product[1][0]), .Sum_o(stage1[0][1]), .Cout_o(stage1[1][2]) );
    generate
        for (k=2; k<=31; k=k+1) begin: gen_stage1_1
            FA fa1_k( .a_i(product[0][k]), .b_i(product[1][k-1]), .c_i(product[2][k-2]), .Sum_o(stage1[0][k]), .Cout_o(stage1[1][k+1]) );
        end
    endgenerate

    assign stage1[2][3] = product[3][0];
    HA ha1_24( .a_i(product[3][1]), .b_i(product[4][0]), .Sum_o(stage1[2][4]), .Cout_o(stage1[3][5]) );
    generate
        for (k=5; k<=31; k=k+1) begin: gen_stage1_2
            FA fa1_k( .a_i(product[3][k-3]), .b_i(product[4][k-4]), .c_i(product[5][k-5]), .Sum_o(stage1[2][k]), .Cout_o(stage1[3][k+1]) );
        end
    endgenerate

    assign stage1[4][6] = product[6][0];
    HA ha1_47( .a_i(product[6][1]), .b_i(product[7][0]), .Sum_o(stage1[4][7]), .Cout_o(stage1[5][8]) );
    generate
        for (k=8; k<=31; k=k+1) begin: gen_stage1_3
            FA fa1_k( .a_i(product[6][k-6]), .b_i(product[7][k-7]), .c_i(product[8][k-8]), .Sum_o(stage1[4][k]), .Cout_o(stage1[5][k+1]) );
        end
    endgenerate

    assign stage1[6][9] = product[9][0];
    HA ha1_610( .a_i(product[9][1]), .b_i(product[10][0]), .Sum_o(stage1[6][10]), .Cout_o(stage1[7][11]) );
    generate
        for (k=11; k<=31; k=k+1) begin: gen_stage1_4
            FA fa1_k( .a_i(product[9][k-9]), .b_i(product[10][k-10]), .c_i(product[11][k-11]), .Sum_o(stage1[6][k]), .Cout_o(stage1[7][k+1]) );
        end
    endgenerate

    assign stage1[8][12] = product[12][0];
    HA ha1_813( .a_i(product[12][1]), .b_i(product[13][0]), .Sum_o(stage1[8][13]), .Cout_o(stage1[9][14]) );
    generate
        for (k=14; k<=31; k=k+1) begin: gen_stage1_5
            FA fa1_k( .a_i(product[12][k-12]), .b_i(product[13][k-13]), .c_i(product[14][k-14]), .Sum_o(stage1[8][k]), .Cout_o(stage1[9][k+1]) );
        end
    endgenerate

    assign stage1[10][15] = product[15][0];
    HA ha1_1016( .a_i(product[15][1]), .b_i(product[16][0]), .Sum_o(stage1[10][16]), .Cout_o(stage1[11][17]) );
    generate
        for (k=17; k<=31; k=k+1) begin: gen_stage1_6
            FA fa1_k( .a_i(product[15][k-15]), .b_i(product[16][k-16]), .c_i(product[17][k-17]), .Sum_o(stage1[10][k]), .Cout_o(stage1[11][k+1]) );
        end
    endgenerate

    assign stage1[12][18] = product[18][0];
    HA ha1_1219( .a_i(product[18][1]), .b_i(product[19][0]), .Sum_o(stage1[12][19]), .Cout_o(stage1[13][20]) );
    generate
        for (k=20; k<=31; k=k+1) begin: gen_stage1_7
            FA fa1_k( .a_i(product[18][k-18]), .b_i(product[19][k-19]), .c_i(product[20][k-20]), .Sum_o(stage1[12][k]), .Cout_o(stage1[13][k+1]) );
        end
    endgenerate

    assign stage1[14][21] = product[21][0];
    HA ha1_1422( .a_i(product[21][1]), .b_i(product[22][0]), .Sum_o(stage1[14][22]), .Cout_o(stage1[15][23]) );
    generate
        for (k=23; k<=31; k=k+1) begin: gen_stage1_8
            FA fa1_k( .a_i(product[21][k-21]), .b_i(product[22][k-22]), .c_i(product[23][k-23]), .Sum_o(stage1[14][k]), .Cout_o(stage1[15][k+1]) );
        end
    endgenerate

    assign stage1[16][24] = product[24][0];
    HA ha1_1625( .a_i(product[24][1]), .b_i(product[25][0]), .Sum_o(stage1[16][25]), .Cout_o(stage1[17][26]) );
    generate
        for (k=26; k<=31; k=k+1) begin: gen_stage1_9
            FA fa1_k( .a_i(product[24][k-24]), .b_i(product[25][k-25]), .c_i(product[26][k-26]), .Sum_o(stage1[16][k]), .Cout_o(stage1[17][k+1]) );
        end
    endgenerate

    assign stage1[18][27] = product[27][0];
    HA ha1_1828( .a_i(product[27][1]), .b_i(product[28][0]), .Sum_o(stage1[18][28]), .Cout_o(stage1[19][29]) );
    generate
        for (k=29; k<=31; k=k+1) begin: gen_stage1_10
            FA fa1_k( .a_i(product[27][k-27]), .b_i(product[28][k-28]), .c_i(product[29][k-29]), .Sum_o(stage1[18][k]), .Cout_o(stage1[19][k+1]) );
        end
    endgenerate

    assign stage1[20][31:30] = product[30][1:0];
    assign stage1[21][31] = product[31][0];

    // stage 2: 22 -> 15
    wire [32:0] stage2 [0:14];

    assign stage2[0][1:0] = stage1[0][1:0];
    HA ha2_02( .a_i(stage1[0][2]), .b_i(stage1[1][2]), .Sum_o(stage2[0][2]), .Cout_o(stage2[1][3]) );
    generate
        for (k=3; k<=31; k=k+1) begin: gen_stage2_1
            FA fa2_k( .a_i(stage1[0][k]), .b_i(stage1[1][k]), .c_i(stage1[2][k]), .Sum_o(stage2[0][k]), .Cout_o(stage2[1][k+1]) );
        end
    endgenerate

    assign stage2[2][5] = stage1[3][5];
    HA ha2_26( .a_i(stage1[3][6]), .b_i(stage1[4][6]), .Sum_o(stage2[2][6]), .Cout_o(stage2[3][7]) );
    HA ha2_27( .a_i(stage1[3][7]), .b_i(stage1[4][7]), .Sum_o(stage2[2][7]), .Cout_o(stage2[3][8]) );
    generate
        for (k=8; k<=31; k=k+1) begin: gen_stage2_2
            FA fa2_k( .a_i(stage1[3][k]), .b_i(stage1[4][k]), .c_i(stage1[5][k]), .Sum_o(stage2[2][k]), .Cout_o(stage2[3][k+1]) );
        end
    endgenerate

    assign stage2[4][10:9] = stage1[6][10:9];
    HA ha2_411( .a_i(stage1[6][11]), .b_i(stage1[7][11]), .Sum_o(stage2[4][11]), .Cout_o(stage2[5][12]) );
    generate
        for (k=12; k<=31; k=k+1) begin: gen_stage2_3
            FA fa2_k( .a_i(stage1[6][k]), .b_i(stage1[7][k]), .c_i(stage1[8][k]), .Sum_o(stage2[4][k]), .Cout_o(stage2[5][k+1]) );
        end
    endgenerate

    assign stage2[6][14] = stage1[9][14];
    HA ha2_615( .a_i(stage1[9][15]), .b_i(stage1[10][15]), .Sum_o(stage2[6][15]), .Cout_o(stage2[7][16]) );
    HA ha2_616( .a_i(stage1[9][16]), .b_i(stage1[10][16]), .Sum_o(stage2[6][16]), .Cout_o(stage2[7][17]) );
    generate
        for (k=17; k<=31; k=k+1) begin: gen_stage2_4
            FA fa2_k( .a_i(stage1[9][k]), .b_i(stage1[10][k]), .c_i(stage1[11][k]), .Sum_o(stage2[6][k]), .Cout_o(stage2[7][k+1]) );
        end
    endgenerate

    assign stage2[8][19:18] = stage1[12][19:18];
    HA ha2_820( .a_i(stage1[12][20]), .b_i(stage1[13][20]), .Sum_o(stage2[8][20]), .Cout_o(stage2[9][21]) );
    generate
        for (k=21; k<=31; k=k+1) begin: gen_stage2_5
            FA fa2_k( .a_i(stage1[12][k]), .b_i(stage1[13][k]), .c_i(stage1[14][k]), .Sum_o(stage2[8][k]), .Cout_o(stage2[9][k+1]) );
        end
    endgenerate

    assign stage2[10][23] = stage1[15][23];
    HA ha2_1024( .a_i(stage1[15][24]), .b_i(stage1[16][24]), .Sum_o(stage2[10][24]), .Cout_o(stage2[11][25]) );
    HA ha2_1025( .a_i(stage1[15][25]), .b_i(stage1[16][25]), .Sum_o(stage2[10][25]), .Cout_o(stage2[11][26]) );
    generate
        for (k=26; k<=31; k=k+1) begin: gen_stage2_6
            FA fa2_k( .a_i(stage1[15][k]), .b_i(stage1[16][k]), .c_i(stage1[17][k]), .Sum_o(stage2[10][k]), .Cout_o(stage2[11][k+1]) );
        end
    endgenerate

    assign stage2[12][28:27] = stage1[18][28:27];
    HA ha2_1229( .a_i(stage1[18][29]), .b_i(stage1[19][29]), .Sum_o(stage2[12][29]), .Cout_o(stage2[13][30]) );
    generate
        for (k=30; k<=31; k=k+1) begin: gen_stage2_7
            FA fa2_k( .a_i(stage1[18][k]), .b_i(stage1[19][k]), .c_i(stage1[20][k]), .Sum_o(stage2[12][k]), .Cout_o(stage2[13][k+1]) );
        end
    endgenerate

    assign stage2[14][31] = stage1[21][31];

    // stage 3: 15 -> 10
    wire [32:0] stage3 [0:9];

    assign stage3[0][2:0] = stage2[0][2:0];
    HA ha3_03( .a_i(stage2[0][3]), .b_i(stage2[1][3]), .Sum_o(stage3[0][3]), .Cout_o(stage3[1][4]) );
    HA ha3_04( .a_i(stage2[0][4]), .b_i(stage2[1][4]), .Sum_o(stage3[0][4]), .Cout_o(stage3[1][5]) );
    generate
        for (k=5; k<=31; k=k+1) begin: gen_stage3_1
            FA fa3_k( .a_i(stage2[0][k]), .b_i(stage2[1][k]), .c_i(stage2[2][k]), .Sum_o(stage3[0][k]), .Cout_o(stage3[1][k+1]) );
        end
    endgenerate

    assign stage3[2][8:7] = stage2[3][8:7];
    HA ha3_29( .a_i(stage2[3][9]), .b_i(stage2[4][9]), .Sum_o(stage3[2][9]), .Cout_o(stage3[3][10]) );
    HA ha3_210( .a_i(stage2[3][10]), .b_i(stage2[4][10]), .Sum_o(stage3[2][10]), .Cout_o(stage3[3][11]) );
    HA ha3_211( .a_i(stage2[3][11]), .b_i(stage2[4][11]), .Sum_o(stage3[2][11]), .Cout_o(stage3[3][12]) );
    generate
        for (k=12; k<=31; k=k+1) begin: gen_stage3_2
            FA fa3_k( .a_i(stage2[3][k]), .b_i(stage2[4][k]), .c_i(stage2[5][k]), .Sum_o(stage3[2][k]), .Cout_o(stage3[3][k+1]) );
        end
    endgenerate

    assign stage3[4][15:14] = stage2[6][15:14];
    HA ha3_416( .a_i(stage2[6][16]), .b_i(stage2[7][16]), .Sum_o(stage3[4][16]), .Cout_o(stage3[5][17]) );
    HA ha3_417( .a_i(stage2[6][17]), .b_i(stage2[7][17]), .Sum_o(stage3[4][17]), .Cout_o(stage3[5][18]) );
    generate
        for (k=18; k<=31; k=k+1) begin: gen_stage3_3
            FA fa3_k( .a_i(stage2[6][k]), .b_i(stage2[7][k]), .c_i(stage2[8][k]), .Sum_o(stage3[4][k]), .Cout_o(stage3[5][k+1]) );
        end
    endgenerate

    assign stage3[6][22:21] = stage2[9][22:21];
    HA ha3_623( .a_i(stage2[9][23]), .b_i(stage2[10][23]), .Sum_o(stage3[6][23]), .Cout_o(stage3[7][24]) );
    HA ha3_624( .a_i(stage2[9][24]), .b_i(stage2[10][24]), .Sum_o(stage3[6][24]), .Cout_o(stage3[7][25]) );
    generate
        for (k=25; k<=31; k=k+1) begin: gen_stage3_4
            FA fa3_k( .a_i(stage2[9][k]), .b_i(stage2[10][k]), .c_i(stage2[11][k]), .Sum_o(stage3[6][k]), .Cout_o(stage3[7][k+1]) );
        end
    endgenerate

    assign stage3[8][29:27] = stage2[12][29:27];
    HA ha3_830( .a_i(stage2[12][30]), .b_i(stage2[13][30]), .Sum_o(stage3[8][30]), .Cout_o(stage3[9][31]) );
    FA fa3_831( .a_i(stage2[12][31]), .b_i(stage2[13][31]), .c_i(stage2[14][31]), .Sum_o(stage3[8][31]) );

    // stage 4: 10 -> 7
    wire [32:0] stage4 [0:6];

    assign stage4[0][3:0] = stage3[0][3:0];
    HA ha4_04( .a_i(stage3[0][4]), .b_i(stage3[1][4]), .Sum_o(stage4[0][4]), .Cout_o(stage4[1][5]) );
    HA ha4_05( .a_i(stage3[0][5]), .b_i(stage3[1][5]), .Sum_o(stage4[0][5]), .Cout_o(stage4[1][6]) );
    HA ha4_06( .a_i(stage3[0][6]), .b_i(stage3[1][6]), .Sum_o(stage4[0][6]), .Cout_o(stage4[1][7]) );
    generate
        for (k=7; k<=31; k=k+1) begin: gen_stage4_1
            FA fa4_k( .a_i(stage3[0][k]), .b_i(stage3[1][k]), .c_i(stage3[2][k]), .Sum_o(stage4[0][k]), .Cout_o(stage4[1][k+1]) );
        end
    endgenerate

    assign stage4[2][13:10] = stage3[3][13:10];
    HA ha4_214( .a_i(stage3[3][14]), .b_i(stage3[4][14]), .Sum_o(stage4[2][14]), .Cout_o(stage4[3][15]) );
    HA ha4_215( .a_i(stage3[3][15]), .b_i(stage3[4][15]), .Sum_o(stage4[2][15]), .Cout_o(stage4[3][16]) );
    HA ha4_216( .a_i(stage3[3][16]), .b_i(stage3[4][16]), .Sum_o(stage4[2][16]), .Cout_o(stage4[3][17]) );
    generate
        for (k=17; k<=31; k=k+1) begin: gen_stage4_2
            FA fa4_k( .a_i(stage3[3][k]), .b_i(stage3[4][k]), .c_i(stage3[5][k]), .Sum_o(stage4[2][k]), .Cout_o(stage4[3][k+1]) );
        end
    endgenerate

    assign stage4[4][23:21] = stage3[6][23:21];
    HA ha4_424( .a_i(stage3[6][24]), .b_i(stage3[7][24]), .Sum_o(stage4[4][24]), .Cout_o(stage4[5][25]) );
    HA ha4_425( .a_i(stage3[6][25]), .b_i(stage3[7][25]), .Sum_o(stage4[4][25]), .Cout_o(stage4[5][26]) );
    HA ha4_426( .a_i(stage3[6][26]), .b_i(stage3[7][26]), .Sum_o(stage4[4][26]), .Cout_o(stage4[5][27]) );
    generate
        for (k=27; k<=31; k=k+1) begin: gen_stage4_3
            FA fa4_k( .a_i(stage3[6][k]), .b_i(stage3[7][k]), .c_i(stage3[8][k]), .Sum_o(stage4[4][k]), .Cout_o(stage4[5][k+1]) );
        end
    endgenerate

    assign stage4[6][31] = stage3[9][31];

    // stage 5: 7 -> 5
    wire [32:0] stage5 [0:4];

    assign stage5[0][4:0] = stage4[0][4:0];
    HA ha5_05( .a_i(stage4[0][5]), .b_i(stage4[1][5]), .Sum_o(stage5[0][5]), .Cout_o(stage5[1][6]) );
    HA ha5_06( .a_i(stage4[0][6]), .b_i(stage4[1][6]), .Sum_o(stage5[0][6]), .Cout_o(stage5[1][7]) );
    HA ha5_07( .a_i(stage4[0][7]), .b_i(stage4[1][7]), .Sum_o(stage5[0][7]), .Cout_o(stage5[1][8]) );
    HA ha5_08( .a_i(stage4[0][8]), .b_i(stage4[1][8]), .Sum_o(stage5[0][8]), .Cout_o(stage5[1][9]) );
    HA ha5_09( .a_i(stage4[0][9]), .b_i(stage4[1][9]), .Sum_o(stage5[0][9]), .Cout_o(stage5[1][10]) );
    generate
        for (k=10; k<=31; k=k+1) begin: gen_stage5_1
            FA fa5_k( .a_i(stage4[0][k]), .b_i(stage4[1][k]), .c_i(stage4[2][k]), .Sum_o(stage5[0][k]), .Cout_o(stage5[1][k+1]) );
        end
    endgenerate

    assign stage5[2][20:15] = stage4[3][20:15];
    HA ha5_221( .a_i(stage4[3][21]), .b_i(stage4[4][21]), .Sum_o(stage5[2][21]), .Cout_o(stage5[3][22]) );
    HA ha5_222( .a_i(stage4[3][22]), .b_i(stage4[4][22]), .Sum_o(stage5[2][22]), .Cout_o(stage5[3][23]) );
    HA ha5_223( .a_i(stage4[3][23]), .b_i(stage4[4][23]), .Sum_o(stage5[2][23]), .Cout_o(stage5[3][24]) );
    HA ha5_224( .a_i(stage4[3][24]), .b_i(stage4[4][24]), .Sum_o(stage5[2][24]), .Cout_o(stage5[3][25]) );
    generate
        for (k=25; k<=31; k=k+1) begin: gen_stage5_2
            FA fa5_k( .a_i(stage4[3][k]), .b_i(stage4[4][k]), .c_i(stage4[5][k]), .Sum_o(stage5[2][k]), .Cout_o(stage5[3][k+1]) );
        end
    endgenerate
    assign stage5[4][31] = stage4[6][31];


    // stage 6: 5 -> 4
    wire [32:0] stage6 [0:3];

    assign stage6[0][5:0] = stage5[0][5:0];
    generate
        for (k=6; k<=14; k=k+1) begin: gen_stage6_1
            HA ha_6_k( .a_i(stage5[0][k]), .b_i(stage5[1][k]), .Sum_o(stage6[0][k]), .Cout_o(stage6[1][k+1]) );
        end
        for (k=15; k<=31; k=k+1) begin: gen_stage6_2
            FA fa_6_k( .a_i(stage5[0][k]), .b_i(stage5[1][k]), .c_i(stage5[2][k]), .Sum_o(stage6[0][k]), .Cout_o(stage6[1][k+1]) );
        end
    endgenerate

    assign stage6[2][31:22] = stage5[3][31:22];
    assign stage6[3][31] = stage5[4][31];

    // stage 7: 4 -> 3
    wire [32:0] stage7 [0:2];

    assign stage7[0][6:0] = stage6[0][6:0];
    generate
        for (k=7; k<=21; k=k+1) begin: gen_stage7_1
            HA ha_7_k( .a_i(stage6[0][k]), .b_i(stage6[1][k]), .Sum_o(stage7[0][k]), .Cout_o(stage7[1][k+1]) );
        end
        for (k=22; k<=31; k=k+1) begin: gen_stage7_2
            FA fa_7_k( .a_i(stage6[0][k]), .b_i(stage6[1][k]), .c_i(stage6[2][k]), .Sum_o(stage7[0][k]), .Cout_o(stage7[1][k+1]) );
        end
    endgenerate
    assign stage7[2][31] = stage6[3][31];

    // stage 8: 3 -> 2
    wire [32:0] stage8 [0:1];

    assign stage8[0][7:0] = stage7[0][7:0];
    generate
        for (k=8; k<=30; k=k+1) begin: gen_stage8_1
            HA ha_8_k( .a_i(stage7[0][k]), .b_i(stage7[1][k]), .Sum_o(stage8[0][k]), .Cout_o(stage8[1][k+1]) );
        end
    endgenerate
    FA fa_8_31( .a_i(stage7[0][31]), .b_i(stage7[1][31]), .c_i(stage7[2][31]), .Sum_o(stage8[0][31]) );

    // Output
    assign partialSum0_o = stage8[0];
    assign partialSum1_o = stage8[1][31:9];

endmodule

module Wallace_MUL_32_p2 (
    partialSum0_i,
    partialSum1_i,    
    Out_o
);   

    input [31:0] partialSum0_i;
    input [22:0] partialSum1_i;
    output [31:0] Out_o;

    assign Out_o = partialSum0_i + { partialSum1_i, 9'b0 };

endmodule

module HA(
    a_i, 
    b_i, 
    Sum_o, 
    Cout_o
);

input a_i, b_i; // a and b are inputs with size 1-bit
output Sum_o, Cout_o; // Sum and Cout are outputs with size 1-bit

assign Sum_o = a_i ^ b_i; 
assign Cout_o = a_i & b_i; 

endmodule


module FA(
    a_i, 
    b_i, 
    c_i,
    Sum_o, 
    Cout_o
);

input a_i, b_i, c_i; // a and b are inputs with size 1-bit
output Sum_o, Cout_o; // Sum and Cout are outputs with size 1-bit

assign Sum_o = a_i ^ b_i ^ c_i;
assign Cout_o = (a_i & b_i) | (b_i & c_i) | (a_i & c_i);

endmodule
