module booth_substep(
    input wire signed [31:0] acc,    //Current value of accumulator
    input wire signed [31:0] Q,  //Current value of Q (initially the multiplier)    
    input wire signed q0,       //Current value of q-1 th bit
    input wire signed [31:0] multiplicand,  //the multipliand
    output reg signed [31:0] next_acc,   //next accumulator value || value of 8 MSB's of 16 bit output [17:8]
    output reg signed [31:0] next_Q, //Next value of Q || value of 8 LSB's of 16 bit output [7:0]
    output reg q0_next);
    
	wire [31:0] addsub_temp;  //next value of q_-1 th bit
	

    adder_subractor addsub (.Q(Q[0]), .A(acc), .B(multiplicand), .S(addsub_temp));
    
    
    always @(*) begin	
        if(Q[0] == q0) begin
            q0_next = Q[0];
            next_Q = Q>>>1;
            next_Q[31] = acc[0];
            
            //  Right shift
            next_acc = acc>>>1;
            
            //  With sign extension
            if (acc[31] == 1) begin
                next_acc[31] = 1;
            end
        end

        else begin        //if Q[0] != q0 (that is,  q_-1 bit)
            q0_next = Q[0];
            next_Q = Q>>>1;
            next_Q[31] = addsub_temp[0];
            
            //Right s1hift
            next_acc = addsub_temp>>>1;
            
            //  With sign extension
            if (addsub_temp[31] == 1) begin
                next_acc[31] = 1;
            end
        end	
    end	
endmodule 

module adder_subractor(
    input wire Q,
    input wire signed [31:0] A,
    input wire signed [31:0] B,
    output wire signed [31:0] S
);
    assign S = (Q) ? (A - B) : (A + B);
endmodule
