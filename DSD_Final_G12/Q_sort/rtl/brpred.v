/*
module BrPred_satcnt(
    clk,
    rst_n,
    IF_branch,
    ID_branch,
    stall,
    wrong,
    taken
);

input  clk;
input  rst_n;
input  IF_branch;
input  ID_branch;
input  stall;
input  wrong;
output taken;

reg [1:0] state, state_nxt;

localparam S_SNT = 0;
localparam S_WNT = 1;
localparam S_WT =  2;
localparam S_ST =  3;

assign taken = state[1] && IF_branch;

always@(*) begin
    if(ID_branch && !stall)begin
        case(state)
        S_SNT: state_nxt = wrong ? S_WNT : S_SNT;
        S_WNT: state_nxt = wrong ? S_WT  : S_SNT;
        S_WT:  state_nxt = wrong ? S_WNT : S_ST ;
        S_ST:  state_nxt = wrong ? S_WT  : S_ST ;
        endcase
    end
    else state_nxt = state;
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
*/

module SatCnt(
    clk,
    rst_n,
    update,
    wrong,
    taken
);

input  clk;
input  rst_n;
input  update;
input  wrong;
output taken;

reg [1:0] state, state_nxt;

localparam S_SNT = 0;
localparam S_WNT = 1;
localparam S_WT =  2;
localparam S_ST =  3;

assign taken = state[1];

always@(*) begin
    if(update)begin
        case(state)
        S_SNT: state_nxt = wrong ? S_WNT : S_SNT;
        S_WNT: state_nxt = wrong ? S_WT  : S_SNT;
        S_WT:  state_nxt = wrong ? S_WNT : S_ST ;
        S_ST:  state_nxt = wrong ? S_WT  : S_ST ;
        endcase
    end
    else state_nxt = state;
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

/*
module BrPred(
    clk,
    rst_n,
    IF_branch,
    ID_branch,
    stall,
    wrong,
    taken
);

input  clk;
input  rst_n;
input  IF_branch;
input  ID_branch;
input  stall;
input  wrong;
output taken;

reg[1:0] history, history_nxt;
reg [3:0] update_pht;
wire result0, result1, result2, result3;
reg result;
reg prev_taken;
assign taken = result & IF_branch;

SatCnt pht0(.clk(clk), .rst_n(rst_n), .update(update_pht[0]), .wrong(wrong), .taken(result0));
SatCnt pht1(.clk(clk), .rst_n(rst_n), .update(update_pht[1]), .wrong(wrong), .taken(result1));
SatCnt pht2(.clk(clk), .rst_n(rst_n), .update(update_pht[2]), .wrong(wrong), .taken(result2));
SatCnt pht3(.clk(clk), .rst_n(rst_n), .update(update_pht[3]), .wrong(wrong), .taken(result3));

always@(*) begin
    if(ID_branch && !stall) begin
        history_nxt[1] = history[0];
        history_nxt[0] = wrong ^ prev_taken;
    end
    else begin
        history_nxt = history;
    end
end

always@(*) begin
    if (ID_branch && !stall) begin
        case(history)
        2'b00  : update_pht = 4'd1;
        2'b01  : update_pht = 4'd2;
        2'b10  : update_pht = 4'd4;
        default: update_pht = 4'd8;
        endcase
    end
    else update_pht = 4'd0;
end

always@(*) begin
   case(history)
    2'b00  : result = result0;
    2'b01  : result = result1;
    2'b10  : result = result2;
    default: result = result3;
    endcase 
end

always@(posedge clk) begin
    if(~rst_n) begin
        history <= 0;
        prev_taken <= 0;
    end
    else begin
        history <= history_nxt;
        prev_taken <= taken;
    end
end
endmodule

*/
module BrPred3(
    clk,
    rst_n,
    IF_branch,
    ID_branch,
    stall,
    wrong,
    taken
);

input  clk;
input  rst_n;
input  IF_branch;
input  ID_branch;
input  stall;
input  wrong;
output taken;

reg [2:0] history, history_nxt;
reg [7:0] update_pht;
wire result0, result1, result2, result3, result4, result5, result6, result7;
reg result;
reg prev_taken;

assign taken = result & IF_branch;

SatCnt pht0(.clk(clk), .rst_n(rst_n), .update(update_pht[0]), .wrong(wrong), .taken(result0));
SatCnt pht1(.clk(clk), .rst_n(rst_n), .update(update_pht[1]), .wrong(wrong), .taken(result1));
SatCnt pht2(.clk(clk), .rst_n(rst_n), .update(update_pht[2]), .wrong(wrong), .taken(result2));
SatCnt pht3(.clk(clk), .rst_n(rst_n), .update(update_pht[3]), .wrong(wrong), .taken(result3));
SatCnt pht4(.clk(clk), .rst_n(rst_n), .update(update_pht[4]), .wrong(wrong), .taken(result4));
SatCnt pht5(.clk(clk), .rst_n(rst_n), .update(update_pht[5]), .wrong(wrong), .taken(result5));
SatCnt pht6(.clk(clk), .rst_n(rst_n), .update(update_pht[6]), .wrong(wrong), .taken(result6));
SatCnt pht7(.clk(clk), .rst_n(rst_n), .update(update_pht[7]), .wrong(wrong), .taken(result7));

always@(*) begin
    if(ID_branch && !stall) begin
        history_nxt[2] = history[1];
        history_nxt[1] = history[0];
        history_nxt[0] = wrong ^ prev_taken;
    end
    else begin
        history_nxt = history;
    end
