//`include "./lib/booth_substep.v"
`include "./lib/half_setup_0to15.v"
`include "./lib/half_setup_16to31.v"
module booth_multiplier_32bit_pipeline(
    input clk,
    input rst_n,
    input signed[31:0] multiplier,
    input signed[31:0] multiplicand,
    output signed [63:0] product_o
    );

	wire signed [31:0] Q[0:30];  //an 8 bit (1byte) array, with a depth of 7 (0 to 6 rows of 1 byte each)
	wire signed [31:0] Q_nxt[0:30];  //an 8 bit (1byte) array, with a depth of 7 (0 to 6 rows of 1 byte each)
	wire signed [31:0] acc[0:31]; //an 8 bit (1byte) array, with a depth of 8 (0 to 7 rows of 1 byte each)
	wire signed [31:0] acc_nxt[0:31]; //an 8 bit (1byte) array, with a depth of 8 (0 to 7 rows of 1 byte each)
	wire signed[31:0] q0;
	wire signed[31:0] q0_nxt;
	wire qout;

    wire [31:0] Q15;
    wire        q016;
    wire [31:0] acc16;

    wire negative;

    wire [31:0] multiplicand_temp;

    wire [63:0] product_temp;

	
	assign acc[0] = 31'd0;   //initialising accumulator to 0

    // With pipeline =====================================================================
    
    half_setup_0to15  stage1(.clk(clk), .rst_n(rst_n), .multiplier_i(multiplier), 
                            .multiplicand_i(multiplicand), .acc16(acc16), .Q15(Q15), 
                            .q016(q016), .multiplicand_o(multiplicand_temp), .negative_o(negative));
    

    half_setup_16to31 stage2(.clk(clk), .rst_n(rst_n), .Q15(Q15), .q016(q016), 
                            .acc16(acc16), .multiplicand_i(multiplicand_temp), 
                            .negative_i(negative), .product_o(product_o));
    
endmodule


