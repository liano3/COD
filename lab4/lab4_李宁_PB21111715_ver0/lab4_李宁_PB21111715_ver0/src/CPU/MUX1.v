`timescale 1ns / 1ps
// alu 操作数选择模块
module MUX1(
    input [31:0] sr0,
    input [31:0] sr1,
    input alu_sel,
    output [31:0] sr_out
);
assign sr_out = (alu_sel == 1'b0) ? sr0 : sr1;
endmodule
