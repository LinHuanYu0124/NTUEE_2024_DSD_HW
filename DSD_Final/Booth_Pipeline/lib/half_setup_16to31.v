module half_setup_16to31(
    input clk,
    input rst_n,
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
    
    reg [31:0] multiplicand_r;
    reg [63:0] product_r;
    reg negative_r;
    assign product_o = product_r;
    assign acc[1] = acc16;
    assign Q[0] = Q15;
    assign q0[1] = q016;

    genvar i;
    for (i = 1; i <= 15; i = i + 1) begin
        booth_substep step(acc[i], Q[i-1], q0[i], multiplicand_r, acc[i+1], Q[i], q0[i+1]);
    end 
    booth_substep step31(acc[16], Q[15], q0[16], multiplicand_r, product[63:32], product[31:0], qout);
    
 
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            product_r <= 64'b0;
        end
        else begin
            multiplicand_r <= multiplicand_i;
            product_r <= (negative_i) ? ~product + 1 : product;
        end

    end
endmodule