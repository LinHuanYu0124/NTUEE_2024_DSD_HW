module IF_ID (
    clk_i, rst_i, flush_i, stall_i, 
    instr_i, PC_i,
    instr_o, PC_o
);
input         clk_i, rst_i, flush_i, stall_i;
input   start_i;
input  [31:0] instr_i, PC_i;
output reg [31:0] instr_o, PC_o;

// TODO 
always@(posedge clk_i or negedge rst_i)begin
    if(~rst_i) begin
        instr_o <= 32'b0;
        PC_o <= 32'b0;
    end   
    else begin
        if (!stall_i && !flush_i) begin
            instr_o <= instr_i;
            PC_o <= PC_i;
        end
        if(flush_i)begin
            instr_o <= 32'b0;
            PC_o <= 32'b0;
        end
    end
end


endmodule
