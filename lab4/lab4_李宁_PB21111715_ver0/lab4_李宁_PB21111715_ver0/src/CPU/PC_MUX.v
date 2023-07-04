`timescale 1ns / 1ps
// PC 数据选择器
module PC_MUX(
    input [31:0] pc_add4,
    input [31:0] alu_res,
    input [31:0] pc_jalr,
    input jal, jalr, br,
    output reg [31:0] pc_next
);
always @(*) begin
    if (jal || br)
        pc_next = alu_res;
    else if (jalr)
        pc_next = pc_jalr;
    else
        pc_next = pc_add4;
end
endmodule
