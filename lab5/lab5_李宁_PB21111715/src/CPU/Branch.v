`timescale 1ns / 1ps
// 分支模块
module Branch(
    input [31:0] op1,
    input [31:0] op2,
    input [2:0] br_type,
    output reg br
);
always @(*) begin
    case (br_type)
        3'b000: br = (op1 == op2); // beq
        3'b001: br = (op1 != op2); // bne
        3'b100: br = (op1[31] == op2[31] ? op1 < op2 : op1[31]); // blt
        3'b101: br = (op1[31] == op2[31] ? op1 >= op2 : ~op1[31]); // bge
        3'b110: br = (op1 < op2); // bltu
        default: br = 0;
    endcase
end
endmodule
