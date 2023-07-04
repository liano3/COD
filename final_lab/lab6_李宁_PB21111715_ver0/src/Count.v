`timescale 1ns / 1ps
// 输出分支预测效果
module Count(
    input clk,
    input rst,
    input [31:0] inst_ex,
    input jump_guess_ex,
    input jump_ex
);
reg [7:0] suc;
reg [7:0] fail;
always @(posedge clk) begin
    if (rst) begin
        suc <= 0;
        fail <= 0;
    end
    else if (inst_ex[6:0] == 7'b1100011 || inst_ex[6:0] == 7'b1101111 || inst_ex[6:0] == 7'b1100111) begin
        if (jump_guess_ex == jump_ex)
            suc <= suc + 1;
        else
            fail <= fail + 1;
    end
end
endmodule
