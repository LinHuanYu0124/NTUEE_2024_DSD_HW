/*
module cache_i(
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
    localparam IDLE = 0;
    localparam AL   = 1;

    reg state, state_nxt;

    reg mem_read, mem_read_nxt;
    reg [27:0] mem_addr;
    reg [31:0] proc_rdata;
    reg proc_stall, proc_stall_nxt;
    // 1bit lru + (1bit valid + 26bit tag + 128bit data) x2 sets
    // [310] | [309][308:283][282:155] | [154][153:128][127:0]
    reg [310:0] cache     [0:3];
    reg [310:0] cache_nxt [0:3];
    wire [1:0] offset;
    wire [1:0] index;
    wire [25:0] tag;
    wire hit1, hit0;
    integer i;
    // for debug
    wire lru;
    wire val0,val1, dir0,dir1;
//==== combinational circuit ==============================
// decode proc_addr to 25bit tag + 3bit index + 2bit block offset
assign offset = proc_addr[1:0];
assign index  = proc_addr[3:2];
assign tag    = proc_addr[29:4];
assign hit1 = cache[index][309] && (tag == cache[index][308:283]);
assign hit0 = cache[index][154] && (tag == cache[index][153:128]);

// read only
assign mem_wdata = 128'd0;
assign mem_write = 1'b0;


always@(*) begin
    if(hit1) begin
        case(offset)
        2'd0: proc_rdata = cache[index][186:155];
        2'd1: proc_rdata = cache[index][218:187];
        2'd2: proc_rdata = cache[index][250:219];
        2'd3: proc_rdata = cache[index][282:251];
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
        if(proc_read & !hit1 & !hit0) state_nxt = AL;
        else state_nxt = IDLE;
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
    mem_addr = {tag, index};
    proc_stall = 1'b1;
    case(state)
    IDLE: begin
        // read miss or write 
        if(proc_read) begin
            if(hit1) begin
                proc_stall = 1'b0;
                cache_nxt[index][310] = 1'b0;
            end
            else if(hit0) begin
                proc_stall = 1'b0;
                cache_nxt[index][310] = 1'b1;
            end
            else begin
                proc_stall = 1'b1;
                mem_read_nxt = 1'b1;
            end
        end
        else proc_stall = 1'b0;
    end
    AL: begin
        case(cache[index][310])
        1'b0: begin
            cache_nxt[index][154] = 1;
            cache_nxt[index][153:128] = tag;
            cache_nxt[index][127:0] = mem_rdata;
        end
        1'b1: begin
            cache_nxt[index][309] = 1;
            cache_nxt[index][308:283] = tag;
            cache_nxt[index][282:155] = mem_rdata;
        end
        endcase
        mem_read_nxt = !mem_ready;
    end
    endcase
end
//==== sequential circuit =================================
always@( posedge clk ) begin
    for(i=0; i<=3; i=i+1) begin
        cache[i][308:155] <=  cache_nxt[i][308:155];
        cache[i][153:0]   <=  cache_nxt[i][153:0];
    end
    if( proc_reset ) begin
        mem_read  <= 0;
        state     <= IDLE;
        for(i=0; i<=3; i=i+1) begin
            cache[i][310] <= 1'b0;
            cache[i][309] <= 1'b0;
            cache[i][154] <= 1'b0;
        end
    end
    else begin
        mem_read  <= mem_read_nxt;
        state     <= state_nxt;
        for(i=0; i<=3; i=i+1) begin
            cache[i][310] <= cache_nxt[i][310];
            cache[i][309] <= cache_nxt[i][309];
            cache[i][154] <= cache_nxt[i][154];
        end
    end
end
endmodule
*/


// dm cache
module cache_i(
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
    localparam IDLE = 0;
    localparam AL   = 1;

    reg state, state_nxt;

    reg mem_read, mem_read_nxt;
    reg [27:0] mem_addr;
    reg [31:0] proc_rdata;
    reg proc_stall, proc_stall_nxt;
    // 1bit valid + 25bit tag + 128bit data
    // [153][152:128][127:0]
    reg [153:0] cache     [0:7];
    reg [153:0] cache_nxt [0:7];
    wire [1:0] offset;
    wire [2:0] index;
    wire [24:0] tag;
    wire hit;
    integer i;

//==== combinational circuit ==============================
// decode proc_addr to 25bit tag + 3bit index + 2bit block offset
assign offset = proc_addr[1:0];
assign index  = proc_addr[4:2];
assign tag    = proc_addr[29:5];
assign hit = cache[index][153] && (tag == cache[index][152:128]);

// read only
assign mem_wdata = 128'd0;
assign mem_write = 1'b0;


always@(*) begin
    case(offset)
    2'd0: proc_rdata = cache[index][31:0];
    2'd1: proc_rdata = cache[index][63:32];
    2'd2: proc_rdata = cache[index][95:64];
    2'd3: proc_rdata = cache[index][127:96];
    endcase
end
//==== FSM ================================================
always@(*) begin
    case(state)
    IDLE: begin
        if(proc_read & !hit) state_nxt = AL;
        else state_nxt = IDLE;
    end
    AL: begin
        if(mem_ready) state_nxt = IDLE;
        else state_nxt = AL;
    end
    endcase
end

always@(*) begin
    // default values
    for(i=0; i<=7; i=i+1) cache_nxt[i] = cache[i];
    mem_read_nxt = mem_read;
    mem_addr = {tag, index};
    proc_stall = 1'b1;
    case(state)
    IDLE: begin
        if(proc_read) begin
            if(hit) begin
                proc_stall = 1'b0;
            end
            else begin
                proc_stall = 1'b1;
                mem_read_nxt = 1'b1;
            end
        end
        else proc_stall = 1'b0;
    end
    AL: begin
        cache_nxt[index][153] = 1;
        cache_nxt[index][152:128] = tag;
        cache_nxt[index][127:0] = mem_rdata;
        mem_read_nxt = !mem_ready;
    end
    endcase
end
//==== sequential circuit =================================
always@( posedge clk ) begin
    for(i=0; i<=7; i=i+1) begin
        cache[i][152:0]   <=  cache_nxt[i][152:0];
    end
    if( proc_reset ) begin
        mem_read  <= 0;
        state     <= IDLE;
        for(i=0; i<=7; i=i+1) begin
            cache[i][153] <= 1'b0;
        end
    end
    else begin
        mem_read  <= mem_read_nxt;
        state     <= state_nxt;
        for(i=0; i<=7; i=i+1) begin
            cache[i][153] <= cache_nxt[i][153];
        end
    end
end
endmodule