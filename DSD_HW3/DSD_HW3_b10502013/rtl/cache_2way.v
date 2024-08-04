`define TAG 29:4		// position of tag in address
`define INDEX 3:2		// position of index in address
`define OFFSET 1:0      // position of offset in address

module cache(
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

    
//=== reg/wire definition ===================================
    reg   [1:0] state_r , state_w;
    reg  [31:0] proc_rdata_o;
    reg         mem_write_o_w, mem_write_o_r;
    reg         mem_read_o_w, mem_read_o_r;
    reg  [27:0] mem_addr_o;
    reg [127:0] mem_wdata_o;
    reg         vaild0_r [0:3];
    reg         vaild0_w [0:3];
    reg         vaild1_r [0:3];
    reg         vaild1_w [0:3];
    reg  [24:0] tag0_r [0:3];
    reg  [24:0] tag0_w [0:3];
    reg  [24:0] tag1_r [0:3];
    reg  [24:0] tag1_w [0:3];
    reg [127:0] mem0_r [0:3];
    reg [127:0] mem0_w [0:3];
    reg [127:0] mem1_r [0:3];
    reg [127:0] mem1_w [0:3];
    reg         dirty0_r [0:3];
    reg         dirty0_w [0:3];
    reg         dirty1_r [0:3];
    reg         dirty1_w [0:3];
    reg   [3:0] out_data_r;
    reg   [3:0] out_data_w;

    wire        hit, hit0, hit1;
    wire  [0:7] word_offset;
    wire  [1:0] index;
    wire [25:0] tag;
    wire        read_miss;
    wire        read_hit;
    wire        write_hit;
    wire        write_miss;

//=== assign ================================================
    assign proc_stall   = (proc_read | proc_write) & !hit;
    assign proc_rdata   = proc_rdata_o;
    assign mem_read     = mem_read_o_r;
    assign mem_write    = mem_write_o_r;
    assign mem_addr     = mem_addr_o;
    assign mem_wdata    = mem_wdata_o;
    assign word_offset  = proc_addr[`OFFSET];
    assign index        = proc_addr[`INDEX];
    assign tag          = proc_addr[`TAG];
    integer i;

    // HIT ?
    assign hit0         = ((tag0_r[index] == tag) && vaild0_r[index]) ? 1'b1 : 1'b0;
    assign hit1         = ((tag1_r[index] == tag) && vaild1_r[index]) ? 1'b1 : 1'b0;
    assign hit          = ((proc_read || proc_write) && (hit1 || hit0) ) ? 1'b1 : 1'b0;
    assign read_miss    = (proc_read && !hit) ? 1'b1 : 1'b0;
    assign write_miss   = (proc_write && !hit) ? 1'b1 : 1'b0;
    assign read_hit     = (proc_read && hit) ? 1'b1 : 1'b0;
    assign write_hit    = (proc_write && hit) ? 1'b1 : 1'b0;
    

//=== FSM ==================================================
    parameter S_IDLE            = 0;
    parameter S_MEM_READ        = 1;
    parameter S_MEM_WRITE_BACK  = 2;
    parameter S_WRITE           = 3;
    
    always @(*) begin
        state_w = state_r;
        case (state_r)
            S_IDLE : begin
                if (read_hit) begin
                    state_w = S_IDLE;
                end
                else if (read_miss) begin
                    if (dirty1_r[index] && out_data_r[index]) begin
                        state_w = S_MEM_WRITE_BACK;
                    end
                    else if (dirty0_r[index] && !out_data_r[index]) begin
                        state_w = S_MEM_WRITE_BACK;
                    end
                    else begin
                        state_w = S_MEM_READ;
                    end
                end
                else if (write_hit) begin
                    state_w = S_WRITE;
                end
                else if (write_miss) begin
                    if (dirty1_r[index] && out_data_r[index]) begin
                        state_w = S_MEM_WRITE_BACK;
                    end
                    else if (dirty0_r[index] && !out_data_r[index]) begin
                        state_w = S_MEM_WRITE_BACK;
                    end
                    else begin
                        state_w = S_MEM_READ;
                    end
                end
                else begin
                    state_w = state_r;
                end
            end 

            S_MEM_READ : begin
                if(mem_ready) begin
                    if (write_miss) begin
                        state_w = S_WRITE;
                    end
                    else if(read_miss) begin
                        state_w = S_IDLE;
                    end
                    else begin
                        state_w = state_r;
                    end
                end
                else begin
                    state_w = state_r;
                end
            end

            S_MEM_WRITE_BACK : begin
                if (mem_ready) begin
                    state_w = S_MEM_READ;
                end
                else begin
                    state_w = state_r;
                end
            end

            S_WRITE : begin
                if(write_hit) begin
                    state_w = S_WRITE;
                end
                else if (write_miss) begin
                    if (dirty1_r[index] && out_data_r[index]) begin
                        state_w = S_MEM_WRITE_BACK;
                    end
                    else if (dirty0_r[index] && !out_data_r[index]) begin
                        state_w = S_MEM_WRITE_BACK;
                    end
                    else begin
                        state_w = S_MEM_READ;
                    end
                end
                else if (read_hit) begin
                    state_w = S_IDLE;
                end
                else if (read_miss) begin
                    if (dirty1_r[index] && out_data_r[index]) begin
                        state_w = S_MEM_WRITE_BACK;
                    end
                    else if (dirty0_r[index] && !out_data_r[index]) begin
                        state_w = S_MEM_WRITE_BACK;
                    end
                    else begin
                        state_w = S_MEM_READ;
                    end
                end
                else begin
                    state_w = state_r;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        if (proc_reset) begin
            state_r <= S_IDLE;
        end
        else begin
            state_r <= state_w;
        end
    end

