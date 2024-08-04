`define TAG 29:5		// position of tag in address
`define INDEX 4:2		// position of index in address
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
    reg         vaild_r [0:7];
    reg         vaild_w [0:7];
    reg  [24:0] tag_r [0:7];
    reg  [24:0] tag_w [0:7];
    reg [127:0] mem_r [0:8];
    reg [127:0] mem_w [0:8];
    reg         mem_write_o_w, mem_write_o_r;
    reg         mem_read_o_w, mem_read_o_r;
    reg  [27:0] mem_addr_o;
    reg [127:0] mem_wdata_o;
    reg         dirty_r [0:7];
    reg         dirty_w [0:7];

    wire        hit;
    wire        read_miss;
    wire        read_hit;
    wire        write_hit;
    wire        write_miss;
    wire  [0:7] word_offset;
    wire  [2:0] index;
    wire [24:0] tag;

//=== assign ================================================
    //assign proc_stall   = proc_stall_o;
    assign proc_stall   = (proc_read | proc_write) & !hit;
    assign proc_rdata   = proc_rdata_o;
    assign mem_read     = mem_read_o_r;
    assign mem_write    = mem_write_o_r;
    assign mem_addr     = mem_addr_o;
    assign mem_wdata    = mem_wdata_o;
    assign index        = proc_addr[`INDEX];
    assign tag          = proc_addr[`TAG];
    assign word_offset  = proc_addr[`OFFSET];
    integer i;

    // HIT ?
    assign hit          = ((proc_read || proc_write) && (tag_r[index] == tag) && vaild_r[index]) ? 1'b1 : 1'b0;
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
                    if (dirty_r[index]) begin
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
                    if (dirty_r[index]) begin
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
                    if (dirty_r[index]) begin
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
                    if (dirty_r[index]) begin
                        state_w = S_MEM_WRITE_BACK;
                    end
                    else begin
                        state_w = S_MEM_READ;
                    end
                end
                else if (write_miss) begin
                    if (dirty_r[index]) begin
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
        for (i = 0; i < 8; i = i + 1) begin
            vaild_w[i]  = vaild_r[i];
            tag_w[i]    = tag_r[i];
            mem_w[i]    = mem_r[i];
            dirty_w[i]   = dirty_r[i];
        end

        //  Default
        mem_read_o_w    = mem_read_o_r;
        mem_write_o_w   = mem_write_o_r;
        proc_rdata_o    = 0;

        case (state_r)
            S_IDLE : begin
                
                //  READ HIT
                if (proc_read & hit) begin
                    proc_rdata_o = mem_r[index][(word_offset<<5) +: 32];
                end
                else begin
                    proc_rdata_o = 32'b0;
                end

                if (read_miss || write_miss) begin
                    if (dirty_r[index]) begin
                        mem_write_o_w = 1;
                    end
                    else begin
                        mem_read_o_w  = 1;
                    end
                end
            end 

            S_MEM_READ : begin
                if (mem_ready) begin
                    vaild_w[index]  = 1;
                    dirty_w[index]  = 0;
                    tag_w[index]    = tag;
                    mem_w[index]    = mem_rdata;
                    mem_read_o_w                = 0;
                end
            end

            S_MEM_WRITE_BACK : begin
                dirty_w[index]  = 0;
                if (mem_ready) begin
                    mem_write_o_w     = 0;
                    if (read_miss || write_miss) begin
                        mem_read_o_w  = 1;
                    end
                end
            end

            S_WRITE : begin

                if (read_miss || write_miss) begin
                    if (dirty_r[index]) begin
                        mem_write_o_w = 1'b1;
                    end else begin
                        mem_read_o_w = 1'b1;
                    end
                end

                if (write_hit) begin
                    mem_w[index][(word_offset<<5) +: 31]    = proc_wdata;
                    tag_w[index]                            = tag;
                    dirty_w[index]                          = 1;
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
                mem_addr_o = {tag_r[index], index};
            end

            default: begin
                mem_addr_o = 32'b0;
            end
        endcase
    end

    always @(*) begin
        if (mem_write_o_r) begin
            mem_wdata_o = mem_r[index];
        end else begin
            mem_wdata_o = 0;
        end
    end

//==== Sequential ==========================================
    always@( posedge clk ) begin
        if( proc_reset ) begin
            mem_write_o_r   <= 0;
            mem_read_o_r    <= 0;
            for (i=0 ; i < 8; i = i + 1) begin
                vaild_r[i]  <= 0;
                dirty_r[i]  <= 0;
                tag_r[i]    <= 0;
                mem_r[i]    <= 0;
            end
        end
        else begin
            mem_read_o_r    <= mem_read_o_w;
            mem_write_o_r   <= mem_write_o_w;
            for (i=0 ; i < 8; i = i + 1) begin
                vaild_r[i]  <= vaild_w[i];
                dirty_r[i]  <= dirty_w[i];
                tag_r[i]    <= tag_w[i];
                mem_r[i]    <= mem_w[i];
            end
        end
    end
endmodule