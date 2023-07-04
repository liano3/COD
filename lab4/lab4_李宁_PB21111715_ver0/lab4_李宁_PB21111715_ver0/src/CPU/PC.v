`timescale 1ns / 1ps
// PC寄存器模块
module PC(
    input clk,
    input rst,
    input [31:0] pc_next,
    output reg [31:0] pc_cur
);
always @(posedge clk or posedge rst) begin
    if (rst)
        pc_cur <= 16'h2ffc;
    else
        pc_cur <= pc_next;
end
endmodule
