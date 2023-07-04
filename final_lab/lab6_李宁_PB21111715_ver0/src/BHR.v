`timescale 1ns / 1ps
// 基于局部历史和 2bit 计数器的分支预测
module BHR(
    input clk,
    input [31:0] pc_if,
    input [31:0] pc_ex,
    input jump_ex,
    input flush_id,
    input flush_ex,
    input stall_if,
    input stall_id,
    output jump_local_if
);
reg [1:0] bht[0:511];
reg [1:0] pht[0:511][0:3];
reg [9:0] temp;
reg [4:0] temp1;
initial begin
    for (temp = 0; temp < 512; temp = temp + 1) begin
        bht[temp] = 2'b00;
        for (temp1 = 0; temp1 < 4; temp1 = temp1 + 1)
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
assign jump_local_if = (pht[index_if][bht[index_if]] == T || pht[index_if][bht[index_if]] == ST);

// 更新 BHT 和 PHT
// 考虑流水线停顿或冲刷时的冲突
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
        bht[index_ex] <= bht[index_ex] << 1 | jump_ex;
        if (jump_ex) begin
            case (pht[index_ex][bht[index_ex]])
                NT: pht[index_ex][bht[index_ex]] <= T;
                T: pht[index_ex][bht[index_ex]] <= ST;
                ST: pht[index_ex][bht[index_ex]] <= ST;
                SNT: pht[index_ex][bht[index_ex]] <= NT;
            endcase
        end
        else begin
            case (pht[index_ex][bht[index_ex]])
                NT: pht[index_ex][bht[index_ex]] <= SNT;
                T: pht[index_ex][bht[index_ex]] <= NT;
                ST: pht[index_ex][bht[index_ex]] <= T;
                SNT: pht[index_ex][bht[index_ex]] <= SNT;
            endcase
        end
    end
end
endmodule
