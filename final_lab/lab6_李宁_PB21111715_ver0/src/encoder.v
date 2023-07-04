`timescale 1ns / 1ps
// 编码器
module encoder(
    input jump_ex,
    input ebreak,
    input jump_guess_if,
    input jump_guess_ex,
    output reg [1:0] pc_sel
);
always @(*) begin
    if (~jump_guess_ex & jump_ex)
        pc_sel = 2'b01;
    else if (jump_guess_ex & ~jump_ex)
        pc_sel = 2'b10;
    else if (jump_guess_if)
        pc_sel = 2'b11;
    else
        pc_sel = 2'b00;
end
endmodule
