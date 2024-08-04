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

//==== localparameter ===================================== 
    localparam word_offset_bit = 2;
    localparam set_bit = 2;
    localparam tag_bit = 26;
    localparam BIT_W = 32;
    
//==== wire/reg definition ================================
    reg valid_memory_1 [0:(1<<set_bit)-1];
    reg dirty_memory_1 [0:(1<<set_bit)-1];
    reg [tag_bit-1:0] tag_memory_1 [0:(1<<set_bit)-1];
    reg [(BIT_W<<2)-1:0] data_memory_1 [0:(1<<set_bit)-1];

    reg valid_memory_nxt_1 [0:(1<<set_bit)-1];
    reg dirty_memory_nxt_1 [0:(1<<set_bit)-1];
    reg [tag_bit-1:0] tag_memory_nxt_1 [0:(1<<set_bit)-1];
    reg [(BIT_W<<2)-1:0] data_memory_nxt_1 [0:(1<<set_bit)-1];

    reg valid_memory_0 [0:(1<<set_bit)-1];
    reg dirty_memory_0 [0:(1<<set_bit)-1];
    reg [tag_bit-1:0] tag_memory_0 [0:(1<<set_bit)-1];
    reg [(BIT_W<<2)-1:0] data_memory_0 [0:(1<<set_bit)-1];

    reg valid_memory_nxt_0 [0:(1<<set_bit)-1];
    reg dirty_memory_nxt_0 [0:(1<<set_bit)-1];
    reg [tag_bit-1:0] tag_memory_nxt_0 [0:(1<<set_bit)-1];
    reg [(BIT_W<<2)-1:0] data_memory_nxt_0 [0:(1<<set_bit)-1];

    wire [7:0] word_offset;
    wire [set_bit-1:0] index;
    wire [tag_bit-1:0] tag;

    assign word_offset = proc_addr[word_offset_bit-1:0];           
    assign index = proc_addr[set_bit-1+2:2];       
    assign tag = proc_addr[tag_bit-1+4:4]; 

    localparam S_IDLE = 0;
    localparam S_READ_MISS = 1;
    localparam S_WRITE_BACK = 2;

    reg [1:0] state, state_nxt;

    reg o_mem_read, o_mem_read_nxt;
    reg o_mem_write, o_mem_write_nxt;
    reg [27:0] o_mem_addr;
    reg [127:0] o_mem_wdata;
    reg [31:0] o_proc_rdata;

    wire hit, hit1, hit0;
    wire read_hit;
    wire read_miss;
    wire write_hit;
    wire write_miss;

    reg [3:0] replace_vector, replace_vector_nxt;

    assign hit1 = ((tag_memory_1[index] == tag) && valid_memory_1[index]) ? 1'b1 : 1'b0;
    assign hit0 = ((tag_memory_0[index] == tag) && valid_memory_0[index]) ? 1'b1 : 1'b0;
    assign hit = (proc_read || proc_write) & (hit1 | hit0);
    assign read_hit = (proc_read && hit) ? 1'b1 : 1'b0;
    assign read_miss = (proc_read && !hit) ? 1'b1 : 1'b0;
    assign write_hit = (proc_write && hit) ? 1'b1 : 1'b0;
    assign write_miss = (proc_write && !hit) ? 1'b1 : 1'b0;

    assign mem_read = o_mem_read;    
    assign mem_write = o_mem_write;
    assign mem_addr = o_mem_addr;
    assign mem_wdata = o_mem_wdata;
    assign proc_rdata = o_proc_rdata;
    assign proc_stall = (proc_read | proc_write) & !hit;

    integer i;
    
