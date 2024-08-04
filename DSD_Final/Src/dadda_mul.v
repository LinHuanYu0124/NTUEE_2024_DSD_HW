// A - 32 bits , B - 32 bits, Y(output) - 64 bits
//Here we used 16*16 dadda to implement 32*32.
module dadda_32(clk, rst_n, A, B, Out);
    input clk, rst_n;
    input [31:0] A;
    input [31:0] B; 
    output [31:0] Out;

//outputs of 16*16 dadda.      
    wire [31:0] y11,y12,y21,y22;

    wire [31:0] A_i, B_i, sign_nxt;
    wire [63:0] Y_o;

    assign A_i = A[31] ? (~A+1) : A;
    assign B_i = B[31] ? (~B+1) : B;
    assign sign_nxt = A[31] ^ B[31];

//sum and carry of final 2 stages.      
    wire [31:0] s_1, c_1; 
    wire [32:0] s_2, c_2;
    wire [15:0] s_3, c_3;
    wire [15:0] s_4, c_4;

    reg [48:0] middle_reg;
    reg [31:0] A_buffer;
    reg [15:0] B_left_buffer;
    reg sign;

    dadda_16 d1(.A(A_i[15:0]),.B(B_i[15:0]),.Y(y11));
    // assign Y[15:0] = y11[15:0];
    dadda_16 d2(.A(A_i[31:16]),.B(B_i[15:0]),.Y(y21));

    dadda_16 d3(.A(A_buffer[15:0]),.B(B_left_buffer),.Y(y12));
    dadda_16 d4(.A(A_buffer[31:16]),.B(B_left_buffer),.Y(y22));

    always @(posedge clk) begin
        if (!rst_n) begin
            A_buffer <= 32'b0;
            B_left_buffer <= 16'b0;
            sign <= 1'b0;
        end else begin
            A_buffer <= A_i;
            B_left_buffer <= B_i[31:16];
            sign <= sign_nxt;
        end
    end



