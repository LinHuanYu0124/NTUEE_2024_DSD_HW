module ALU (
    Data1_i,
    Data2_i,
    ALUSignal_i,
    ALUResult_o
);

    input   signed  [31:0]  Data1_i;
    input   signed  [31:0]  Data2_i;
    input   [3:0]   ALUSignal_i;

    output signed [31:0]  ALUResult_o;

    localparam  ADD = 4'd0;
    localparam  SUB = 4'd1;
    localparam  AND = 4'd2;
    localparam  OR  = 4'd3;
    localparam  SLT = 4'd4;
    localparam  MUL = 4'd5;
    localparam  XOR = 4'd6;
    localparam  SL = 4'd7;
    localparam  SRA = 4'd8;
    localparam  SRL = 4'd9;

    reg signed  [31:0]  ALUResult_r;

    assign ALUResult_o = ALUResult_r;

    always @(*) begin
        case (ALUSignal_i) // synopsys full_case

            ADD: begin
                ALUResult_r = $signed(Data1_i) + $signed(Data2_i);
            end

            SUB: begin
                ALUResult_r = $signed(Data1_i) - $signed(Data2_i);
            end

            AND: begin
                ALUResult_r = Data1_i & Data2_i;
            end

            OR: begin
                ALUResult_r = Data1_i | Data2_i;
            end

            SLT: begin
                ALUResult_r = ($signed(Data1_i) < $signed(Data2_i)) ? 32'b1 : 32'b0;
            end

            MUL: begin
                ALUResult_r = Data1_i * Data2_i;
            end

            XOR: begin
                ALUResult_r = Data1_i ^ Data2_i;
            end 

            SL: begin
                ALUResult_r = Data1_i << Data2_i;
            end

            SRA: begin
                ALUResult_r = Data1_i >>> Data2_i;
            end

            SRL: begin
                ALUResult_r = Data1_i >> Data2_i;
            end

        endcase
    end

endmodule