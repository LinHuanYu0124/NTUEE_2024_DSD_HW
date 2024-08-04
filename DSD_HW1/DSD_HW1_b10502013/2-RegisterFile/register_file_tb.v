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
        .Clk(Clk)  ,
        .WEN(WEN)  ,
        .RW(RW)   ,
        .busW(busW) ,
        .RX(RX)   ,
        .RY(RY)   ,
        .busX(busX) ,
        .busY(busY)
    );

    initial begin
        $dumpfile("alu_register_file.vcd"); // Set the VCD dumpfile
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

        // Case 1:
        #(`CYCLE*0.8);
        WEN = 1;
        RW = 3'b110;
        busW = 8'hAA;
        RX = 3'b110;
        RY = 3'b111;
        #(`CYCLE*0.2);

        // Case 2:
        #(`CYCLE*0.8);
        WEN = 1;
        RW = 3'b111;
        busW = 8'hFF;
        RX = 3'b111;
        RY = 3'b110;
        #(`CYCLE*0.2);

        // Case 3:
        #(`CYCLE*0.8);
        WEN = 1;
        RW = 3'b000;
        busW = 8'hA5;
        RX = 3'b000;
        RY = 3'b001;
        #(`CYCLE*0.2);

        // Case 4:
        #(`CYCLE*0.8);
        WEN = 0;
        RW = 3'b010;
        busW = 8'h3C;
        RX = 3'b010;
        RY = 3'b011;
        #(`CYCLE*0.2);

        // Case 5:
        #(`CYCLE*0.8);
        WEN = 1;
        RW = 3'b101;
        busW = 8'h7F;
        RX = 3'b000;
        RY = 3'b101;
        #(`CYCLE*0.2);

        // Case 6:
        #(`CYCLE*0.8);
        WEN = 1;
        RW = 3'b011;
        busW = 8'h0A;
        RX = 3'b011;
        RY = 3'b110;
        #(`CYCLE*0.2);

        
        #(`CYCLE);

        // End simulation
        $finish;
    end

endmodule
