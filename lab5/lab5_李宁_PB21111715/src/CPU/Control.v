`timescale 1ns / 1ps
// 控制器模块
module Control(
    input [31:0] inst,
    output jal, 
    output jalr,
    output [2:0] br_type,
    output ebreak,
    output reg rf_we,
    output reg [1:0] rf_wd_sel,
    output reg mem_we,
    output reg alu_src1_sel, 
    output reg alu_src2_sel,
    output reg [3:0] alu_func,
    output reg [2:0] imm_type,
    output reg rf_re0,
    output reg rf_re1
);
assign jal = (inst[6:0] == 7'b1101111);
assign jalr = (inst[6:0] == 7'b1100111);
assign br_type = (inst[6:0] == 7'b1100011) ? inst[14:12] : 3'b010; // 跳转类型、不跳转
assign ebreak = (inst[6:0] == 7'b1110011) ? 1'b1 : 1'b0; // ebreak 指令

always @(*) begin
    case (inst[6:0])
        7'b0010011: begin // addi
            rf_we = inst[11:7] ? 1'b1 : 1'b0; // 不允许写入 x0
            rf_re0 = inst[19:15] ? 1'b1 : 1'b0; // 读 x0 时 rf_re0 为 0
            rf_re1 = 1'b0;
            rf_wd_sel = 2'b00;
            mem_we = 1'b0;
            alu_src1_sel = 1'b0;
            alu_src2_sel = 1'b1;
            alu_func = (inst[14:12] == 3'b000 ? 4'b0000 : 4'b1111);
            imm_type = 3'b000;
        end
        7'b0110011: begin // add, and, or, sub, sll, srl, sra
            rf_we = inst[11:7] ? 1'b1 : 1'b0;
            rf_re0 = inst[19:15] ? 1'b1 : 1'b0;
            rf_re1 = inst[24:20] ? 1'b1 : 1'b0;
            rf_wd_sel = 2'b00;
            mem_we = 1'b0;
            alu_src1_sel = 1'b0;
            alu_src2_sel = 1'b0;
            case (inst[14:12])
                3'b000: alu_func = (inst[30] ? 4'b0001 : 4'b0000); // add, sub
                3'b110: alu_func = 4'b0110; // or
                3'b111: alu_func = 4'b0101; // and
                3'b001: alu_func = 4'b1001; // sll
                3'b101: alu_func = (inst[30] ? 4'b1010 : 4'b1000); // sra, srl
                default: alu_func = 4'b1111;
            endcase
            imm_type = 3'b111;
        end
        7'b1100011: begin // beq, blt, bge, bne, bltu
            rf_we = 1'b0;
            rf_re0 = inst[19:15] ? 1'b1 : 1'b0;
            rf_re1 = inst[24:20] ? 1'b1 : 1'b0;
            rf_wd_sel = 2'b00;
            mem_we = 1'b0;
            alu_src1_sel = 1'b1;
            alu_src2_sel = 1'b1;
            alu_func = 4'b0000;
            imm_type = 3'b011;
        end
        7'b0110111: begin // lui
            rf_we = inst[11:7] ? 1'b1 : 1'b0;
            rf_re0 = 1'b0;
            rf_re1 = 1'b0;
            rf_wd_sel = 2'b11;
            mem_we = 1'b0;
            alu_src1_sel = 1'b0;
            alu_src2_sel = 1'b0;
            alu_func = 4'b1111;
            imm_type = 3'b001;
        end
        7'b0010111: begin // auipc
            rf_we = inst[11:7] ? 1'b1 : 1'b0;
            rf_re0 = 1'b0;
            rf_re1 = 1'b0;
            rf_wd_sel = 2'b00;
            mem_we = 1'b0;
            alu_src1_sel = 1'b1;
            alu_src2_sel = 1'b1;
            alu_func = 4'b0000;
            imm_type = 3'b001;
        end
        7'b1101111: begin // jal
            rf_we = inst[11:7] ? 1'b1 : 1'b0;
            rf_re0 = 1'b0;
            rf_re1 = 1'b0;
            rf_wd_sel = 2'b01;
            mem_we = 1'b0;
            alu_src1_sel = 1'b1;
            alu_src2_sel = 1'b1;
            alu_func = 4'b0000;
            imm_type = 3'b010;
        end
        7'b1100111: begin // jalr
            rf_we = inst[11:7] ? 1'b1 : 1'b0;
            rf_re0 = inst[19:15] ? 1'b1 : 1'b0;
            rf_re1 = 1'b0;
            rf_wd_sel = 2'b01;
            mem_we = 1'b0;
            alu_src1_sel = 1'b0;
            alu_src2_sel = 1'b1;
            alu_func = 4'b0000;
            imm_type = 3'b000;
        end
        7'b0000011: begin // lw
            rf_we = inst[11:7] ? 1'b1 : 1'b0;
            rf_re0 = inst[19:15] ? 1'b1 : 1'b0;
            rf_re1 = 1'b0;
            rf_wd_sel = 2'b10;
            mem_we = 1'b0;
            alu_src1_sel = 1'b0;
            alu_src2_sel = 1'b1;
            alu_func = 4'b0000;
            imm_type = 3'b000;
        end
        7'b0100011: begin // sw
            rf_we = 1'b0;
            rf_re0 = inst[19:15] ? 1'b1 : 1'b0;
            rf_re1 = inst[24:20] ? 1'b1 : 1'b0;
            rf_wd_sel = 2'b00;
            mem_we = 1'b1;
            alu_src1_sel = 1'b0;
            alu_src2_sel = 1'b1;
            alu_func = 4'b0000;
            imm_type = 3'b100;
        end
        7'b1110011: begin // ebreak
            rf_we = 1'b0;
            rf_re0 = 1'b0;
            rf_re1 = 1'b0;
            rf_wd_sel = 2'b00;
            mem_we = 1'b0;
            alu_src1_sel = 1'b1;
            alu_src2_sel = 1'b1;
            alu_func = 4'b0000;
            imm_type = 3'b110;
        end
        default: begin
            rf_we = 1'b0;
            rf_re0 = 1'b0;
            rf_re1 = 1'b0;
            rf_wd_sel = 2'b00;
            mem_we = 1'b0;
            alu_src1_sel = 1'b0;
            alu_src2_sel = 1'b0;
            alu_func = 4'b1111;
            imm_type = 3'b111;
        end
    endcase
end

endmodule