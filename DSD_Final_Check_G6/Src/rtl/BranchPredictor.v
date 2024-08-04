module BranchPredictor (
    clk_i,
    rst_i,
    ActualDecison_i,
    update_i,
    Ttarget_i,
    NTtarget_i,
    predict_o,
    RealBranch_o,
    RealTarget_o
);

input clk_i, rst_i;
input [31:0] Ttarget_i, NTtarget_i;
input update_i;
input ActualDecison_i;
output predict_o, RealBranch_o;
output [31:0] RealTarget_o;

wire [1:0] counter_w;
reg [1:0] counter_r;
wire wrong;

assign predict_o = counter_r[1];
assign wrong = (~(predict_o == ActualDecison_i)) & update_i;
assign counter_w = counter_r;
assign RealBranch_o = wrong;
assign RealTarget_o = (predict_o) ? NTtarget_i : Ttarget_i;

always@(posedge clk_i or negedge rst_i) begin
    if (~rst_i) begin
        counter_r <= 2'd3;
    end
    else begin
        if (update_i) begin
            if (ActualDecison_i) begin
                counter_r <= (counter_r==2'd3) ? 2'd3 : (counter_r + 1);
            end
            else begin
                counter_r <= (counter_r==2'd0) ? 2'd0 : (counter_r - 1);
            end
        end
        else begin
            counter_r <= counter_w;
        end
    end
end

endmodule