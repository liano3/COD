`timescale 1ns / 1ps
// 寄存器堆模块
module RF(
    input clk,
    input we,
    input [4:0] wa,
    input [31:0] wd,
    input [4:0] ra0,
    input [4:0] ra1,
    output [31:0] rd0,
    output [31:0] rd1,

    input [4:0] ra_dbg,
    output [31:0] rd_dbg
);
reg [31:0] regfile [0:31];
// 初始化
integer i;
initial begin
    i = 0;
    while (i < 32) begin
        regfile[i] = 32'b0;
        i = i + 1;
    end
    regfile[2] = 32'h2ffc;
    regfile[3] = 32'h1800;
end
// 读写
assign rd0 = regfile[ra0];
assign rd1 = regfile[ra1];
assign rd_dbg = regfile[ra_dbg];
always @(posedge clk) begin
    if (we && wa)
        regfile[wa] <= wd;
end
endmodule
