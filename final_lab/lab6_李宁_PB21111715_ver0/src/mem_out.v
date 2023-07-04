`timescale 1ns / 1ps
// 拼接从 mem 中读出的数据
module mem_out(
    input [7:0] byte0,
    input [7:0] byte1,
    input [7:0] byte2,
    input [7:0] byte3,
    input [3:0] re,
    input sign,
    output reg [31:0] data
);
always @(*) begin
    case (re)
        4'b1111: data = {byte3, byte2, byte1, byte0};   // lw
        4'b0011: data = {{16{sign ? byte1[7] : 1'b0}}, byte1, byte0};   // lh,lhu
        4'b1100: data = {{16{sign ? byte3[7] : 1'b0}}, byte3, byte2};
        4'b0001: data = {{24{sign ? byte0[7] : 1'b0}}, byte0};  // lb,lbu
        4'b0010: data = {{24{sign ? byte1[7] : 1'b0}}, byte1};
        4'b0100: data = {{24{sign ? byte2[7] : 1'b0}}, byte2};
        4'b1000: data = {{24{sign ? byte3[7] : 1'b0}}, byte3};
        default: data = 32'h0;
    endcase
end
endmodule
