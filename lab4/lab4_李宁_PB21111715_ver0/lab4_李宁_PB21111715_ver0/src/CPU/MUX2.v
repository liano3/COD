`timescale 1ns / 1ps
// 寄存器写入数据选择模块
module MUX2(
    input [31:0] sr0,
    input [31:0] sr1,
    input [31:0] sr2,
    input [31:0] sr3,
    input [1:0] wb_sel,
    output reg [31:0] sr_out
);
always @(*) begin
    case (wb_sel)
        2'b00: sr_out = sr0;
        2'b01: sr_out = sr1;
        2'b10: sr_out = sr2;
        2'b11: sr_out = sr3; 
        default: sr_out = 32'b0; 
    endcase
end
endmodule
