//continuous assignment tb
`timescale 1ns/10ps
`define CYCLE   10
`define HCYCLE  5

module alu_assign_tb;
    reg         [3:0] ctrl;
    reg         [7:0] x;
    reg         [7:0] y;
    wire        carry;
    wire        [7:0] out;
    wire [8:0] add, sub;

    integer c;
    integer _x;
    integer _y;
    integer error;


    assign add = $signed(x) + $signed(y);
    assign sub = $signed(x) - $signed(y);
    
    alu_assign alu_assign(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );

    initial begin
        $dumpfile("alu_assign.vcd"); // Set the VCD dumpfile
        $dumpvars; // Dump all variables
    end

    initial begin
        ctrl = 4'b0000;
        x    = 8'd0;
        y    = 8'd0;
        
        for (c = 0; c < 16; c = c + 1) begin
            #(`CYCLE);
            x = 8'd0;
            y = 8'd0;
            error = 0;

            for (_x = 0;_x < 256 ;_x = _x + 1 ) begin
                    for (_y = 0; _y < 256; _y = _y + 1) begin
                        // test
                        #(`HCYCLE);
                        case (ctrl)
                            4'b0000: if ({ carry, out } !== add)                        error = error + 1;
                            4'b0001: if ({ carry, out } !== sub)                        error = error + 1;
                            4'b0010: if ((out !== (x & y)) || carry)                    error = error + 1;
                            4'b0011: if ((out !== (x | y)) || carry)                    error = error + 1;
                            4'b0100: if ((out !== (~x)) || carry)                       error = error + 1;
                            4'b0101: if ((out !== (x ^ y)) || carry)                    error = error + 1;
                            4'b0110: if ((out !== (~(x | y))) || carry)                 error = error + 1;
                            4'b0111: if ((out !== (y << x[2:0])) || carry)              error = error + 1;
                            4'b1000: if ((out !== (y >> x[2:0])) || carry)              error = error + 1;
                            4'b1001: if ((out !== { x[7], x[7:1] }) || carry)           error = error + 1;
                            4'b1010: if ((out !== { x[6:0], x[7] }) || carry)           error = error + 1;
                            4'b1011: if ((out !== { x[0], x[7:1] }) || carry)           error = error + 1;
                            4'b1100: if ((out !== (x == y)) || carry)                   error = error + 1;
                            default: if ((out !== 8'b0) || carry)                       error = error + 1;
                        endcase

                        #(`HCYCLE);
                        y = y + 1;
                    end
                    x = x + 1;
            end

                // print message
                
            if( error == 0 ) $display( "PASS --- %b", ctrl );
            else $display( "FAIL --- %b, error = %d", ctrl, error );
            ctrl = ctrl + 1;
        end

            // finish tb
            #(`CYCLE) $finish;

    end

endmodule