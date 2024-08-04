module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);

    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output       Carry;

// declaration of wire/reg
    reg [7:0] r0_w, r1_w, r2_w, r3_w, r4_w, r5_w, r6_w, r7_w;
    reg [7:0] r0_r, r1_r, r2_r, r3_r, r4_r, r5_r, r6_r, r7_r;
    reg [7:0] X, Y;       
    reg carry;
    reg [7:0] invert;

//Initialize
    initial begin
        r0_r = 8'h00; 
        r1_r = 8'h00; 
        r2_r = 8'h00;
        r3_r = 8'h00;
        r4_r = 8'h00;
        r5_r = 8'h00;
        r6_r = 8'h00;
        r7_r = 8'h00;
    end

// submodule instantiation

    assign Carry = carry;
    assign busY  = Y;

    always@(*) begin
        //initial
        r0_w = r0_r;
        r1_w = r1_r;
        r2_w = r2_r;
        r3_w = r3_r;
        r4_w = r4_r;
        r5_w = r5_r;
        r6_w = r6_r;
        r7_w = r7_r;

        //8x8 Register
        case (RY)
            3'b000 : Y = r0_r;
            3'b001 : Y = r1_r;
            3'b010 : Y = r2_r;
            3'b011 : Y = r3_r;
            3'b100 : Y = r4_r;
            3'b101 : Y = r5_r;
            3'b110 : Y = r6_r;
            3'b111 : Y = r7_r; 
        endcase

        //MUX
        if (Sel) begin
            case (RX)
                3'b000 : X = r0_r;
                3'b001 : X = r1_r;
                3'b010 : X = r2_r;
                3'b011 : X = r3_r;
                3'b100 : X = r4_r;
                3'b101 : X = r5_r;
                3'b110 : X = r6_r;
                3'b111 : X = r7_r; 
            endcase    
        end
        else begin
            X = DataIn;
        end
    end

    //ALU
    always @(*) begin
        case (Ctrl)
            4'b0000 : {carry, invert} = X + Y;
            4'b0001 : {carry, invert} = $signed(X - Y);
            4'b0010 : {carry, invert} = X & Y;
            4'b0011 : {carry, invert} = X | Y;
            4'b0100 : {carry, invert} = ~X;
            4'b0101 : {carry, invert} = X ^ Y;
            4'b0110 : {carry, invert} = ~(X | Y);
            4'b0111 : {carry, invert} = Y << X[2:0];
            4'b1000 : {carry, invert} = Y >> X[2:0];
            4'b1001 : {carry, invert} = {X[7], X[7:1]};
            4'b1010 : {carry, invert} = {X[6:0], X[7]};
            4'b1011 : {carry, invert} = {X[0], X[7:1]};
            4'b1100 : {carry, invert} = ((X == Y) ? 1:0);
            default : {carry, invert} = 0;
        endcase
    end
    
    //Sequential
    always@(posedge Clk) begin
        if (WEN) begin
            case (RW)
                3'b000 : r0_r <= invert;
                3'b001 : r1_r <= invert;
                3'b010 : r2_r <= invert;
                3'b011 : r3_r <= invert;
                3'b100 : r4_r <= invert;
                3'b101 : r5_r <= invert;
                3'b110 : r6_r <= invert;
                3'b111 : r7_r <= invert;
            endcase
        end
        else begin
            r0_r <= r0_w;
            r1_r <= r1_w;
            r2_r <= r2_w;
            r3_r <= r3_w;
            r4_r <= r4_w;
            r5_r <= r5_w;
            r6_r <= r6_w;
            r7_r <= r7_w;
        end
    end	

endmodule