//Stage 1 - reducing fom 3 to 2
    
    HA1 c_11(.a(y11[16]),.b(y21[0]),.Sum(s_1[0]),.Cout(c_1[0]));
    // assign Y[16] = s_1[0];
    csa_dadda c_12(.A(y11[17]),.B(y21[1]),.Cin(c_1[0]),.Y(s_1[1]),.Cout(c_1[1]));
    csa_dadda c_13(.A(y11[18]),.B(y21[2]),.Cin(c_1[1]),.Y(s_1[2]),.Cout(c_1[2]));
    csa_dadda c_14(.A(y11[19]),.B(y21[3]),.Cin(c_1[2]),.Y(s_1[3]),.Cout(c_1[3]));
    csa_dadda c_15(.A(y11[20]),.B(y21[4]),.Cin(c_1[3]),.Y(s_1[4]),.Cout(c_1[4]));
    csa_dadda c_16(.A(y11[21]),.B(y21[5]),.Cin(c_1[4]),.Y(s_1[5]),.Cout(c_1[5]));
    csa_dadda c_17(.A(y11[22]),.B(y21[6]),.Cin(c_1[5]),.Y(s_1[6]),.Cout(c_1[6]));
    csa_dadda c_18(.A(y11[23]),.B(y21[7]),.Cin(c_1[6]),.Y(s_1[7]),.Cout(c_1[7]));
    csa_dadda c_19(.A(y11[24]),.B(y21[8]),.Cin(c_1[7]),.Y(s_1[8]),.Cout(c_1[8]));
    csa_dadda c_110(.A(y11[25]),.B(y21[9]),.Cin(c_1[8]),.Y(s_1[9]),.Cout(c_1[9]));
    csa_dadda c_111(.A(y11[26]),.B(y21[10]),.Cin(c_1[9]),.Y(s_1[10]),.Cout(c_1[10]));
    csa_dadda c_112(.A(y11[27]),.B(y21[11]),.Cin(c_1[10]),.Y(s_1[11]),.Cout(c_1[11]));
    csa_dadda c_113(.A(y11[28]),.B(y21[12]),.Cin(c_1[11]),.Y(s_1[12]),.Cout(c_1[12]));
    csa_dadda c_114(.A(y11[29]),.B(y21[13]),.Cin(c_1[12]),.Y(s_1[13]),.Cout(c_1[13]));
    csa_dadda c_115(.A(y11[30]),.B(y21[14]),.Cin(c_1[13]),.Y(s_1[14]),.Cout(c_1[14]));
    csa_dadda c_116(.A(y11[31]),.B(y21[15]),.Cin(c_1[14]),.Y(s_1[15]),.Cout(c_1[15]));

    HA1 c_20(.a(y21[16]),.b(c_1[15]),.Sum(s_1[16]),.Cout(c_1[16]));
    HA1 c_21(.a(y21[17]),.b(c_1[16]),.Sum(s_1[17]),.Cout(c_1[17]));
    HA1 c_22(.a(y21[18]),.b(c_1[17]),.Sum(s_1[18]),.Cout(c_1[18]));
    HA1 c_23(.a(y21[19]),.b(c_1[18]),.Sum(s_1[19]),.Cout(c_1[19]));
    HA1 c_24(.a(y21[20]),.b(c_1[19]),.Sum(s_1[20]),.Cout(c_1[20]));
    HA1 c_25(.a(y21[21]),.b(c_1[20]),.Sum(s_1[21]),.Cout(c_1[21]));
    HA1 c_26(.a(y21[22]),.b(c_1[21]),.Sum(s_1[22]),.Cout(c_1[22]));
    HA1 c_27(.a(y21[23]),.b(c_1[22]),.Sum(s_1[23]),.Cout(c_1[23]));
    HA1 c_28(.a(y21[24]),.b(c_1[23]),.Sum(s_1[24]),.Cout(c_1[24]));
    HA1 c_29(.a(y21[25]),.b(c_1[24]),.Sum(s_1[25]),.Cout(c_1[25]));
    HA1 c_30(.a(y21[26]),.b(c_1[25]),.Sum(s_1[26]),.Cout(c_1[26]));
    HA1 c_31(.a(y21[27]),.b(c_1[26]),.Sum(s_1[27]),.Cout(c_1[27]));
    HA1 c_32(.a(y21[28]),.b(c_1[27]),.Sum(s_1[28]),.Cout(c_1[28]));
    HA1 c_33(.a(y21[29]),.b(c_1[28]),.Sum(s_1[29]),.Cout(c_1[29]));
    HA1 c_34(.a(y21[30]),.b(c_1[29]),.Sum(s_1[30]),.Cout(c_1[30]));
    HA1 c_35(.a(y21[31]),.b(c_1[30]),.Sum(s_1[31]),.Cout(c_1[31]));


    always @(posedge clk) begin
        if (!rst_n) begin
            middle_reg <= 48'b0;
        end else begin
            middle_reg <= {c_1[31], s_1, y11[15:0]};
        end
    end

    HA1 c_36(.a(y12[0]),.b(middle_reg[16]),.Sum(s_2[0]),.Cout(c_2[0]));
    csa_dadda c_37(.A(y12[1]),.B(middle_reg[17]),.Cin(c_2[0]),.Y(s_2[1]),.Cout(c_2[1]));
    csa_dadda c_38(.A(y12[2]),.B(middle_reg[18]),.Cin(c_2[1]),.Y(s_2[2]),.Cout(c_2[2]));
    csa_dadda c_39(.A(y12[3]),.B(middle_reg[19]),.Cin(c_2[2]),.Y(s_2[3]),.Cout(c_2[3]));
    csa_dadda c_40(.A(y12[4]),.B(middle_reg[20]),.Cin(c_2[3]),.Y(s_2[4]),.Cout(c_2[4]));
    csa_dadda c_41(.A(y12[5]),.B(middle_reg[21]),.Cin(c_2[4]),.Y(s_2[5]),.Cout(c_2[5]));
    csa_dadda c_42(.A(y12[6]),.B(middle_reg[22]),.Cin(c_2[5]),.Y(s_2[6]),.Cout(c_2[6]));
    csa_dadda c_43(.A(y12[7]),.B(middle_reg[23]),.Cin(c_2[6]),.Y(s_2[7]),.Cout(c_2[7]));
    csa_dadda c_44(.A(y12[8]),.B(middle_reg[24]),.Cin(c_2[7]),.Y(s_2[8]),.Cout(c_2[8]));
    csa_dadda c_45(.A(y12[9]),.B(middle_reg[25]),.Cin(c_2[8]),.Y(s_2[9]),.Cout(c_2[9]));
    csa_dadda c_46(.A(y12[10]),.B(middle_reg[26]),.Cin(c_2[9]),.Y(s_2[10]),.Cout(c_2[10]));
    csa_dadda c_47(.A(y12[11]),.B(middle_reg[27]),.Cin(c_2[10]),.Y(s_2[11]),.Cout(c_2[11]));
    csa_dadda c_48(.A(y12[12]),.B(middle_reg[28]),.Cin(c_2[11]),.Y(s_2[12]),.Cout(c_2[12]));
    csa_dadda c_49(.A(y12[13]),.B(middle_reg[29]),.Cin(c_2[12]),.Y(s_2[13]),.Cout(c_2[13]));
    csa_dadda c_50(.A(y12[14]),.B(middle_reg[30]),.Cin(c_2[13]),.Y(s_2[14]),.Cout(c_2[14]));
    csa_dadda c_51(.A(y12[15]),.B(middle_reg[31]),.Cin(c_2[14]),.Y(s_2[15]),.Cout(c_2[15]));

    csa_dadda c_117(.A(y22[0]),.B(y12[16]),.Cin(middle_reg[32]),.Y(s_2[16]),.Cout(c_2[16]));
    csa_dadda c_118(.A(y22[1]),.B(y12[17]),.Cin(middle_reg[33]),.Y(s_2[17]),.Cout(c_2[17]));
    csa_dadda c_119(.A(y22[2]),.B(y12[18]),.Cin(middle_reg[34]),.Y(s_2[18]),.Cout(c_2[18]));
    csa_dadda c_120(.A(y22[3]),.B(y12[19]),.Cin(middle_reg[35]),.Y(s_2[19]),.Cout(c_2[19]));
    csa_dadda c_121(.A(y22[4]),.B(y12[20]),.Cin(middle_reg[36]),.Y(s_2[20]),.Cout(c_2[20]));
    csa_dadda c_122(.A(y22[5]),.B(y12[21]),.Cin(middle_reg[37]),.Y(s_2[21]),.Cout(c_2[21]));
    csa_dadda c_123(.A(y22[6]),.B(y12[22]),.Cin(middle_reg[38]),.Y(s_2[22]),.Cout(c_2[22]));
    csa_dadda c_124(.A(y22[7]),.B(y12[23]),.Cin(middle_reg[39]),.Y(s_2[23]),.Cout(c_2[23]));
    csa_dadda c_125(.A(y22[8]),.B(y12[24]),.Cin(middle_reg[40]),.Y(s_2[24]),.Cout(c_2[24]));
    csa_dadda c_126(.A(y22[9]),.B(y12[25]),.Cin(middle_reg[41]),.Y(s_2[25]),.Cout(c_2[25]));
    csa_dadda c_127(.A(y22[10]),.B(y12[26]),.Cin(middle_reg[42]),.Y(s_2[26]),.Cout(c_2[26]));
    csa_dadda c_128(.A(y22[11]),.B(y12[27]),.Cin(middle_reg[43]),.Y(s_2[27]),.Cout(c_2[27]));
    csa_dadda c_129(.A(y22[12]),.B(y12[28]),.Cin(middle_reg[44]),.Y(s_2[28]),.Cout(c_2[28]));
    csa_dadda c_130(.A(y22[13]),.B(y12[29]),.Cin(middle_reg[45]),.Y(s_2[29]),.Cout(c_2[29]));
    csa_dadda c_131(.A(y22[14]),.B(y12[30]),.Cin(middle_reg[46]),.Y(s_2[30]),.Cout(c_2[30]));
    csa_dadda c_132(.A(y22[15]),.B(y12[31]),.Cin(middle_reg[47]),.Y(s_2[31]),.Cout(c_2[31]));
    csa_dadda c_133(.A(y22[16]),.B(c_2[31]),.Cin(middle_reg[48]),.Y(s_2[32]),.Cout(c_2[32]));

    HA1 c_200(.a(c_2[15]),.b(s_2[16]),.Sum(s_3[0]),.Cout(c_3[0]));
    csa_dadda c_52(.A(c_2[16]),.B(s_2[17]),.Cin(c_3[0]),.Y(s_3[1]),.Cout(c_3[1]));
    csa_dadda c_53(.A(c_2[17]),.B(s_2[18]),.Cin(c_3[1]),.Y(s_3[2]),.Cout(c_3[2]));
    csa_dadda c_54(.A(c_2[18]),.B(s_2[19]),.Cin(c_3[2]),.Y(s_3[3]),.Cout(c_3[3]));
    csa_dadda c_55(.A(c_2[19]),.B(s_2[20]),.Cin(c_3[3]),.Y(s_3[4]),.Cout(c_3[4]));
    csa_dadda c_56(.A(c_2[20]),.B(s_2[21]),.Cin(c_3[4]),.Y(s_3[5]),.Cout(c_3[5]));
    csa_dadda c_57(.A(c_2[21]),.B(s_2[22]),.Cin(c_3[5]),.Y(s_3[6]),.Cout(c_3[6]));
    csa_dadda c_58(.A(c_2[22]),.B(s_2[23]),.Cin(c_3[6]),.Y(s_3[7]),.Cout(c_3[7]));
    csa_dadda c_59(.A(c_2[23]),.B(s_2[24]),.Cin(c_3[7]),.Y(s_3[8]),.Cout(c_3[8]));
    csa_dadda c_60(.A(c_2[24]),.B(s_2[25]),.Cin(c_3[8]),.Y(s_3[9]),.Cout(c_3[9]));
    csa_dadda c_61(.A(c_2[25]),.B(s_2[26]),.Cin(c_3[9]),.Y(s_3[10]),.Cout(c_3[10]));
    csa_dadda c_62(.A(c_2[26]),.B(s_2[27]),.Cin(c_3[10]),.Y(s_3[11]),.Cout(c_3[11]));
    csa_dadda c_63(.A(c_2[27]),.B(s_2[28]),.Cin(c_3[11]),.Y(s_3[12]),.Cout(c_3[12]));
    csa_dadda c_64(.A(c_2[28]),.B(s_2[29]),.Cin(c_3[12]),.Y(s_3[13]),.Cout(c_3[13]));
    csa_dadda c_65(.A(c_2[29]),.B(s_2[30]),.Cin(c_3[13]),.Y(s_3[14]),.Cout(c_3[14]));
    csa_dadda c_66(.A(c_2[30]),.B(s_2[31]),.Cin(c_3[14]),.Y(s_3[15]),.Cout(c_3[15]));

    HA1 c_201(.a(s_2[32]),.b(c_3[15]),.Sum(s_4[0]),.Cout(c_4[0]));
    csa_dadda c_67(.A(y22[17]),.B(c_2[32]),.Cin(c_4[0]),.Y(s_4[1]),.Cout(c_4[1]));
    HA1 c_202(.a(y22[18]),.b(c_4[1]),.Sum(s_4[2]),.Cout(c_4[2]));
    HA1 c_203(.a(y22[19]),.b(c_4[2]),.Sum(s_4[3]),.Cout(c_4[3]));
    HA1 c_204(.a(y22[20]),.b(c_4[3]),.Sum(s_4[4]),.Cout(c_4[4]));
    HA1 c_205(.a(y22[21]),.b(c_4[4]),.Sum(s_4[5]),.Cout(c_4[5]));
    HA1 c_206(.a(y22[22]),.b(c_4[5]),.Sum(s_4[6]),.Cout(c_4[6]));
    HA1 c_207(.a(y22[23]),.b(c_4[6]),.Sum(s_4[7]),.Cout(c_4[7]));
    HA1 c_208(.a(y22[24]),.b(c_4[7]),.Sum(s_4[8]),.Cout(c_4[8]));
    HA1 c_209(.a(y22[25]),.b(c_4[8]),.Sum(s_4[9]),.Cout(c_4[9]));
    HA1 c_210(.a(y22[26]),.b(c_4[9]),.Sum(s_4[10]),.Cout(c_4[10]));
    HA1 c_211(.a(y22[27]),.b(c_4[10]),.Sum(s_4[11]),.Cout(c_4[11]));
    HA1 c_212(.a(y22[28]),.b(c_4[11]),.Sum(s_4[12]),.Cout(c_4[12]));
    HA1 c_213(.a(y22[29]),.b(c_4[12]),.Sum(s_4[13]),.Cout(c_4[13]));
    HA1 c_214(.a(y22[30]),.b(c_4[13]),.Sum(s_4[14]),.Cout(c_4[14]));
    HA1 c_215(.a(y22[31]),.b(c_4[14]),.Sum(s_4[15]),.Cout(c_4[15]));

    assign Y_o = {s_4, s_3, s_2[15:0], middle_reg[15:0]};

    assign Out = sign ? (~Y_o[31:0]) + 1 : Y_o[31:0];

