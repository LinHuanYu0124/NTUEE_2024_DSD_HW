module MUX2_32 (
    I0_i,
    I1_i,
    sel_i,
    MuxOut_o
);

input   [31:0]  I0_i;
input   [31:0]  I1_i;
input           sel_i;
output  [31:0]  MuxOut_o;

assign MuxOut_o = (sel_i) ? I1_i : I0_i;
        
endmodule

module MUX4_32 (
    I0_i,
    I1_i,
    I2_i,
    I3_i,
    sel_i,
    MuxOut_o
);

input   [31:0]  I0_i, I1_i, I2_i, I3_i;
input   [1:0]   sel_i;
output reg [31:0]  MuxOut_o;

always @(*) begin
    case(sel_i)
        2'b00: begin
            MuxOut_o = I0_i;
        end

        2'b01: begin
            MuxOut_o = I1_i;
        end

        2'b10: begin
            MuxOut_o = I2_i;
        end

        default: begin
            MuxOut_o = I3_i;
        end
    endcase
end
    
endmodule

module MUX3_32 (
    I0_i,
    I1_i,
    I2_i,
    sel_i,
    MuxOut_o
);

input   [31:0]  I0_i, I1_i, I2_i;
input   [1:0]   sel_i;
output reg [31:0]  MuxOut_o;

always @(*) begin
    case(sel_i) // synopsys full_case
        2'b00: MuxOut_o = I0_i;
        2'b01: MuxOut_o = I1_i;
        2'b10: MuxOut_o = I2_i;
    endcase
end
    
endmodule