end

always@(*) begin
    update_pht = 8'd0;
    if (ID_branch && !stall) begin
        update_pht[history] = 1'b1;
    end
    else update_pht[history] = 1'b0;
end

always@(*) begin
   case(history)
    3'd0   : result = result0;
    3'd1   : result = result1;
    3'd2   : result = result2;
    3'd3   : result = result3;
    3'd4   : result = result4;
    3'd5   : result = result5;
    3'd6   : result = result6;
    3'd7   : result = result7;
    endcase 
end

always@(posedge clk) begin
    if(~rst_n) begin
        history <= 0;
        prev_taken <= 0;
    end
    else begin
        history <= history_nxt;
        prev_taken <= taken;
    end
end

endmodule

/*
module BrPred_gshare(
    clk,
    rst_n,
    IF_branch,
    ID_branch,
    PC,
    stall,
    wrong,
    taken
);

input  clk;
input  rst_n;
input  IF_branch;
input  ID_branch;
input  [1:0] PC; // PC[2:1]
input  stall;
input  wrong;
output taken;

reg[1:0] history, history_nxt;
reg [3:0] update_pht;
wire result0, result1, result2, result3;
reg result;
reg prev_taken;

assign taken = result & IF_branch;

SatCnt pht0(.clk(clk), .rst_n(rst_n), .update(update_pht[0]), .wrong(wrong), .taken(result0));
SatCnt pht1(.clk(clk), .rst_n(rst_n), .update(update_pht[1]), .wrong(wrong), .taken(result1));
SatCnt pht2(.clk(clk), .rst_n(rst_n), .update(update_pht[2]), .wrong(wrong), .taken(result2));
SatCnt pht3(.clk(clk), .rst_n(rst_n), .update(update_pht[3]), .wrong(wrong), .taken(result3));

always@(*) begin
    if(ID_branch && !stall) begin
        history_nxt[1] = history[0];
        history_nxt[0] = wrong ^ prev_taken;
    end
    else begin
        history_nxt = history;
    end
end

always@(*) begin
    if (ID_branch && !stall) begin
        case(history ^ PC)
        2'b00  : update_pht = 4'd1;
        2'b01  : update_pht = 4'd2;
        2'b10  : update_pht = 4'd4;
        default: update_pht = 4'd8;
        endcase
    end
    else update_pht = 4'd0;
end

always@(*) begin
   case(history ^ PC)
    2'b00  : result = result0;
    2'b01  : result = result1;
    2'b10  : result = result2;
    default: result = result3;
    endcase 
end

always@(posedge clk) begin
    if(~rst_n) begin
        history <= 0;
        prev_taken <= 0;
    end
    else begin
        history <= history_nxt;
        prev_taken <= taken;
    end
end

endmodule


module BrPred3_gshare(
    clk,
    rst_n,
    IF_branch,
    ID_branch,
    PC,
    stall,
    wrong,
    taken
);

input  clk;
input  rst_n;
input  IF_branch;
input  ID_branch;
input [2:0] PC; // PC[3:1]
input  stall;
input  wrong;
output taken;

reg [2:0] history, history_nxt;
reg [7:0] update_pht;
wire result0, result1, result2, result3, result4, result5, result6, result7, result8;
reg result;
reg prev_taken;

assign taken = result & IF_branch;

SatCnt pht0(.clk(clk), .rst_n(rst_n), .update(update_pht[0]), .wrong(wrong), .taken(result0));
SatCnt pht1(.clk(clk), .rst_n(rst_n), .update(update_pht[1]), .wrong(wrong), .taken(result1));
SatCnt pht2(.clk(clk), .rst_n(rst_n), .update(update_pht[2]), .wrong(wrong), .taken(result2));
SatCnt pht3(.clk(clk), .rst_n(rst_n), .update(update_pht[3]), .wrong(wrong), .taken(result3));
SatCnt pht4(.clk(clk), .rst_n(rst_n), .update(update_pht[4]), .wrong(wrong), .taken(result4));
SatCnt pht5(.clk(clk), .rst_n(rst_n), .update(update_pht[5]), .wrong(wrong), .taken(result5));
SatCnt pht6(.clk(clk), .rst_n(rst_n), .update(update_pht[6]), .wrong(wrong), .taken(result6));
SatCnt pht7(.clk(clk), .rst_n(rst_n), .update(update_pht[7]), .wrong(wrong), .taken(result7));

always@(*) begin
    if(ID_branch && !stall) begin
        history_nxt[2] = history[1];
        history_nxt[1] = history[0];
        history_nxt[0] = wrong ^ prev_taken;
    end
    else begin
        history_nxt = history;
    end
end

always@(*) begin
    update_pht = 8'd0;
    if (ID_branch && !stall) begin
        update_pht[history ^ PC] = 1'b1;
    end
    else update_pht[history ^ PC] = 1'b0;
end

always@(*) begin
   case(history ^ PC)
    3'd0   : result = result0;
    3'd1   : result = result1;
    3'd2   : result = result2;
    3'd3   : result = result3;
    3'd4   : result = result4;
    3'd5   : result = result5;
    3'd6   : result = result6;
    3'd7   : result = result7;
    endcase 
end

always@(posedge clk) begin
    if(~rst_n) begin
        history <= 0;
        prev_taken <= 0;
    end
    else begin
        history <= history_nxt;
        prev_taken <= taken;
    end
end

endmodule
*/