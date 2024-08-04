module booth_multiplier_32bit_pipeline(
    input clk,
    input rst_n,
    input signed[31:0] A,
    input signed[31:0] B,
    output signed [31:0] Out
);

    wire [31:0] Q15_nxt, acc16_nxt, multiplicand_temp_nxt;
    reg [31:0] Q15, acc16, multiplicand_temp;

    wire q016_nxt;
    reg q016;

    wire negative_nxt;
    reg negative;

    wire [63:0] product;

    assign Out = product[31:0];

    always @(posedge clk) begin
        if(~rst_n) begin
            Q15 <= 32'b0;
            q016 <= 1'b0;
            acc16 <= 32'b0;
            negative <= 1'b0;
            multiplicand_temp <= 32'b0;
        end else begin
            Q15 <= Q15_nxt;
            q016 <= q016_nxt;
            acc16 <= acc16_nxt;
            negative <= negative_nxt;
            multiplicand_temp <= multiplicand_temp_nxt;
        end
    end

    // With pipeline =====================================================================
    
    half_setup_0to15  stage1(.multiplier_i(A), 
                            .multiplicand_i(B), .acc16(acc16_nxt), .Q15(Q15_nxt), 
                            .q016(q016_nxt), .multiplicand_o(multiplicand_temp_nxt), .negative_o(negative_nxt));
    

    half_setup_16to31 stage2(.Q15(Q15), .q016(q016), 
                            .acc16(acc16), .multiplicand_i(multiplicand_temp), 
                            .negative_i(negative), .product_o(product));
    
endmodule

module half_setup_0to15(
    input signed[31:0] multiplier_i,
    input signed[31:0] multiplicand_i,
    output signed [31:0] multiplicand_o,
    output signed [31:0] Q15,
    output signed        q016,
    output signed [31:0] acc16,
    output negative_o  
);
	wire signed [31:0] Q[0:15];  //an 8 bit (1byte) array, with a depth of 7 (0 to 6 rows of 1 byte each)
	wire signed [31:0] acc[0:16]; //an 8 bit (1byte) array, with a depth of 8 (0 to 7 rows of 1 byte each)
	wire signed        q0[0:16];
    
    assign negative_o = ((multiplier_i[31] && !multiplicand_i[31]) || (multiplicand_i[31] && !multiplier_i[31])) ? 1'b1 : 1'b0;

    wire [31:0] multiplicand;
    assign multiplicand = (multiplicand_i[31] == 1) ? ~multiplicand_i+1 : multiplicand_i;
    assign multiplicand_o = multiplicand;
    
    wire [31:0] multiplier;
    assign multiplier = (multiplier_i[31] == 1) ? ~multiplier_i+1 : multiplier_i;

    assign Q15 = Q[15];
    assign q016 = q0[16];
    assign acc16 = acc[16];
    
    assign acc[0] = 31'd0;   //initialising accumulator to 0
    assign q0[0] = 1'b0;   //initialising q0 to 0

    booth_substep step1(acc[0], multiplier, q0[0], multiplicand, acc[1], Q[0], q0[1]);
    
    genvar i;
    generate
        for (i = 1; i <= 15; i = i + 1) begin : step_block
            booth_substep step(acc[i], Q[i-1], q0[i], multiplicand, acc[i+1], Q[i], q0[i+1]);
        end
    endgenerate
endmodule

module half_setup_16to31(
    input signed[31:0] Q15,
    input signed       q016,
    input signed[31:0] acc16,
    input signed[31:0] multiplicand_i,
    output signed [63:0] product_o,
    input negative_i
);

    wire signed [31:0] acc[0:16];
    wire signed [31:0] Q[0:15];
    wire signed        q0[0:16];
    wire signed        qout;
    wire signed [63:0] product;
    

    assign product_o = (negative_i) ? ~product + 1 : product;
    assign acc[1] = acc16;
    assign Q[0] = Q15;
    assign q0[1] = q016;

    genvar i;

    generate
        for (i = 1; i <= 15; i = i + 1) begin : step_block
            booth_substep step(acc[i], Q[i-1], q0[i], multiplicand_i, acc[i+1], Q[i], q0[i+1]);
        end
    endgenerate

    booth_substep step31(acc[16], Q[15], q0[16], multiplicand_i, product[63:32], product[31:0], qout);
    
 
endmodule

module adder_subractor(
    input wire cin,
    input wire [31:0] i0,i1,
    output wire [31:0] sum);

	wire cout;
	wire [31:0] temp;
	reg [31:0] int_ip; //intermediate input - processed from the inputs and fed into fa module 
	
    //if cin == 1, int_ip = 1's complement
    //else int_ip = i1

    integer i;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            int_ip[i] = i1[i] ^ cin;
        end
    end
    
    //if cin == 1, cin added to make two's complement
    //else addition takes place
    //fa fa1(i0[0], int_ip[0], cin,     sum[0], temp[0]);


    assign sum[0] = i0[0] ^ int_ip[0] ^ cin;
    assign temp[0] = (i0[0] & int_ip[0]) | (int_ip[0] & cin) | (cin & i0[0]);

    genvar j;
    generate
        for (j = 1; j < 32; j = j + 1) begin : fa_block
            fa fa(i0[j], int_ip[j], temp[j-1], sum[j], temp[j]);
        end
    endgenerate

    // assign cout = i0[31] & int_ip[31] | int_ip[31] & temp[30] | temp[30] & i0[31];
endmodule

module booth_substep(
    input wire signed [31:0] acc,    //Current value of accumulator
    input wire signed [31:0] Q,  //Current value of Q (initially the multiplier)    
    input wire signed q0,       //Current value of q-1 th bit
    input wire signed [31:0] multiplicand,  //the multipliand
    output reg signed [31:0] next_acc,   //next accumulator value || value of 8 MSB's of 16 bit output [17:8]
    output reg signed [31:0] next_Q, //Next value of Q || value of 8 LSB's of 16 bit output [7:0]
    output reg q0_next
);
    
	wire [31:0] addsub_temp;  //next value of q_-1 th bit
	
    adder_subractor myadd(Q[0], acc, multiplicand, addsub_temp);

    always @(*) begin	
        if(Q[0] == q0) begin
            q0_next = Q[0];
            next_Q = Q>>1;
            next_Q[31] = acc[0];
            
            //  Right shift
            next_acc = acc>>1;
            
            //  With sign extension
            if (acc[31] == 1) begin
                next_acc[31] = 1;
            end
        end

        else begin        //if Q[0] != q0 (that is,  q_-1 bit)
            q0_next = Q[0];
            next_Q = Q>>1;
            next_Q[31] = addsub_temp[0];
            
            //Right s1hift
            next_acc = addsub_temp>>1;
            
            //  With sign extension
            if (addsub_temp[31] == 1) begin
                next_acc[31] = 1;
            end
        end	
    end	
endmodule 

//lib.v
//xor module
module xor2 (input wire i0, i1, output wire o);
  assign o = i0 ^ i1;
endmodule


//full adder module
module fa ( input wire i0, i1, cin, output wire sum, cout);
    assign sum = i0 ^ i1 ^ cin;
    assign cout = (i0 & i1) | (i1 & cin) | (cin & i0);
endmodule