endmodule

module dadda_16(A,B,Y);
    
    input [15:0]A;
    input [15:0]B;
    
    output wire [31:0] Y;

//outputs of 8*8 dadda.    
    wire [15:0] y11,y12,y21,y22;

//sum and carry of final 2 stages.     
    wire [15:0] s_1,c_1;    
    wire [22:0] c_2;
    
    dadda_8 d1(.A(A[7:0]),.B(B[7:0]),.y(y11));
    dadda_8 d2(.A(A[7:0]),.B(B[15:8]),.y(y12));
    dadda_8 d3(.A(A[15:8]),.B(B[7:0]),.y(y21));
    dadda_8 d4(.A(A[15:8]),.B(B[15:8]),.y(y22));

    assign Y[7:0] = y11[7:0];
    
//Stage 1 - reducing fom 3 to 2
    
    csa_dadda c_11(.A(y11[8]),.B(y12[0]),.Cin(y21[0]),.Y(s_1[0]),.Cout(c_1[0]));

    assign Y[8] = s_1[0];

    csa_dadda c_12(.A(y11[9]),.B(y12[1]),.Cin(y21[1]),.Y(s_1[1]),.Cout(c_1[1]));
    csa_dadda c_13(.A(y11[10]),.B(y12[2]),.Cin(y21[2]),.Y(s_1[2]),.Cout(c_1[2]));
    csa_dadda c_14(.A(y11[11]),.B(y12[3]),.Cin(y21[3]),.Y(s_1[3]),.Cout(c_1[3]));
    csa_dadda c_15(.A(y11[12]),.B(y12[4]),.Cin(y21[4]),.Y(s_1[4]),.Cout(c_1[4]));
    csa_dadda c_16(.A(y11[13]),.B(y12[5]),.Cin(y21[5]),.Y(s_1[5]),.Cout(c_1[5]));
    csa_dadda c_17(.A(y11[14]),.B(y12[6]),.Cin(y21[6]),.Y(s_1[6]),.Cout(c_1[6]));
    csa_dadda c_18(.A(y11[15]),.B(y12[7]),.Cin(y21[7]),.Y(s_1[7]),.Cout(c_1[7]));

    csa_dadda c_19(.A(y22[0]),.B(y12[8]),.Cin(y21[8]),.Y(s_1[8]),.Cout(c_1[8]));
    csa_dadda c_110(.A(y22[1]),.B(y12[9]),.Cin(y21[9]),.Y(s_1[9]),.Cout(c_1[9]));
    csa_dadda c_111(.A(y22[2]),.B(y12[10]),.Cin(y21[10]),.Y(s_1[10]),.Cout(c_1[10]));
    csa_dadda c_112(.A(y22[3]),.B(y12[11]),.Cin(y21[11]),.Y(s_1[11]),.Cout(c_1[11]));
    csa_dadda c_113(.A(y22[4]),.B(y12[12]),.Cin(y21[12]),.Y(s_1[12]),.Cout(c_1[12]));
    csa_dadda c_114(.A(y22[5]),.B(y12[13]),.Cin(y21[13]),.Y(s_1[13]),.Cout(c_1[13]));
    csa_dadda c_115(.A(y22[6]),.B(y12[14]),.Cin(y21[14]),.Y(s_1[14]),.Cout(c_1[14]));
    csa_dadda c_116(.A(y22[7]),.B(y12[15]),.Cin(y21[15]),.Y(s_1[15]),.Cout(c_1[15]));
    
