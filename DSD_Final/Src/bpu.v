
module BPU( // 2-bit saturating
    input   clk,
    input   rst_n,
    input   IF_branch_i,
    input   ID_branch_i,
    input   stall_i,
    input   wrong_i,
    output  taken_o
);

reg [1:0] state, state_nxt;

localparam S_SNT = 0;
localparam S_WNT = 1;
localparam S_WT =  2;
localparam S_ST =  3;

assign taken_o = state[1] && IF_branch_i;

always@(*) begin
    if(ID_branch_i && !stall_i)begin
        case(state)
            S_SNT: state_nxt = wrong_i ? S_WNT : S_SNT;
            S_WNT: state_nxt = wrong_i ? S_WT  : S_SNT;
            S_WT:  state_nxt = wrong_i ? S_WNT : S_ST ;
            S_ST:  state_nxt = wrong_i ? S_WT  : S_ST ;
        endcase
    end else begin
        state_nxt = state;
    end
end


always@(posedge clk) begin
    if(~rst_n) begin
        state <= S_SNT;
    end
    else begin
        state <= state_nxt;
    end
end

endmodule