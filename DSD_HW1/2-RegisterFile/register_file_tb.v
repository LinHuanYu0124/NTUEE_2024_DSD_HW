`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module register_file_tb;
    // port declaration for design-under-test
    reg Clk, WEN;
    reg  [2:0] RW, RX, RY;
    reg  [7:0] busW;
    wire [7:0] busX, busY;
    
    // instantiate the design-under-test
    register_file rf(
        Clk  ,
        WEN  ,
        RW   ,
        busW ,
        RX   ,
        RY   ,
        busX ,
        busY
    );

    initial begin
        $dumpfile("alu_assign.vcd"); // Set the VCD dumpfile
        $dumpvars; // Dump all variables
    end

    // write your test pattern here

    //Clk
    always #((`CYCLE / 2)) begin
            Clk = ~Clk;
    end

    initial begin
        Clk = 0;
        WEN = 0;
        RW = 3'b000; 
        busW = 8'b11111111;
        RX = 3'b010; 
        RY = 3'b101; 

        #(10);
    
        // Change inputs
        WEN = 1; // Disable write operation
        RW = 3'b110; // Write to register $r6
        busW = 8'hAA; // Write data
        
        // Wait for 10 clock cycles
        #(10);
        
        // Change inputs
        RX = 3'b110; // Read from register $r6
        RY = 3'b111; // Read from register $r7

        #(10);
        
        // End simulation
        $finish;
    end

endmodule