//Stage 2 - reducing fom 2 to 1
        // adding total sum and carry to get final output
    HA1 h1(.a(s_1[1]),.b(c_1[0]),.Sum(Y[9]),.Cout(c_2[0]));


    csa_dadda c_22(.A(s_1[2]),.B(c_1[1]),.Cin(c_2[0]),.Y(Y[10]),.Cout(c_2[1]));
    csa_dadda c_23(.A(s_1[3]),.B(c_1[2]),.Cin(c_2[1]),.Y(Y[11]),.Cout(c_2[2]));
    csa_dadda c_24(.A(s_1[4]),.B(c_1[3]),.Cin(c_2[2]),.Y(Y[12]),.Cout(c_2[3]));
    csa_dadda c_25(.A(s_1[5]),.B(c_1[4]),.Cin(c_2[3]),.Y(Y[13]),.Cout(c_2[4]));
    csa_dadda c_26(.A(s_1[6]),.B(c_1[5]),.Cin(c_2[4]),.Y(Y[14]),.Cout(c_2[5]));
    csa_dadda c_27(.A(s_1[7]),.B(c_1[6]),.Cin(c_2[5]),.Y(Y[15]),.Cout(c_2[6]));
    csa_dadda c_28(.A(s_1[8]),.B(c_1[7]),.Cin(c_2[6]),.Y(Y[16]),.Cout(c_2[7]));
    csa_dadda c_29(.A(s_1[9]),.B(c_1[8]),.Cin(c_2[7]),.Y(Y[17]),.Cout(c_2[8]));
    csa_dadda c_210(.A(s_1[10]),.B(c_1[9]),.Cin(c_2[8]),.Y(Y[18]),.Cout(c_2[9]));
    csa_dadda c_211(.A(s_1[11]),.B(c_1[10]),.Cin(c_2[9]),.Y(Y[19]),.Cout(c_2[10]));
    csa_dadda c_212(.A(s_1[12]),.B(c_1[11]),.Cin(c_2[10]),.Y(Y[20]),.Cout(c_2[11]));
    csa_dadda c_213(.A(s_1[13]),.B(c_1[12]),.Cin(c_2[11]),.Y(Y[21]),.Cout(c_2[12]));
    csa_dadda c_214(.A(s_1[14]),.B(c_1[13]),.Cin(c_2[12]),.Y(Y[22]),.Cout(c_2[13]));
    csa_dadda c_215(.A(s_1[15]),.B(c_1[14]),.Cin(c_2[13]),.Y(Y[23]),.Cout(c_2[14]));
    csa_dadda c_216(.A(y22[8]),.B(c_1[15]),.Cin(c_2[14]),.Y(Y[24]),.Cout(c_2[15]));

    HA1 h2(.a(y22[9]),.b(c_2[15]),.Sum(Y[25]),.Cout(c_2[16]));
    HA1 h3(.a(y22[10]),.b(c_2[16]),.Sum(Y[26]),.Cout(c_2[17]));
    HA1 h4(.a(y22[11]),.b(c_2[17]),.Sum(Y[27]),.Cout(c_2[18]));
    HA1 h5(.a(y22[12]),.b(c_2[18]),.Sum(Y[28]),.Cout(c_2[19]));
    HA1 h6(.a(y22[13]),.b(c_2[19]),.Sum(Y[29]),.Cout(c_2[20]));
    HA1 h7(.a(y22[14]),.b(c_2[20]),.Sum(Y[30]),.Cout(c_2[21]));
    HA1 h8(.a(y22[15]),.b(c_2[21]),.Sum(Y[31]),.Cout(c_2[22]));
    
