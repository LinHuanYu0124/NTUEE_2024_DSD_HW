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

    localparam word_offset_bit = 2;
    localparam block_bit = 3;
    localparam tag_bit = 25;
    localparam BIT_W = 32;

//==== wire/reg definition ================================
    reg valid_memory [0:(8)-1];
    reg [tag_bit-1:0] tag_memory [0:(8)-1];
    reg [(BIT_W<<2)-1:0] data_memory [0:(8)-1];

    reg valid_memory_nxt [0:(8)-1];
    reg [tag_bit-1:0] tag_memory_nxt [0:(8)-1];
    reg [(BIT_W<<2)-1:0] data_memory_nxt [0:(8)-1];

    wire [7:0] word_offset;
    wire [block_bit-1:0] index;
    wire [tag_bit-1:0] tag;

    assign word_offset = proc_addr[word_offset_bit-1:0];           
    assign index = proc_addr[block_bit-1+2:2];       
    assign tag = proc_addr[tag_bit-1+5:5]; 

    localparam S_IDLE = 0;
    localparam S_READ_MISS = 1;
    localparam S_WRITE_BACK = 2;

    reg [1:0] state, state_nxt;

    reg o_mem_read, o_mem_read_nxt;
    reg [27:0] o_mem_addr;
    reg [127:0] o_mem_wdata;
    reg [31:0] o_proc_rdata;

    wire hit;
    assign hit = ((proc_read) && (tag_memory[index] == tag) && valid_memory[index]);

    assign mem_read = o_mem_read;    
    assign mem_write = 1'b0;
    assign mem_addr = o_mem_addr;
    assign mem_wdata = 128'b0;
    assign proc_rdata = o_proc_rdata;
    assign proc_stall = !hit;

    integer i;
    
//==== combinational circuit ==============================

    // FSM
    always @(*) begin
        state_nxt = state;
        case(state)
            S_IDLE: begin
                if (!hit) begin
                    state_nxt = S_READ_MISS;
                end else begin
                    state_nxt = S_IDLE;
                end
            end

            S_READ_MISS: begin
                if (mem_ready) begin
                    state_nxt = S_IDLE;
                end
            end
        endcase
    end

    always @(*) begin
        for (i=0 ; i<(8) ; i=i+1) begin
            valid_memory_nxt[i] = valid_memory[i];
            tag_memory_nxt[i] = tag_memory[i];
            data_memory_nxt[i] = data_memory[i];
        end

        if (state == S_READ_MISS) begin
            if (mem_ready) begin
                for (i=0 ; i<(8) ; i=i+1) begin
                    if ($unsigned(i) == $unsigned(index)) begin
                        valid_memory_nxt[i] = 1'b1;
                        tag_memory_nxt[i] = tag;
                        data_memory_nxt[i] = mem_rdata;
                    end
                end
            end 
        end
    end

    always @(*) begin
        o_mem_read_nxt = o_mem_read;
        
        case(state)
            S_IDLE: begin
                if (!hit) begin
                    o_mem_read_nxt = 1'b1;
                end
            end

            S_READ_MISS: begin
                if (mem_ready) begin
                    o_mem_read_nxt = 1'b0;
                end
            end
        endcase
    end

    always @(*) begin
        if (o_mem_read) begin
            o_mem_addr = {tag, index};
        end else begin
            o_mem_addr = 32'b0;
        end
    end

    always @(*) begin
        if (hit) begin
            o_proc_rdata = data_memory[index][(word_offset<<5) +: 32];
        end else begin
            o_proc_rdata = 32'b0;
        end
    end


//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
        state <= S_IDLE;
        o_mem_read <= 1'b0;
        for (i=0 ; i<(8) ; i=i+1) begin
            valid_memory[i] <= 0;
            tag_memory[i] <= 0;
            data_memory[i] <= 0;
        end
    end
    else begin
        state <= state_nxt;
        o_mem_read <= o_mem_read_nxt;
        for (i=0 ; i<(8) ; i=i+1) begin
            valid_memory[i] <= valid_memory_nxt[i];
            tag_memory[i] <= tag_memory_nxt[i];
            data_memory[i] <= data_memory_nxt[i];
        end
    end
end

endmodule