//==== combinational circuit ==============================

    always @(*) begin
        for (i=0 ; i<4 ; i=i+1) begin
            if ($unsigned(i) == index) begin
                case({hit1, hit0})
                    2'b10: begin
                        replace_vector_nxt[i] = 1'b0;
                    end

                    2'b01: begin
                        replace_vector_nxt[i] = 1'b1;
                    end

                    default: begin
                        replace_vector_nxt[i] = replace_vector[i];
                    end
                endcase
            end else begin
                replace_vector_nxt[i] = replace_vector[i];
            end    
        end
    end

    always @(*) begin
        state_nxt = state;
        case(state)
            S_IDLE: begin
                case({read_hit, read_miss, write_hit, write_miss})
                    4'b1000: begin
                        state_nxt = S_IDLE;
                    end

                    4'b0100: begin
                        for (i=0 ; i<(4) ; i=i+1) begin
                            if ($unsigned(i) == $unsigned(index)) begin
                                if (replace_vector[index]) begin
                                    if (dirty_memory_1[index]) begin
                                        state_nxt = S_WRITE_BACK;
                                    end else begin
                                        state_nxt = S_READ_MISS;
                                    end
                                end else begin
                                    if (dirty_memory_0[index]) begin
                                        state_nxt = S_WRITE_BACK;
                                    end else begin
                                        state_nxt = S_READ_MISS;
                                    end
                                end
                            end
                        end
                    end

                    4'b0010: begin
                        state_nxt = S_IDLE;
                    end

                    4'b0001: begin
                        for (i=0 ; i<(4) ; i=i+1) begin
                            if ($unsigned(i) == $unsigned(index)) begin
                                if (replace_vector[index]) begin
                                    if (dirty_memory_1[index]) begin
                                        state_nxt = S_WRITE_BACK;
                                    end else begin
                                        state_nxt = S_READ_MISS;
                                    end
                                end else begin
                                    if (dirty_memory_0[index]) begin
                                        state_nxt = S_WRITE_BACK;
                                    end else begin
                                        state_nxt = S_READ_MISS;
                                    end
                                end
                            end
                        end
                    end
                    
                    default: begin
                        state_nxt = S_IDLE;
                    end
                endcase
            end

            S_READ_MISS: begin
                if (mem_ready) begin
                    state_nxt = S_IDLE;
                end
            end

            S_WRITE_BACK: begin
                if (mem_ready) begin
                    state_nxt = S_READ_MISS;
                end
            end
        endcase
    end

    always @(*) begin
        for (i=0 ; i<(1<<set_bit) ; i=i+1) begin
            valid_memory_nxt_0[i] = valid_memory_0[i];
            dirty_memory_nxt_0[i] = dirty_memory_0[i];
            tag_memory_nxt_0[i] = tag_memory_0[i];
            data_memory_nxt_0[i] = data_memory_0[i];

            valid_memory_nxt_1[i] = valid_memory_1[i];
            dirty_memory_nxt_1[i] = dirty_memory_1[i];
            tag_memory_nxt_1[i] = tag_memory_1[i];
            data_memory_nxt_1[i] = data_memory_1[i];
        end

        case(state)
            S_IDLE: begin
                if (write_hit) begin
                    for (i=0 ; i<(4) ; i=i+1) begin
                        if ($unsigned(i) == $unsigned(index)) begin
                            if (hit1) begin
                                data_memory_nxt_1[i][(word_offset<<5) +: 32] = proc_wdata;
                                tag_memory_nxt_1[i] = tag;
                                dirty_memory_nxt_1[i] = 1'b1;
                            end else begin
                                data_memory_nxt_0[i][(word_offset<<5) +: 32] = proc_wdata;
                                tag_memory_nxt_0[i] = tag;
                                dirty_memory_nxt_0[i] = 1'b1;
                            end
                        end
                    end
                end
            end

            S_READ_MISS: begin
                if (mem_ready) begin
                    for (i=0 ; i<(4) ; i=i+1) begin
                        if ($unsigned(i) == $unsigned(index)) begin
                            if (replace_vector[i]) begin
                                valid_memory_nxt_1[i] = 1'b1;
                                dirty_memory_nxt_1[i] = 1'b0;
                                tag_memory_nxt_1[i] = tag;
                                data_memory_nxt_1[i] = mem_rdata;
                            end else begin
                                valid_memory_nxt_0[i] = 1'b1;
                                dirty_memory_nxt_0[i] = 1'b0;
                                tag_memory_nxt_0[i] = tag;
                                data_memory_nxt_0[i] = mem_rdata;
                            end
                        end
                    end
                end
            end

            S_WRITE_BACK: begin
                for (i=0 ; i<(4) ; i=i+1) begin
                    if ($unsigned(i) == $unsigned(index)) begin
                        if (replace_vector[i]) begin
                            dirty_memory_nxt_1[i] = 1'b0;
                        end else begin
                            dirty_memory_nxt_0[i] = 1'b0;
                        end
                    end
                end
            end
        endcase
    end

    always @(*) begin
        o_mem_read_nxt = o_mem_read;
        o_mem_write_nxt = o_mem_write;
        case(state)
            S_IDLE: begin
                if (read_miss | write_miss) begin
                    for (i=0 ; i<(4) ; i=i+1) begin
                        if ($unsigned(i) == $unsigned(index)) begin
                            if (replace_vector[index]) begin
                                if (dirty_memory_1[index]) begin
                                    o_mem_write_nxt = 1'b1;
                                end else begin
                                    o_mem_read_nxt = 1'b1;
                                end
                            end else begin
                                if (dirty_memory_0[index]) begin
                                    o_mem_write_nxt = 1'b1;
                                end else begin
                                    o_mem_read_nxt = 1'b1;
                                end
                            end
                        end
                    end
                end
            end

            S_READ_MISS: begin
                if (mem_ready) begin
                    o_mem_read_nxt = 1'b0;
                end
            end

            S_WRITE_BACK: begin
                if (mem_ready) begin
                    o_mem_write_nxt = 1'b0;

                    if (read_miss | write_miss) begin
                        o_mem_read_nxt = 1'b1;
                    end
                end
            end
        endcase
    end

    always @(*) begin
        case({o_mem_read, o_mem_write})
            2'b10: begin
                o_mem_addr = {tag, index};
            end

            2'b01: begin
                if (replace_vector[index]) begin
                    o_mem_addr = {tag_memory_1[index], index};
                end else begin
                    o_mem_addr = {tag_memory_0[index], index};
                end
            end

            default: begin
                o_mem_addr = 32'b0;
            end
        endcase
    end

    always @(*) begin
        if (o_mem_write) begin
            if (replace_vector[index]) begin
                o_mem_wdata = data_memory_1[index];
            end else begin
                o_mem_wdata = data_memory_0[index];
            end
        end else begin
            o_mem_wdata = 128'b0;
        end
    end

    always @(*) begin
        if (proc_read & hit) begin
            if (hit1) begin
                o_proc_rdata = data_memory_1[index][(word_offset<<5) +: 32];
            end else begin
                o_proc_rdata = data_memory_0[index][(word_offset<<5) +: 32];
            end
        end else begin
            o_proc_rdata = 32'b0;
        end
    end

