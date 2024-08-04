module IFID
(
    clk_i,
    rst_i,
    Stall_i,
    Flush_i,
    pc_i,
    instr_i,

    pc_o,
    instr_o
);

// Ports
input               clk_i;
input               rst_i;

input               Stall_i;
input               Flush_i;
input   [31:0]      pc_i;
input   [31:0]      instr_i;

output  [31:0]      pc_o;
output  [31:0]      instr_o;

reg     [31:0]      pc_o;
reg     [31:0]      instr_o;

always@(posedge clk_i or negedge rst_i) begin
    if (~rst_i) begin
        pc_o = 32'b0;
        instr_o = 32'b0;
    end
    else if(Flush_i) begin
        pc_o = 32'b0;
        instr_o = 32'b0;
    end
    else if(!Stall_i) begin
        pc_o = pc_i;
        instr_o = instr_i;
    end
end

endmodule