endmodule

module dadda_8(A,B,y);
    
    input [7:0] A;
    input [7:0] B;
    output wire [15:0] y;

    reg  dot [0:7][7:0];


// stage-1 sum and carry
    wire [0:5] s1,c1;
// stage-2 sum and carry
    wire [0:13] s2,c2;   
// stage-3 sum and carry
    wire [0:9] s3,c3;
// stage-4 sum and carry
    wire [0:11] s4,c4;
// stage-5 sum and carry
    wire [0:13] s5,c5;

// generating partial products 
integer i;
integer j;

always @(*) begin
    for(i=0; i<8; i=i+1) begin
        for(j=0; j<8; j=j+1) begin
            dot[i][j] = A[j] & B[i];
        end
    end
end

 

//Reduction by stages.
// di_values = 2,3,4,6,8,13...

//Stage 1 - reducing fom 8 to 6  


    HA1 h1(.a(dot[6][0]),.b(dot[5][1]),.Sum(s1[0]),.Cout(c1[0]));
    HA1 h2(.a(dot[4][3]),.b(dot[3][4]),.Sum(s1[2]),.Cout(c1[2]));
    HA1 h3(.a(dot[4][4]),.b(dot[3][5]),.Sum(s1[4]),.Cout(c1[4]));

    csa_dadda c11(.A(dot[7][0]),.B(dot[6][1]),.Cin(dot[5][2]),.Y(s1[1]),.Cout(c1[1]));
    csa_dadda c12(.A(dot[7][1]),.B(dot[6][2]),.Cin(dot[5][3]),.Y(s1[3]),.Cout(c1[3]));     
    csa_dadda c13(.A(dot[7][2]),.B(dot[6][3]),.Cin(dot[5][4]),.Y(s1[5]),.Cout(c1[5]));
    
