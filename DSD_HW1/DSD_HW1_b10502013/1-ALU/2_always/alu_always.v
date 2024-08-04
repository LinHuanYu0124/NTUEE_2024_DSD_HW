//RT �Vlevel (event-driven) 
module alu_always(
    ctrl,
    x,
    y,
    carry,
    out 
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output       carry;
    output [7:0] out;

    reg [7:0] out_r;
    reg carry_r;
    
    assign out = out_r;
    assign carry = carry_r;

    always @(*) begin
        case (ctrl)
            4'b0000 : {carry_r, out_r} = x + y;
            4'b0001 : {carry_r, out_r} = x - y;
            4'b0010 : {carry_r, out_r} = x & y;
            4'b0011 : {carry_r, out_r} = x | y;
            4'b0100 : {carry_r, out_r} = ~x;
            4'b0101 : {carry_r, out_r} = x ^ y;
            4'b0110 : {carry_r, out_r} = ~(x | y);
            4'b0111 : {carry_r, out_r} = y << x[2:0];
            4'b1000 : {carry_r, out_r} = y >> x[2:0];
            4'b1001 : {carry_r, out_r} = {x[7],x[7:1]};
            4'b1010 : {carry_r, out_r} = {x[6:0] , x[7]};
            4'b1011 : {carry_r, out_r} = {x[0] , x[7:1]};
            4'b1100 : {carry_r, out_r} = ((x==y)?1:0);
            default : {carry_r, out_r} = 0;
        endcase
    end

endmodule
