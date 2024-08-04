`timescale 1ns / 1ps

module alu_assign_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns

    // Inputs
    reg [3:0] ctrl;
    reg [7:0] x;
    reg [7:0] y;
    reg [8:0] ans;
    reg [3:0] count;

    // Outputs
    wire carry;
    wire [7:0] out;

    // Instantiate the unit under test (UUT)
    alu_assign dut (
        .ctrl(ctrl),
        .x(x),
        .y(y),
        .carry(carry),
        .out(out)
    );

    // Clock generation
    reg clk = 0;
    always #((CLK_PERIOD)/2) clk = ~clk;

    initial begin
        $dumpfile("alu_assign.vcd"); // Set the VCD dumpfile
        $dumpvars; // Dump all variables
    end

    // Test cases
    initial begin
        // Test case 1: Addition
        ctrl = 4'b0000;
        x = 8'b1111_1111; 
        y = 8'b0000_0001; // 5
        ans = 9'b1_0000_0000;
        count = 1;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 2: Subtraction
        ctrl = 4'b0001;
        x = 8'h05; // 5
        y = 8'h0A; // 10
        ans = 9'b1_1111_1011;
        count = 2;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 3: Bitwise AND
        ctrl = 4'b0010;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 9'b0_0000_0000;
        count = 3;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 4: Bitwise OR
        ctrl = 4'b0011;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 9'b0_0000_1111;
        count = 4;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 5: Bitwise OR
        ctrl = 4'b0100;
        x = 8'd10; // 10
        y = 8'h05; // 5
        ans = 9'b1_1111_0101;
        count = 5;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 6:
        ctrl = 4'b0101;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 9'b0_0000_1111;
        count = 6;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 7:
        ctrl = 4'b0110;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 9'b1_1111_0000;
        count = 7;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        ctrl = 4'b0111;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 9'b0_0001_0100;
        count = 8;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        ctrl = 4'b1000;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 9'b0_0000_0001;
        count = 9;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        ctrl = 4'b1001;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 9'b0_0000_0101;
        count = 10;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        ctrl = 4'b1010;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 9'b0_0001_0100;
        count = 11;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);
        
        ctrl = 4'b1010;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 9'b0_0001_0100;
        count = 12;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        ctrl = 4'b1100;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = 0;
        count = 13;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        $finish;
    end

endmodule
