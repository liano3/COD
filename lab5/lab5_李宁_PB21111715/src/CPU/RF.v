`timescale 1ns / 1ps
// 寄存器堆模块
module RF(
    input clk,
    input we,
    input [4:0] wa,
    input [31:0] wd,
    input [4:0] ra0,
    input [4:0] ra1,
    output reg [31:0] rd0,
    output reg [31:0] rd1,

    input [4:0] ra_dbg,
    output reg [31:0] rd_dbg
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
// assign rd0 = regfile[ra0];
// assign rd1 = regfile[ra1];
// assign rd_dbg = regfile[ra_dbg];
// 写优先
always @(*) begin
    rd0 = (we && ra0 && wa == ra0) ? wd : regfile[ra0];
    rd1 = (we && ra1 && wa == ra1) ? wd : regfile[ra1];
    rd_dbg = (we && ra_dbg && wa == ra_dbg) ? wd : regfile[ra_dbg];
end
always @(posedge clk) begin
    if (we && wa)
        regfile[wa] <= wd;
end
endmodule
