`timescale 1ns / 1ps
// 基于全局历史的分支预测器
module GHR(
    input clk,
    input [31:0] pc_if,
    input [31:0] pc_ex,
    input jump_ex,
    input flush_id,
    input flush_ex,
    input stall_if,
    input stall_id,
    output jump_global_if
);
reg [2:0] ghr;
reg [1:0] pht[0:511][0:7];
reg [9:0] temp;
reg [4:0] temp1;
initial begin
    ghr = 3'b0;
    for (temp = 0; temp < 512; temp = temp + 1) begin
        for (temp1 = 0; temp1 < 8; temp1 = temp1 + 1)
            pht[temp][temp1] = 2'b00;
    end
end
// 2bit 计数器状态
parameter NT = 2'b00;   // 不跳
parameter T = 2'b01;    // 跳
parameter ST = 2'b10;   // 肯定跳
parameter SNT = 2'b11;  // 肯定不跳

// 查询 PHT
wire [8:0] index_if;
assign index_if = pc_if[10:2];
assign jump_global_if = (pht[index_if][ghr] == T || pht[index_if][ghr] == ST);

// 更新 GHR 和 PHT
reg [2:0] count;
initial begin
    count = 3'b000;
end
always @(posedge clk) begin
    if (count)
        count <= count - 1;
    else if (flush_id & flush_ex)   // 分支预测失败，冲刷流水线，停两周期
        count <= 2;
    else if (flush_ex & stall_if & stall_id)    // load-use 冒险，停顿流水线，停一周期
        count <= 1;
end
wire [8:0] index_ex;
assign index_ex = pc_ex[10:2];
always @(posedge clk) begin
    if (!count) begin
        ghr <= (ghr << 1 | jump_ex);
        if (jump_ex) begin
            case (pht[index_ex][ghr])
                NT: pht[index_ex][ghr] <= T;
                T: pht[index_ex][ghr] <= ST;
                ST: pht[index_ex][ghr] <= ST;
                SNT: pht[index_ex][ghr] <= NT;
            endcase
        end
        else begin
            case (pht[index_ex][ghr])
                NT: pht[index_ex][ghr] <= SNT;
                T: pht[index_ex][ghr] <= NT;
                ST: pht[index_ex][ghr] <= T;
                SNT: pht[index_ex][ghr] <= SNT;
            endcase
        end
    end
end

endmodule
