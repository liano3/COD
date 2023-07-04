`timescale 1ns / 1ps
// 编码器
module encoder(
    input jal,
    input jalr,
    input br,
    input ebreak,
    output reg [1:0] pc_sel
);
always @(*) begin
    if (jalr)
        pc_sel = 2'b01;
    else if (br | ebreak)
        pc_sel = 2'b11;
    else if (jal)
        pc_sel = 2'b10;
    else
        pc_sel = 2'b00;
end
endmodule
