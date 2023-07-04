`timescale 1ns / 1ps
// 给出分支目标地址
module BTB(
    input clk,
    input [31:0] pc_if,
    input [31:0] pc_ex,
    input [31:0] pc_add4_ex,
    input [31:0] pc_next,
    input [1:0] pc_sel_ex,
    
    input jal_ex,
    input jalr_ex,

    output reg [31:0] pc_target
);
reg [33:0] btb[0:511];  // 多了两位 tag，用于标识 br/jal/jalr
reg [9:0] temp;
initial begin
    for (temp = 0; temp < 512; temp = temp + 1)
        btb[temp] = 34'h0;
end
// 查询 BTB
wire [8:0] index_if;
assign index_if = pc_if[10:2];
// assign pc_target = btb[index_if][31:0];

// RAS, 用于 jalr 指令
reg [31:0] ras[0:511];
reg [9:0] ras_top;
initial begin
    ras_top = 10'b0;
    for (temp = 0; temp < 512; temp = temp + 1)
        ras[temp] = 32'h0;
end

// 查询 RAS
always @(*) begin
    if (btb[index_if][33:32] == 2'b10)
        pc_target = ras[ras_top - 1];
    else
        pc_target = btb[index_if][31:0];
end

// 更新 RAS
always @(posedge clk) begin
    if (jal_ex) begin
        ras[ras_top] <= pc_add4_ex;
        ras_top <= ras_top + 1;
    end
    else if (jalr_ex) begin
        ras_top <= ras_top - 1;
    end
end

// 更新 BTB
wire [8:0] index_ex;
assign index_ex = pc_ex[10:2];
always @(posedge clk) begin
    if (pc_sel_ex == 2'b01)
        btb[index_ex][31:0] <= pc_next;
    if (jal_ex)
        btb[index_ex][33:32] <= 2'b01;
    else if (jalr_ex)
        btb[index_ex][33:32] <= 2'b10;
    else
        btb[index_ex][33:32] <= 2'b00;
end
// 30a0 = 0011 0000 1010 0000 loop3 index = 40
// 30cc = 0011 0000 1100 1100 loop2 index = 51
// 30d4 = 0011 0000 1101 0100 loop1 index = 53
// 312c = 0011 0001 0010 1100 mul index = 75
// 3130 = 76

// jalr 指令需要栈


endmodule
