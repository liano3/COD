`timescale 1ns / 1ps
// 控制器模块
module Control(
    input [31:0] inst,
    output jal, jalr,
    output [2:0] br_type,
    output reg wb_en,
    output reg [1:0] wb_sel,
    output reg mem_we,
    output reg alu_op1_sel, alu_op2_sel,
    output reg [3:0] alu_ctrl,
    output reg [2:0] imm_type
);
assign jal = (inst[6:0] == 7'b1101111);
assign jalr = (inst[6:0] == 7'b1100111);
assign br_type = (inst[6:0] == 7'b1100011) ? inst[14:12] : 3'b010; // 跳转类型、不跳转

always @(*) begin
    case (inst[6:0])
        7'b0010011: begin // addi
            wb_en = 1'b1;
            wb_sel = 2'b00;
            mem_we = 1'b0;
            alu_op1_sel = 1'b0;
            alu_op2_sel = 1'b1;
            alu_ctrl = (inst[14:12] == 3'b000 ? 4'b0000 : 4'b1111);
            imm_type = 3'b000;
        end
        7'b0110011: begin // add, and, or, sub, sll, srl, sra
            wb_en = 1'b1;
            wb_sel = 2'b00;
            mem_we = 1'b0;
            alu_op1_sel = 1'b0;
            alu_op2_sel = 1'b0;
            case (inst[14:12])
                3'b000: alu_ctrl = (inst[30] ? 4'b0001 : 4'b0000); // add, sub
                3'b110: alu_ctrl = 4'b0110; // or
                3'b111: alu_ctrl = 4'b0101; // and
                3'b001: alu_ctrl = 4'b1001; // sll
                3'b101: alu_ctrl = (inst[30] ? 4'b1010 : 4'b1000); // sra, srl
                default: alu_ctrl = 4'b1111;
            endcase
            imm_type = 3'b111;
        end
        7'b1100011: begin // beq, blt, bge, bne, bltu
            wb_en = 1'b0;
            wb_sel = 2'b00;
            mem_we = 1'b0;
            alu_op1_sel = 1'b1;
            alu_op2_sel = 1'b1;
            alu_ctrl = 4'b0000;
            imm_type = 3'b011;
        end
        7'b0110111: begin // lui
            wb_en = 1'b1;
            wb_sel = 2'b11;
            mem_we = 1'b0;
            alu_op1_sel = 1'b0;
            alu_op2_sel = 1'b0;
            alu_ctrl = 4'b1111;
            imm_type = 3'b001;
        end
        7'b0010111: begin // auipc
            wb_en = 1'b1;
            wb_sel = 2'b00;
            mem_we = 1'b0;
            alu_op1_sel = 1'b1;
            alu_op2_sel = 1'b1;
            alu_ctrl = 4'b0000;
            imm_type = 3'b001;
        end
        7'b1101111: begin // jal
            wb_en = 1'b1;
            wb_sel = 2'b01;
            mem_we = 1'b0;
            alu_op1_sel = 1'b1;
            alu_op2_sel = 1'b1;
            alu_ctrl = 4'b0000;
            imm_type = 3'b010;
        end
        7'b1100111: begin // jalr
            wb_en = 1'b1;
            wb_sel = 2'b01;
            mem_we = 1'b0;
            alu_op1_sel = 1'b0;
            alu_op2_sel = 1'b1;
            alu_ctrl = 4'b0000;
            imm_type = 3'b000;
        end
        7'b0000011: begin // lw
            wb_en = 1'b1;
            wb_sel = 2'b10;
            mem_we = 1'b0;
            alu_op1_sel = 1'b0;
            alu_op2_sel = 1'b1;
            alu_ctrl = 4'b0000;
            imm_type = 3'b000;
        end
        7'b0100011: begin // sw
            wb_en = 1'b0;
            wb_sel = 2'b00;
            mem_we = 1'b1;
            alu_op1_sel = 1'b0;
            alu_op2_sel = 1'b1;
            alu_ctrl = 4'b0000;
            imm_type = 3'b100;
        end
        default: begin
            wb_en = 1'b0;
            wb_sel = 2'b00;
            mem_we = 1'b0;
            alu_op1_sel = 1'b0;
            alu_op2_sel = 1'b0;
            alu_ctrl = 4'b1111;
            imm_type = 3'b111;
        end
    endcase
end

endmodule