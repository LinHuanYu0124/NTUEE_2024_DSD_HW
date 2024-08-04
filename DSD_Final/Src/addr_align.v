module Addr_Align (
    input           clk,
    input           rst_n,
    input   [31:0]  pc_i,
    input   [31:0]  I_cache_data_i,
    input           I_cache_stall_i,
    output  [29:0]  I_cache_addr_o,
    output  [31:0]  I_chche_data_o,
    output          I_cache_stall_o
);

reg [15:0] temp_data, temp_data_nxt;
reg fetch_again, fetch_again_nxt;

wire [31:0] I_cache_data_in;
assign I_cache_data_in = {I_cache_data_i[7:0], I_cache_data_i[15:8], I_cache_data_i[23:16], I_cache_data_i[31:24]};

wire compress;
assign compress = (I_cache_data_in[17:16]==2'b11) && pc_i[1] && !fetch_again;


// output assignment
assign I_cache_addr_o = fetch_again ? pc_i[31:2]+1 : pc_i[31:2];
assign I_cache_stall_o = (I_cache_stall_i | compress) ? 1'b1 : 1'b0;
assign I_chche_data_o = fetch_again ? {I_cache_data_in[15:0], temp_data} : ((pc_i[1]) ? {16'd0, I_cache_data_in[31:16]} : I_cache_data_in);

always @(*) begin
    if (compress) begin
        fetch_again_nxt = 1'b1;
    end else if (I_cache_stall_i) begin
        fetch_again_nxt = fetch_again;
    end else begin
        fetch_again_nxt = 1'b0;
    end

    if (compress && (!I_cache_stall_i)) begin
        temp_data_nxt = I_cache_data_in[31:16];
    end else begin
        temp_data_nxt = temp_data;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        temp_data <= 0;
        fetch_again <= 0;
    end else begin
        temp_data <= temp_data_nxt;
        fetch_again <= fetch_again_nxt;
    end
end

endmodule