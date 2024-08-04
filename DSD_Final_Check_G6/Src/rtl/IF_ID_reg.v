module IFIDreg 
(
    clk_i,
    rst_i,
    IF_ID_Write_i,
    flush_i,
    Instr_i,
    PC_i,
    Instr_o,
    PC_o,
    imm_i,
    imm_o
);

    // I/O
    input clk_i, rst_i;
    input IF_ID_Write_i, flush_i;
    input [31:0] Instr_i, PC_i, imm_i;
    output [31:0] Instr_o, PC_o, imm_o;

    // registers and wires
    reg [31:0] instr_r, PC_r, imm_r;
    wire [31:0] instr_w, PC_w, imm_w;

    // output assignment
    assign Instr_o = instr_r;
    assign PC_o = PC_r;
    assign imm_o = imm_r;

    assign instr_w = (flush_i) ? 32'b0 :
                    (IF_ID_Write_i) ? Instr_i : instr_r;

    assign PC_w = (flush_i) ? 32'b0 : 
                    (IF_ID_Write_i) ? PC_i : PC_r;

    assign imm_w = (flush_i) ? 32'b0 : 
                    (IF_ID_Write_i) ? imm_i : imm_r;

    always@(posedge clk_i or negedge rst_i) begin
        if(!rst_i) begin
            instr_r <= 32'b0;
            PC_r <= 32'b0;
            imm_r <= 32'b0;
        end
        else begin
            instr_r <= instr_w;
            PC_r <= PC_w;
            imm_r <= imm_w;
        end
    end

endmodule