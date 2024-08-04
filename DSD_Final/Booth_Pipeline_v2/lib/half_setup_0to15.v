module half_setup_0to15(
    input clk,
    input rst_n,
    input signed[31:0] multiplier_i,
    input signed[31:0] multiplicand_i,
    output signed [31:0] multiplicand_o,
    output signed [31:0] Q15,
    output signed        q016,
    output signed [31:0] acc16,
    output reg negative_o  
    );
	wire signed [31:0] Q[0:15];  //an 8 bit (1byte) array, with a depth of 7 (0 to 6 rows of 1 byte each)
	wire signed [31:0] acc[0:16]; //an 8 bit (1byte) array, with a depth of 8 (0 to 7 rows of 1 byte each)
	wire signed        q0[0:16];
    
    wire negative;
    assign negative = ((multiplier_i[31] && !multiplicand_i[31]) || (multiplicand_i[31] && !multiplier_i[31])) ? 1'b1 : 1'b0;

    wire [31:0] multiplicand;
    assign multiplicand = (multiplicand_i[31] == 1) ? ~multiplicand_i+1 : multiplicand_i;
    assign multiplicand_o = multiplicand;
    // assign multiplicand_o = multiplicand_i;
    
    wire [31:0] multiplier;
    assign multiplier = (multiplier_i[31] == 1) ? ~multiplier_i+1 : multiplier_i;

    reg signed [31:0] acc16_r;
    reg signed [31:0] Q15_r;
    reg signed        q016_r;

    assign Q15 = Q15_r;
    assign q016 = q016_r;
    assign acc16 = acc16_r;
    
    assign acc[0] = 31'd0;   //initialising accumulator to 0
    assign q0[0] = 1'b0;   //initialising q0 to 0

    booth_substep step1(acc[0], multiplier, q0[0], multiplicand, acc[1], Q[0], q0[1]);
    genvar i;
    for (i = 1; i <= 15; i = i + 1) begin
        booth_substep step(acc[i], Q[i-1], q0[i], multiplicand, acc[i+1], Q[i], q0[i+1]);
    end 

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            acc16_r <= 32'b0;
            Q15_r   <= 32'b0;
            q016_r  <= 1'b0;
            negative_o <= 1'b0;
        end
        else begin
            acc16_r <= acc[16];
            Q15_r   <= Q[15];
            q016_r  <= q0[16];
            negative_o <= negative;
        end

    end
endmodule