`include "./lib/booth_substep.v"
`include "./booth_multiplier_32bit_pipeline.v"

//==============================================================================

module test_bench();
    reg clk;
    reg rst_n;
    reg signed [31:0] multiplier;
    reg signed [31:0] multiplicand;
    wire signed [63:0] product_o;
    reg [5:0] count;

    // Instantiate the module under test
    booth_multiplier_32bit_pipeline uut (
        .clk(clk),
        .rst_n(rst_n),
        .multiplier(multiplier),
        .multiplicand(multiplicand),
        .product_o(product_o)
    );

    initial begin
        $dumpfile("tb_booth.vcd");
        $dumpvars(0, test_bench);
    end

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Reset
        clk = 0;
        rst_n = 0;
        count = 0;
        #10 rst_n = 1;

        // Test case 1
        multiplier = 32'd10;
        multiplicand = 32'd20;
        #10;

        //Test case 2
        multiplier = 32'd1;
        multiplicand = 32'd20;
        #7;
        // Verify Test case 1
        
        if (product_o !== 64'd200) begin
            $display("Test case 1 failed: 10 * 20 = %d",  product_o);
        end
        else begin
            $display("Test case 1 passed: 10 * 20 = %d",  product_o);
        end
        count += 1;
        #3;


        // Test case 3
        multiplier = -15;
        multiplicand = 32'd30;
        #7;
        //Verify Test case 2
        if (product_o !== 64'd20) begin
            $display("Test case 2 failed: 1  * 20 = %d",  product_o);
        end
        else begin
            $display("Test case 2 passed: 1  * 20 = %d",  product_o);
        end
        count += 1;
        #3;
        
        // Test case 4
        multiplier = -2147483647;
        multiplicand = -2147483647;
        #7;
        //Verify Test case 3
        if (product_o !== -450) begin
            $display("Test case 3 failed: 15 * 30 = %d",  product_o);
        end
        else begin
            $display("Test case 3 passed: 15 * 30 = %d",  product_o);
        end
        count += 1;
        #3;

        multiplier = 32'd0;
        multiplicand = 32'd0;
        #7;
        //Verifying Test case 4
        if (product_o !== (-2147483647)*(-2147483647)) begin
            $display("Test case 5 failed: -2147483647 * -2147483647 = %d",  product_o);
        end
        else begin
            $display("Test case 5 passed: -2147483648 * -2147483648 = %d",  product_o);
        end
        count += 1;
        #3;

        // Test case 5
        multiplier = -1;
        multiplicand = 32'd1;
        #7;
        // Verify Test case 5
        if (product_o !== 64'd0) begin
            $display("Test case 5 failed: 0 * 0 = %d",  product_o);
        end
        else begin
            $display("Test case 5 passed: 0 * 0 = %d",  product_o);
        end
        count += 1;
        #3;

        // Test case 6
        multiplier = 32'd2147483647;
        multiplicand = -1;
        #7;
        // Verify Test case 5
        if (product_o !== -64'd1) begin
            $display("Test case 6 failed: -1 * 1 = %d",  product_o);
        end
        else begin
            $display("Test case 6 passed: -1 * 1 = %d",  product_o);
        end
        count += 1;
        #3;


        multiplier = -2147483647;
        multiplicand = -1;        
        #7;
        // Verify Test case 7
        if (product_o !== -2147483647) begin
            $display("Test case 7 failed: 2147483647 * -1 = %d",  product_o);
        end
        else begin
            $display("Test case 7 passed: 2147483647 * -1 = %d",  product_o);
        end
        count += 1;
        #3;

        // Test case 8
        
        #7;
        #10;
        // Verify Test case 8
        if (product_o !== 64'd2147483647) begin
            $display("Test case 8 failed: -2147483647 * -1 = %d",  product_o);
        end
        else begin
            $display("Test case 8 passed: -2147483647 * -1 = %d",  product_o);
        end
        count += 1;
        #3;

        // Add more test cases as needed...

        // Finish the simulation
        #10;
        $finish;
    end
endmodule


//================={=============================================================