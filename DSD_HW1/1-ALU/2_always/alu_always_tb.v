//always block tb
`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

module alu_always_tb;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    reg  [8:0] ans;
    wire       carry;
    wire [7:0] out;
    reg [3:0] count; 
    
    alu_always alu_always(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );

//    initial begin
//        $fsdbDumpfile("alu_always.fsdb");
//        $fsdbDumpvars;
//    end

    initial begin
        $dumpfile("alu_always.vcd"); // Set the VCD dumpfile
        $dumpvars; // Dump all variables
    end

    initial begin
        // Test case 1: Addition
        ctrl = 4'b0000;
        x = 8'b1111_1111; 
        y = 8'b0001_1000; // 5
        ans = x + y;
        count = 1;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 2: Subtraction
        ctrl = 4'b0001;
        x = 8'h05; // 5
        y = 8'h0A; // 10
        ans = x - y;
        count = 2;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 3: Bitwise AND
        ctrl = 4'b0010;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = x & y;
        count = 3;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 4: Bitwise OR
        ctrl = 4'b0011;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = x | y;
        count = 4;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 5: Bitwise OR
        ctrl = 4'b0100;
        x = 8'b1010_1010; // 10
        y = 8'h05; // 5
        ans = ~x;
        count = 5;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 6:
        ctrl = 4'b0101;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = x^y;
        count = 6;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Test case 7:
        ctrl = 4'b0110;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = ~(x|y);
        count = 7;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        ctrl = 4'b0111;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = y<<x[2:0];
        count = 8;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        ctrl = 4'b1000;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = y>>x[2:0];
        count = 9;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        ctrl = 4'b1001;
        x = 8'h0A; // 10
        y = 8'h05; // 5
        ans = {x[7],x[7:1]};
        count = 10;
        #10;
        if ({carry, out} == ans) $display("Test case %d passed", count);
        else $display("Test case %d failed, ans = %b, carry = %b, out = %b",count, ans, carry, out);

        // Finish simulation
        $finish;
    end
endmodule