//Stage 2 - reducing fom 6 to 4

    HA1 h4(.a(dot[4][0]),.b(dot[3][1]),.Sum(s2[0]),.Cout(c2[0]));
    HA1 h5(.a(dot[2][3]),.b(dot[1][4]),.Sum(s2[2]),.Cout(c2[2]));


    csa_dadda c21(.A(dot[5][0]),.B(dot[4][1]),.Cin(dot[3][2]),.Y(s2[1]),.Cout(c2[1]));
    csa_dadda c22(.A(s1[0]),.B(dot[4][2]),.Cin(dot[3][3]),.Y(s2[3]),.Cout(c2[3]));
    csa_dadda c23(.A(dot[2][4]),.B(dot[1][5]),.Cin(dot[0][6]),.Y(s2[4]),.Cout(c2[4]));
    csa_dadda c24(.A(s1[1]),.B(s1[2]),.Cin(c1[0]),.Y(s2[5]),.Cout(c2[5]));
    csa_dadda c25(.A(dot[2][5]),.B(dot[1][6]),.Cin(dot[0][7]),.Y(s2[6]),.Cout(c2[6]));
    csa_dadda c26(.A(s1[3]),.B(s1[4]),.Cin(c1[1]),.Y(s2[7]),.Cout(c2[7]));
    csa_dadda c27(.A(c1[2]),.B(dot[2][6]),.Cin(dot[1][7]),.Y(s2[8]),.Cout(c2[8]));
    csa_dadda c28(.A(s1[5]),.B(c1[3]),.Cin(c1[4]),.Y(s2[9]),.Cout(c2[9]));
    csa_dadda c29(.A(dot[4][5]),.B(dot[3][6]),.Cin(dot[2][7]),.Y(s2[10]),.Cout(c2[10]));
    csa_dadda c210(.A(dot[7][3]),.B(c1[5]),.Cin(dot[6][4]),.Y(s2[11]),.Cout(c2[11]));
    csa_dadda c211(.A(dot[5][5]),.B(dot[4][6]),.Cin(dot[3][7]),.Y(s2[12]),.Cout(c2[12]));
    csa_dadda c212(.A(dot[7][4]),.B(dot[6][5]),.Cin(dot[5][6]),.Y(s2[13]),.Cout(c2[13]));
    
