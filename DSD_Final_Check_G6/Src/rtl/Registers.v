module Registers
(
    rst_i,
    clk_i,
    RS1addr_i,
    RS2addr_i,
    JALR_RS1addr_i,
    RDaddr_i, 
    RDdata_i,
    RegWrite_i, 
    RS1data_o, 
    RS2data_o,
    JALR_RS1data_o
);

// Ports
input               rst_i;
input               clk_i;
input   [4:0]       RS1addr_i;
input   [4:0]       RS2addr_i;
input   [4:0]       JALR_RS1addr_i;
input   [4:0]       RDaddr_i;
input   [31:0]      RDdata_i;
input               RegWrite_i;
output  [31:0]      RS1data_o; 
output  [31:0]      RS2data_o;
output  [31:0]      JALR_RS1data_o;

integer i;

// Register File
reg [31:0] mem [0:31];     
reg [31:0] mem_nxt [0:31];  

// Read Data      
assign  RS1data_o = (RS1addr_i == RDaddr_i && RegWrite_i && RDaddr_i != 0)? RDdata_i : mem[RS1addr_i];
assign  RS2data_o = (RS2addr_i == RDaddr_i && RegWrite_i && RDaddr_i != 0)? RDdata_i : mem[RS2addr_i];

assign  JALR_RS1data_o = mem[JALR_RS1addr_i];

always @(*) begin
    for (i=0; i<32; i=i+1) 
        mem_nxt[i] = (RegWrite_i && (RDaddr_i == i)) ? RDdata_i : mem[i]; 
end  

// Write Data   
always@(posedge clk_i or negedge rst_i) begin
    if (~rst_i) begin
        for (i=0; i<32; i=i+1) begin
            mem[i] <= 0;
        end
    end
    else begin
        mem[0] <= 0;
        for (i=1; i<32; i=i+1) begin
            mem[i] <= mem_nxt[i];
        end
    end
end
   
endmodule 
