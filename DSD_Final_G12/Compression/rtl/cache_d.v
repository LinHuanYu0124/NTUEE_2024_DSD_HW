module cache_d(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);
    
//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr; 
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;
    
//==== wire/reg definition ================================
    localparam IDLE = 2'd0;
    localparam WR   = 2'd1;
    localparam WB   = 2'd2;
    localparam AL   = 2'd3;

    reg [1:0] state, state_nxt;

    reg mem_read, mem_write, mem_read_nxt, mem_write_nxt;
    reg [27:0] mem_addr;
    reg [31:0] proc_rdata;
    reg proc_stall, proc_stall_nxt;
    // 1bit lru + (1bit valid + 1bit dirty + 26bit tag + 128bit data) x2 sets
    // [312] | [311][310][309:284][283:156] | [155][154][153:128][127:0]
    reg [312:0] cache     [0:3];
    reg [312:0] cache_nxt [0:3];
    wire [1:0] offset;
    wire [1:0] index;
    wire [25:0] tag;
    wire hit1, hit0;
    integer i;

//==== combinational circuit ==============================
// decode proc_addr to 25bit tag + 3bit index + 2bit block offset
assign offset = proc_addr[1:0];
assign index  = proc_addr[3:2];
assign tag    = proc_addr[29:4];
assign hit1 = cache[index][311] && (tag == cache[index][309:284]);
assign hit0 = cache[index][155] && (tag == cache[index][153:128]);
assign mem_wdata = cache[index][312] ? cache[index][283:156] : cache[index][127:0];


always@(*) begin
    if(hit1) begin
        case(offset)
        2'd0: proc_rdata = cache[index][187:156];
        2'd1: proc_rdata = cache[index][219:188];
        2'd2: proc_rdata = cache[index][251:220];
        2'd3: proc_rdata = cache[index][283:252];
        endcase
    end
    else begin
        case(offset)
        2'd0: proc_rdata = cache[index][31:0];
        2'd1: proc_rdata = cache[index][63:32];
        2'd2: proc_rdata = cache[index][95:64];
        2'd3: proc_rdata = cache[index][127:96];
        endcase
    end
end

//==== FSM ================================================
always@(*) begin
    case(state)
    IDLE: begin
        if(proc_read & !hit1 & !hit0) begin
            // state_nxt = RE;
            case(cache[index][312])
            1'b0: begin
                if(cache[index][155] & cache[index][154]) state_nxt = WB;
                else state_nxt = AL;
            end
            1'b1: begin
                if(cache[index][311] & cache[index][310]) state_nxt = WB;
                else state_nxt = AL;
            end
            endcase
        end
        else if(proc_write) state_nxt = WR;
        else state_nxt = IDLE;
    end
    WR: begin
        // select LRU block
        // block is valid & dirty -> WB
        // else -> write block valid, dirty, tag, data directly
        if(hit1 | hit0) state_nxt = IDLE;
        else begin
            case(cache[index][312])
            1'b0: begin
                if(cache[index][154]) state_nxt = WB;
                else state_nxt = IDLE;
            end
            1'b1: begin
                if(cache[index][310]) state_nxt = WB;
                else state_nxt = IDLE;
            end
            endcase
        end
    end
    WB: begin
        if(mem_ready) state_nxt = proc_write ? WR : AL;
        else state_nxt = WB;
    end
    AL: begin
        if(mem_ready) state_nxt = IDLE;
        else state_nxt = AL;
    end
    endcase
end

