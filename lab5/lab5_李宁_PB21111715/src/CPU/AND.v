`timescale 1ns / 1ps
// AND模块
module AND(
    input [31:0] a,
    input [31:0] b,
    output [31:0] out
);
assign out = a & b;
endmodule
