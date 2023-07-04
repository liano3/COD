`timescale 1ns / 1ps
// ALU模块
module alu #(parameter WIDTH = 32) //数据宽度
(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b, //两操作数（对于减运算，a是被减数）
    input [3:0] func, //操作功能（加、减、与、或、异或等）
    output reg [WIDTH-1:0] y, //运算结果（和、差 …）
    output reg of //溢出标志of，加减法结果溢出时置1
);
always @(*) begin
    case (func)
        4'h0: begin
            y = a + b; //加法
            of = (a[WIDTH-1] == b[WIDTH-1]) && (a[WIDTH-1] != y[WIDTH-1]); //溢出判断
        end
        4'h1: begin
            y = a - b; //减法
            of = (a[WIDTH-1] != b[WIDTH-1]) && (a[WIDTH-1] != y[WIDTH-1]); //溢出判断
        end
        4'h2: begin
            y = (a == b); // 等于
            of = 0;
        end
        4'h3: begin
            y = (a < b); // 无符号小于
            of = 0;
        end
        4'h4: begin
            y = (a[WIDTH-1] == b[WIDTH-1]) ? (a < b) : a[WIDTH-1]; // 有符号小于
            of = 0;
        end
        4'h5: begin
            y = a & b; // 与
            of = 0;
        end
        4'h6: begin
            y = a | b; // 或
            of = 0;
        end
        4'h7: begin
            y = a ^ b; // 异或
            of = 0;
        end
        4'h8: begin
            y = a >> b; // 右移
            of = 0;
        end
        4'h9: begin
            y = a << b; // 左移
            of = 0;
        end
        4'ha: begin
            y = $signed(a) >>> b; // 算术右移
            of = 0;
        end
        default: begin
            y = 0;
            of = 0;
        end
    endcase
end
endmodule
