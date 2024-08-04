module address_alignment (
    clk,
    rst_n,
    pc,
    i_cache_data,
    i_cache_stall,
    addr,
    data,
    stall,
    compression
);
input clk;
input rst_n;
input [31:0] pc, i_cache_data;
input i_cache_stall;
output reg [29:0] addr;
output reg [31:0] data;
output reg stall, compression;
reg [15:0] temp_result, temp_result_nxt;
reg again, again_nxt;
reg [29:0] addr_nxt;

reg [31:0] in_data;

always @(*) begin
    in_data = {i_cache_data[7:0], i_cache_data[15:8], i_cache_data[23:16], i_cache_data[31:24]};
    stall = 1;
    addr = again ? pc[31:2]+1 : pc[31:2];
    compression = 0;
    again_nxt = again;
    temp_result_nxt = temp_result;
    // data = in_data;
    if(i_cache_stall) begin
        stall = 1;
    end
    else if((in_data[17:16]==2'b11) && pc[1] && !again) begin
        stall = 1;
        compression = 0;
        again_nxt = 1;
        temp_result_nxt = in_data[31:16];
    end
    else if(again)begin
        stall = 0;
        compression = 0;
        again_nxt = 0;
        // data = {in_data[15:0], temp_result};
    end
    else begin
        stall = 0;
        if(pc[1]) begin
            compression = 1;
            // data = {16'd0, in_data[31:16]};
        end
        else begin
            compression = in_data[1:0]!=2'b11;
            // data = in_data;
        end
    end
end

always@(*) begin
    if(again) data = {in_data[15:0], temp_result};
    else if(pc[1]) data = {16'd0, in_data[31:16]};
    else data = in_data;
end

always @(posedge clk) begin
    if(!rst_n) begin
        temp_result <= 0;
        again <= 0;
    end
    else begin
        temp_result <= temp_result_nxt;
        again <= again_nxt;
    end
end

endmodule