//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
        state <= S_IDLE;
        o_mem_read <= 1'b0;
        o_mem_write <= 1'b0;
        replace_vector <= 4'b0;
        for (i=0 ; i<(1<<set_bit) ; i=i+1) begin
            valid_memory_0[i] <= 0;
            dirty_memory_0[i] <= 0;
            tag_memory_0[i] <= 0;
            data_memory_0[i] <= 0;

            valid_memory_1[i] <= 0;
            dirty_memory_1[i] <= 0;
            tag_memory_1[i] <= 0;
            data_memory_1[i] <= 0;
        end
    end
    else begin
        state <= state_nxt;
        o_mem_read <= o_mem_read_nxt;
        o_mem_write <= o_mem_write_nxt;
        replace_vector <= replace_vector_nxt;
        for (i=0 ; i<(1<<set_bit) ; i=i+1) begin
            valid_memory_0[i] <= valid_memory_nxt_0[i];
            dirty_memory_0[i] <= dirty_memory_nxt_0[i];
            tag_memory_0[i] <= tag_memory_nxt_0[i];
            data_memory_0[i] <= data_memory_nxt_0[i];

            valid_memory_1[i] <= valid_memory_nxt_1[i];
            dirty_memory_1[i] <= dirty_memory_nxt_1[i];
            tag_memory_1[i] <= tag_memory_nxt_1[i];
            data_memory_1[i] <= data_memory_nxt_1[i];
        end
    end
end

endmodule
