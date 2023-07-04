`timescale 1ns / 1ps
// 立即数生成模块
module IMM(
    input [31:0] inst,
    input [2:0] imm_type,
    output reg [31:0] imm
);
// 根据立即数类型生成立即数
always @(*) begin
    case (imm_type)
        3'b000: imm = { {20{inst[31]}}, inst[31:20] }; // addi, jalr, lw
        3'b001: imm = { inst[31:12], 12'b0 }; // lui, auipc
        3'b010: imm = { {11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0 }; // jal
        3'b011: imm = { {19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 }; // beq, blt
        3'b100: imm = { {20{inst[31]}}, inst[31:25], inst[11:7] }; // sw
        3'b110: imm = 32'h4; // ebreak
        default: imm = 32'b0;
    endcase
end
endmodule