//=== Combinational ========================================
    always @(*) begin
        for (i=0 ; i<4 ; i=i+1) begin
            if (i == word_offset) begin
                case({hit, hit1, hit0})
                    3'b110: begin
                        out_data_w[i] = 1'b0;
                    end

                    3'b101: begin
                        out_data_w[i] = 1'b1;
                    end

                    default: begin
                        out_data_w[i] = out_data_r[i];
                    end
                endcase
            end 
            else begin
                out_data_w[i] = out_data_r[i];
            end    
        end
    end
    
    always @(*) begin
        for (i = 0; i < 4; i = i + 1) begin
            vaild0_w[i]  = vaild0_r[i];
            tag0_w[i]    = tag0_r[i];
            mem0_w[i]    = mem0_r[i];
            dirty0_w[i]  = dirty0_r[i];
            vaild1_w[i]  = vaild1_r[i];
            tag1_w[i]    = tag1_r[i];
            mem1_w[i]    = mem1_r[i];
            dirty1_w[i]  = dirty1_r[i];
        end

        mem_read_o_w    = mem_read_o_r;
        mem_write_o_w   = mem_write_o_r;
        proc_rdata_o    = 0;

        case (state_r)
            S_IDLE : begin
                
                //  READ HIT
                if (proc_read & hit) begin
                    if (hit0) begin
                        proc_rdata_o = mem0_r[index][(word_offset<<5) +: 32];    
                    end
                    else begin
                        proc_rdata_o = mem1_r[index][(word_offset<<5) +: 32];    
                    end
                end
                else begin
                    proc_rdata_o = 32'b0;
                end

                if (read_miss || write_miss) begin
                    if (dirty1_r[index] && out_data_r[index]) begin
                        mem_write_o_w   = 1;
                    end
                    else if (dirty0_r[index] && !out_data_r[index]) begin
                        mem_write_o_w   = 1;
                    end
                    else begin
                        mem_read_o_w    = 1;
                    end
                end
            end 

            S_MEM_READ : begin
                if (mem_ready) begin
                    if (out_data_r[index]) begin
                        vaild1_w[index]  = 1;
                        dirty1_w[index]  = 0;
                        tag1_w[index]    = tag;
                        mem1_w[index]    = mem_rdata;
                    end
                    else begin
                        vaild0_w[index]  = 1;
                        dirty0_w[index]  = 0;
                        tag0_w[index]    = tag;
                        mem0_w[index]    = mem_rdata;
                    end
                    mem_read_o_w         = 0;
                end
            end

            S_MEM_WRITE_BACK : begin
                if (out_data_r[index]) begin
                    dirty1_w[index] = 0;
                end
                else begin
                    dirty0_w[index] = 0;
                end
                if (mem_ready) begin
                    mem_write_o_w     = 0;
                    if (read_miss || write_miss) begin
                        mem_read_o_w  = 1;
                    end
                end
            end

            S_WRITE : begin
                if (read_miss || write_miss) begin
                    if (dirty1_r[index] && out_data_r[index]) begin
                        mem_write_o_w   = 1;
                    end
                    else if (dirty0_r[index] && !out_data_r[index]) begin
                        mem_write_o_w   = 1;
                    end
                    else begin
                            mem_read_o_w    = 1;
                    end
                end

                if (write_hit) begin
                    if (hit1) begin
                        mem1_w[index][(word_offset<<5) +: 31]    = proc_wdata;   
                        tag1_w[index]                            = tag;
                        dirty1_w[index]                          = 1;
                    end
                    else begin
                        mem0_w[index][(word_offset<<5) +: 31]    = proc_wdata;
                        tag0_w[index]                            = tag;
                        dirty0_w[index]                          = 1;
                    end
                end
            end
        endcase
    end

    always @(*) begin
        case({mem_read_o_r, mem_write_o_r})
            2'b10: begin
                mem_addr_o = {tag, index};
            end

            2'b01: begin
                if (out_data_r[index]) begin
                    mem_addr_o = {tag1_r[index], index};
                end
                else begin
                    mem_addr_o = {tag0_r[index], index};
                end
            end

            default: begin
                mem_addr_o = 32'b0;
            end
        endcase
    end

    always @(*) begin
        if (mem_write_o_r) begin
            if (out_data_r[index]) begin
                mem_wdata_o = mem1_r[index];
            end
            else begin
                mem_wdata_o = mem0_r[index];
            end
        end else begin
            mem_wdata_o = 0;
        end
    end

    

//==== Sequential ==========================================
    always@( posedge clk ) begin
        if( proc_reset ) begin
            mem_write_o_r   <= 0;
            mem_read_o_r    <= 0;
            for (i = 0; i < 4; i = i + 1 ) begin
                vaild1_r[i]  <= 0;
                dirty1_r[i]  <= 0;
                tag1_r[i]    <= 0;
                mem1_r[i]    <= 0;
                vaild0_r[i]  <= 0;
                dirty0_r[i]  <= 0;
                tag0_r[i]    <= 0;
                mem0_r[i]    <= 0;
                out_data_r[i] <= 0;
            end
        end
        else begin
            mem_read_o_r    <= mem_read_o_w;
            mem_write_o_r   <= mem_write_o_w;
            for (i=0 ; i < 4; i = i + 1) begin
                vaild1_r[i]  <= vaild1_w[i];
                dirty1_r[i]  <= dirty1_w[i];
                tag1_r[i]    <= tag1_w[i];
                mem1_r[i]    <= mem1_w[i];
                vaild0_r[i]  <= vaild0_w[i];
                dirty0_r[i]  <= dirty0_w[i];
                tag0_r[i]    <= tag0_w[i];
                mem0_r[i]    <= mem0_w[i];
                out_data_r[i] <= out_data_w[i];
            end
        end
    end
endmodule