//Stage 3 - reducing fom 4 to 3

    HA1 h6(.a(dot[3][0]),.b(dot[2][1]),.Sum(s3[0]),.Cout(c3[0]));

    csa_dadda c31(.A(s2[0]),.B(dot[2][2]),.Cin(dot[1][3]),.Y(s3[1]),.Cout(c3[1]));
    csa_dadda c32(.A(s2[1]),.B(s2[2]),.Cin(c2[0]),.Y(s3[2]),.Cout(c3[2]));
    csa_dadda c33(.A(c2[1]),.B(c2[2]),.Cin(s2[3]),.Y(s3[3]),.Cout(c3[3]));
    csa_dadda c34(.A(c2[3]),.B(c2[4]),.Cin(s2[5]),.Y(s3[4]),.Cout(c3[4]));
    csa_dadda c35(.A(c2[5]),.B(c2[6]),.Cin(s2[7]),.Y(s3[5]),.Cout(c3[5]));
    csa_dadda c36(.A(c2[7]),.B(c2[8]),.Cin(s2[9]),.Y(s3[6]),.Cout(c3[6]));
    csa_dadda c37(.A(c2[9]),.B(c2[10]),.Cin(s2[11]),.Y(s3[7]),.Cout(c3[7]));
    csa_dadda c38(.A(c2[11]),.B(c2[12]),.Cin(s2[13]),.Y(s3[8]),.Cout(c3[8]));
    csa_dadda c39(.A(dot[7][5]),.B(dot[6][6]),.Cin(dot[5][7]),.Y(s3[9]),.Cout(c3[9]));

