module register(clk, rst_n, wen, rd, rs1, rs2, w_data, r_data1, r_data2);

    input clk, rst_n, wen;
    input [4:0] rd, rs1, rs2;
    input [31:0] w_data;

    output [31:0] r_data1, r_data2;

    reg signed [31:0] r [0:31];
    reg signed [31:0] r_nxt [0:31];

    integer i;

    assign r_data1 = r[rs1];
    assign r_data2 = r[rs2];

    always @(*) begin
        r_nxt[0] = 0;
        for (i=1; i<32; i=i+1)
            r_nxt[i] = (wen && (rd == i)) ? w_data : r[i];
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            for (i=0; i<32; i=i+1)
                r[i] <= 0;
        end
        else begin
        for (i=0; i<32; i=i+1)
            r[i] <= r_nxt[i];
        end
    end

endmodule
