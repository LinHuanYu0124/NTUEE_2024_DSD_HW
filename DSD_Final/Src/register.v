module Register(
    input           clk, 
    input           rst_n, 
    input           wen_i, 
    input   [4:0]   rd_i, 
    input   [4:0]   rs1_i, 
    input   [4:0]   rs2_i, 
    input   [31:0]  rd_data_i, 
    output  [31:0]  rs1_data_o, 
    output  [31:0]  rs2_data_o
);

    reg [31:0] mem [0:31];
    reg [31:0] mem_nxt [0:31];

    integer i;

    assign rs1_data_o = mem[rs1_i];
    assign rs2_data_o = mem[rs2_i];

    always @(*) begin
        mem_nxt[0] = 0;
        for (i=1; i<32; i=i+1) begin
            mem_nxt[i] = (wen_i && (rd_i == i)) ? rd_data_i : mem[i];
        end
    end

    always @(posedge clk) begin
        if (~rst_n) begin
            for (i=0; i<32; i=i+1) begin
                mem[i] <= 0;
            end
        end else begin
            for (i=0; i<32; i=i+1) begin
                mem[i] <= mem_nxt[i];
            end
        end
    end

endmodule