always@(*) begin
    // default values
    for(i=0; i<=3; i=i+1) cache_nxt[i] = cache[i];
    mem_read_nxt = mem_read;
    mem_write_nxt = mem_write;
    mem_addr = {tag, index};
    proc_stall = 1'b1;
    case(state)
    IDLE: begin
        // read miss or write 
        if(proc_read) begin
            if(hit1) begin
                proc_stall = 1'b0;
                cache_nxt[index][312] = 1'b0;
            end
            else if(hit0) begin
                proc_stall = 1'b0;
                cache_nxt[index][312] = 1'b1;
            end
            else begin
                proc_stall = 1'b1;
                case(cache[index][312])
                1'b0: begin
                    // dirty miss
                    if(cache[index][155] & cache[index][154]) mem_write_nxt = 1'b1;
                    // clean miss
                    else mem_read_nxt = 1'b1;
                end
                1'b1: begin
                    if(cache[index][311] & cache[index][310]) mem_write_nxt = 1'b1;
                    else mem_read_nxt = 1'b1;
                end
                endcase
            end
        end
        else if( proc_write ) begin
            proc_stall = 1'b1;
        end

        // if (proc_read | proc_write ) proc_stall = 1'b1;
        else proc_stall = 1'b0;
    end
    WR: begin
        mem_addr = cache[index][312] ? {cache[index][309:284], index} : {cache[index][153:128], index};   
        if(hit1 | (cache[index][312] & !cache[index][310] & !hit0) ) begin
            cache_nxt[index][312] = 1'b0;
            proc_stall = 1'b0;
            cache_nxt[index][311] = 1;
            cache_nxt[index][310] = 1;
            cache_nxt[index][309:284] = tag;
            case(offset)
            2'd0: cache_nxt[index][187:156] = proc_wdata;
            2'd1: cache_nxt[index][219:188] = proc_wdata;
            2'd2: cache_nxt[index][251:220] = proc_wdata;
            2'd3: cache_nxt[index][283:252] = proc_wdata;
            endcase
        end
        else if(hit0 | (!cache[index][312] & !cache[index][154]) ) begin
            cache_nxt[index][312] = 1'b1;
            proc_stall = 1'b0;
            cache_nxt[index][155] = 1;
            cache_nxt[index][154] = 1;
            cache_nxt[index][153:128] = tag;
            case(offset)
            2'd0: cache_nxt[index][31:0]   = proc_wdata;
            2'd1: cache_nxt[index][63:32]  = proc_wdata;
            2'd2: cache_nxt[index][95:64]  = proc_wdata;
            2'd3: cache_nxt[index][127:96] = proc_wdata;
            endcase
        end
        else begin
            mem_write_nxt = 1'b1;
        end
        
    end
    WB: begin
        // update dirty
        case(cache[index][312])
            1'b0: cache_nxt[index][154] = 0;
            1'b1: cache_nxt[index][310] = 0;
        endcase
        mem_write_nxt = !mem_ready;
        mem_addr = cache[index][312] ? {cache[index][309:284], index} : {cache[index][153:128], index};
        mem_read_nxt = mem_ready & proc_read;
    end
    AL: begin
        case(cache[index][312])
        1'b0: begin
            cache_nxt[index][155] = 1;
            cache_nxt[index][154] = 0;
            cache_nxt[index][153:128] = tag;
            cache_nxt[index][127:0] = mem_rdata;
        end
        1'b1: begin
            cache_nxt[index][311] = 1;
            cache_nxt[index][310] = 0;
            cache_nxt[index][309:284] = tag;
            cache_nxt[index][283:156] = mem_rdata;
        end
        endcase
        mem_read_nxt = !mem_ready;
    end
    endcase
end
//==== sequential circuit =================================
always@( posedge clk ) begin
    for(i=0; i<=3; i=i+1) begin
        cache[i][309:156] <=  cache_nxt[i][309:156];
        cache[i][153:0] <=  cache_nxt[i][153:0];
    end
    if( proc_reset ) begin
        mem_write <= 0;
        mem_read  <= 0;
        state     <= IDLE;
        for(i=0; i<=3; i=i+1) begin
            cache[i][312] <= 1'b0;
            cache[i][311] <= 1'b0;
            cache[i][310] <= 1'b0;
            cache[i][155] <= 1'b0;
            cache[i][154] <= 1'b0;
        end
        
    end
    else begin
        mem_write <= mem_write_nxt;
        mem_read  <= mem_read_nxt;
        state     <= state_nxt;
        for(i=0; i<=3; i=i+1) begin
            cache[i][312] <= cache_nxt[i][312];
            cache[i][311] <= cache_nxt[i][311];
            cache[i][310] <= cache_nxt[i][310];
            cache[i][155] <= cache_nxt[i][155];
            cache[i][154] <= cache_nxt[i][154];
        end
    end
end
endmodule

/*
write_sdf -version 2.1 cache_new_syn.sdf
write -format verilog -hier -output cache_new_syn.v
write -format ddc -hier -output cache_new_syn.ddc
*/