//Stage 4 - reducing fom 3 to 2

    HA1 h7(.a(dot[2][0]),.b(dot[1][1]),.Sum(s4[0]),.Cout(c4[0]));


    csa_dadda c41(.A(s3[0]),.B(dot[1][2]),.Cin(dot[0][3]),.Y(s4[1]),.Cout(c4[1]));
    csa_dadda c42(.A(c3[0]),.B(s3[1]),.Cin(dot[0][4]),.Y(s4[2]),.Cout(c4[2]));
    csa_dadda c43(.A(c3[1]),.B(s3[2]),.Cin(dot[0][5]),.Y(s4[3]),.Cout(c4[3]));
    csa_dadda c44(.A(c3[2]),.B(s3[3]),.Cin(s2[4]),.Y(s4[4]),.Cout(c4[4]));
    csa_dadda c45(.A(c3[3]),.B(s3[4]),.Cin(s2[6]),.Y(s4[5]),.Cout(c4[5]));
    csa_dadda c46(.A(c3[4]),.B(s3[5]),.Cin(s2[8]),.Y(s4[6]),.Cout(c4[6]));
    csa_dadda c47(.A(c3[5]),.B(s3[6]),.Cin(s2[10]),.Y(s4[7]),.Cout(c4[7]));
    csa_dadda c48(.A(c3[6]),.B(s3[7]),.Cin(s2[12]),.Y(s4[8]),.Cout(c4[8]));
    csa_dadda c49(.A(c3[7]),.B(s3[8]),.Cin(dot[4][7]),.Y(s4[9]),.Cout(c4[9]));
    csa_dadda c410(.A(c3[8]),.B(s3[9]),.Cin(c2[13]),.Y(s4[10]),.Cout(c4[10]));
    csa_dadda c411(.A(c3[9]),.B(dot[7][6]),.Cin(dot[6][7]),.Y(s4[11]),.Cout(c4[11]));
    
//Stage 5 - reducing fom 2 to 1
    // adding total sum and carry to get final output

    HA1 h8(.a(dot[1][0]),.b(dot[0][1]),.Sum(y[1]),.Cout(c5[0]));

    csa_dadda c51(.A(s4[0]),.B(dot[0][2]),.Cin(c5[0]),.Y(y[2]),.Cout(c5[1]));
    csa_dadda c52(.A(c4[0]),.B(s4[1]),.Cin(c5[1]),.Y(y[3]),.Cout(c5[2]));
    csa_dadda c54(.A(c4[1]),.B(s4[2]),.Cin(c5[2]),.Y(y[4]),.Cout(c5[3]));
    csa_dadda c55(.A(c4[2]),.B(s4[3]),.Cin(c5[3]),.Y(y[5]),.Cout(c5[4]));
    csa_dadda c56(.A(c4[3]),.B(s4[4]),.Cin(c5[4]),.Y(y[6]),.Cout(c5[5]));
    csa_dadda c57(.A(c4[4]),.B(s4[5]),.Cin(c5[5]),.Y(y[7]),.Cout(c5[6]));
    csa_dadda c58(.A(c4[5]),.B(s4[6]),.Cin(c5[6]),.Y(y[8]),.Cout(c5[7]));
    csa_dadda c59(.A(c4[6]),.B(s4[7]),.Cin(c5[7]),.Y(y[9]),.Cout(c5[8]));
    csa_dadda c510(.A(c4[7]),.B(s4[8]),.Cin(c5[8]),.Y(y[10]),.Cout(c5[9]));
    csa_dadda c511(.A(c4[8]),.B(s4[9]),.Cin(c5[9]),.Y(y[11]),.Cout(c5[10]));
    csa_dadda c512(.A(c4[9]),.B(s4[10]),.Cin(c5[10]),.Y(y[12]),.Cout(c5[11]));
    csa_dadda c513(.A(c4[10]),.B(s4[11]),.Cin(c5[11]),.Y(y[13]),.Cout(c5[12]));
    csa_dadda c514(.A(c4[11]),.B(dot[7][7]),.Cin(c5[12]),.Y(y[14]),.Cout(c5[13]));

    assign y[0] =  dot[0][0];
    assign y[15] = c5[13];

endmodule 

module csa_dadda(A,B,Cin,Y,Cout);
    input A,B,Cin;
    output Y,Cout;
        
    assign Y = A^B^Cin;
    assign Cout = (A&B)|(A&Cin)|(B&Cin);
    
endmodule

module HA1(a, b, Sum, Cout);

input a, b; // a and b are inputs with size 1-bit
output Sum, Cout; // Sum and Cout are outputs with size 1-bit

assign Sum = a ^ b; 
assign Cout = a & b; 

endmodule
