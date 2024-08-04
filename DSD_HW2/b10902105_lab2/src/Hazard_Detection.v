module Hazard_Detection
(
    RS1addr_i,
    RS2addr_i,
    EX_MemRead_i,
    EX_RDaddr_i,
    
    NoOp_o,
    Stall_o,
    PCWrite_o
);

// Ports
input   [4:0]       RS1addr_i;
input   [4:0]       RS2addr_i;
input               EX_MemRead_i;
input   [4:0]       EX_RDaddr_i;

output              NoOp_o;
output              Stall_o;
output              PCWrite_o;

//reg                 NoOp_o;
//reg                 Stall_o;
//reg                 PCWrite_o;


assign NoOp_o = (EX_MemRead_i && ((EX_RDaddr_i == RS1addr_i) || (EX_RDaddr_i == RS2addr_i)))? 1'b1 : 1'b0;
assign Stall_o = (EX_MemRead_i && ((EX_RDaddr_i == RS1addr_i) || (EX_RDaddr_i == RS2addr_i)))? 1'b1 : 1'b0;
assign PCWrite_o = (EX_MemRead_i && ((EX_RDaddr_i == RS1addr_i) || (EX_RDaddr_i == RS2addr_i)))? 1'b0 : 1'b1;

//always@(*) begin
//    NoOp_o =    1'b0;
//    Stall_o =   1'b0;
//    PCWrite_o = 1'b1;
//    if (EX_MemRead_i && ((EX_RDaddr_i == RS1addr_i) || (EX_RDaddr_i == RS2addr_i))) begin
//        // Stall the pipeline
//        NoOp_o =    1'b1;
//        Stall_o =   1'b1;
//        PCWrite_o = 1'b0;
//    end
//end

endmodule
