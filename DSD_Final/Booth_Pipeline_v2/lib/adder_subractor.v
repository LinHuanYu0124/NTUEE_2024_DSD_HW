`include "./lib/gates.v"
module adder_subractor(
    input wire cin,
    input wire [31:0] i0,i1,
    output wire [31:0] sum);

	wire cout;
	wire [31:0] temp;
	wire [31:0] int_ip; //intermediate input - processed from the inputs and fed into fa module 
	
    //if cin == 1, int_ip = 1's complement
    //else int_ip = i1
    genvar i;
    for (i = 0; i < 32; i = i + 1) begin
        assign int_ip[i] = i1[i] ^ cin;
    end
    
    //if cin == 1, cin added to make two's complement
    //else addition takes place
    //fa fa1(i0[0], int_ip[0], cin,     sum[0], temp[0]);


    assign sum[0] = i0[0] ^ int_ip[0] ^ cin;
    assign temp[0] = (i0[0] & int_ip[0]) | (int_ip[0] & cin) | (cin & i0[0]);
    for (i = 1; i < 32; i = i + 1) begin
        fa fa(i0[i], int_ip[i], temp[i-1], sum[i], temp[i]);
    end
    // assign cout = i0[31] & int_ip[31] | int_ip[31] & temp[30] | temp[30] & i0[31];
endmodule