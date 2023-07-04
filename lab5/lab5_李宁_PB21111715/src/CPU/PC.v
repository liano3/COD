`timescale 1ns / 1ps
// PC寄存器模块
module PC(
    input clk,
    input rst,
    input stall_if,
    input [31:0] pc_next,
    output reg [31:0] pc_cur
);
initial begin
    pc_cur = 32'h2ffc;
end
always @(posedge clk) begin
    if (rst)
        pc_cur <= 32'h2ffc;
    else
    if (stall_if)
        pc_cur <= pc_cur;
    else
        pc_cur <= pc_next;
end
endmodule
