`timescale 1ns / 1ps
// 段间寄存器
module SEG_REG(
    // 控制
    input clk,
    input flush,
    input stall,
    input ebreak_in,
    // 输入
    input [31:0] pc_cur_in,
    input [31:0] inst_in,
    input [4:0] rf_ra0_in,
    input [4:0] rf_ra1_in,
    input rf_re0_in,
    input rf_re1_in,
    input [31:0] rf_rd0_raw_in,
    input [31:0] rf_rd1_raw_in,
    input [31:0] rf_rd0_in,
    input [31:0] rf_rd1_in,
    input [4:0] rf_wa_in,
    input [1:0] rf_wd_sel_in,
    input rf_we_in,
    input [2:0] imm_type_in,
    input [31:0] imm_in,
    input alu_src1_sel_in,
    input alu_src2_sel_in,
    input [31:0] alu_src1_in,
    input [31:0] alu_src2_in,
    input [3:0] alu_func_in,
    input [31:0] alu_ans_in,
    input [31:0] pc_add4_in,
    input [31:0] pc_br_in,
    input [31:0] pc_jal_in,
    input [31:0] pc_jalr_in,
    input jal_in,
    input jalr_in,
    input [2:0] br_type_in,
    input br_in,
    input [1:0] pc_sel_in,
    input [31:0] pc_next_in,
    input [31:0] dm_addr_in,
    input [31:0] dm_din_in,
    input [31:0] dm_dout_in,
    input dm_we_in,

    input jump_local_in,
    input jump_global_in,
    input jump_guess_in,
    // 输出
    output reg ebreak_out,
    output reg [31:0] pc_cur_out,
    output reg [31:0] inst_out,
    output reg [4:0] rf_ra0_out,
    output reg [4:0] rf_ra1_out,
    output reg rf_re0_out,
    output reg rf_re1_out,
    output reg [31:0] rf_rd0_raw_out,
    output reg [31:0] rf_rd1_raw_out,
    output reg [31:0] rf_rd0_out,
    output reg [31:0] rf_rd1_out,
    output reg [4:0] rf_wa_out,
    output reg [1:0] rf_wd_sel_out,
    output reg rf_we_out,
    output reg [2:0] imm_type_out,
    output reg [31:0] imm_out,
    output reg alu_src1_sel_out,
    output reg alu_src2_sel_out,
    output reg [31:0] alu_src1_out,
    output reg [31:0] alu_src2_out,
    output reg [3:0] alu_func_out,
    output reg [31:0] alu_ans_out,
    output reg [31:0] pc_add4_out,
    output reg [31:0] pc_br_out,
    output reg [31:0] pc_jal_out,
    output reg [31:0] pc_jalr_out,
    output reg jal_out,
    output reg jalr_out,
    output reg [2:0] br_type_out,
    output reg br_out,
    output reg [1:0] pc_sel_out,
    output reg [31:0] pc_next_out,
    output reg [31:0] dm_addr_out,
    output reg [31:0] dm_din_out,
    output reg [31:0] dm_dout_out,
    output reg dm_we_out,

    output reg jump_local_out,
    output reg jump_global_out,
    output reg jump_guess_out
);
initial begin
    pc_cur_out = 0;
    inst_out = 0;
    rf_ra0_out = 0;
    rf_ra1_out = 0;
    rf_re0_out = 0;
    rf_re1_out = 0;
    rf_rd0_raw_out = 0;
    rf_rd1_raw_out = 0;
    rf_rd0_out = 0;
    rf_rd1_out = 0;
    rf_wa_out = 0;
    rf_wd_sel_out = 0;
    rf_we_out = 0;
    imm_type_out = 0;
    imm_out = 0;
    alu_src1_sel_out = 0;
    alu_src2_sel_out = 0;
    alu_src1_out = 0;
    alu_src2_out = 0;
    alu_func_out = 0;
    alu_ans_out = 0;
    pc_add4_out = 0;
    pc_br_out = 0;
    pc_jal_out = 0;
    pc_jalr_out = 0;
    jal_out = 0;
    jalr_out = 0;
    br_type_out = 3'b010;
    br_out = 0;
    pc_sel_out = 0;
    pc_next_out = 0;
    dm_addr_out = 0;
    dm_din_out = 0;
    dm_dout_out = 0;
    dm_we_out = 0;
    ebreak_out = 0;
    jump_local_out = 0;
    jump_global_out = 0;
    jump_guess_out = 0;
end
always @(posedge clk) begin
    if (flush) begin
        // 清空
        pc_cur_out <= 0;
        inst_out <= 0;
        rf_ra0_out <= 0;
        rf_ra1_out <= 0;
        rf_re0_out <= 0;
        rf_re1_out <= 0;
        rf_rd0_raw_out <= 0;
        rf_rd1_raw_out <= 0;
        rf_rd0_out <= 0;
        rf_rd1_out <= 0;
        rf_wa_out <= 0;
        rf_wd_sel_out <= 0;
        rf_we_out <= 0;
        imm_type_out <= 0;
        imm_out <= 0;
        alu_src1_sel_out <= 0;
        alu_src2_sel_out <= 0;
        alu_src1_out <= 0;
        alu_src2_out <= 0;
        alu_func_out <= 0;
        alu_ans_out <= 0;
        pc_add4_out <= 0;
        pc_br_out <= 0;
        pc_jal_out <= 0;
        pc_jalr_out <= 0;
        jal_out <= 0;
        jalr_out <= 0;
        br_type_out <= 3'b010;  // 我的不跳转编码是 010，找了半天 bug 原来在这。。。
        br_out <= 0;
        pc_sel_out <= 0;
        pc_next_out <= 0;
        dm_addr_out <= 0;
        dm_din_out <= 0;
        dm_dout_out <= 0;
        dm_we_out <= 0;
        ebreak_out <= 0;
        jump_local_out <= 0;
        jump_global_out <= 0;
        jump_guess_out <= 0;
    end
    else if (!stall) begin
        // 传递
        pc_cur_out <= pc_cur_in;
        inst_out <= inst_in;
        rf_ra0_out <= rf_ra0_in;
        rf_ra1_out <= rf_ra1_in;
        rf_re0_out <= rf_re0_in;
        rf_re1_out <= rf_re1_in;
        rf_rd0_raw_out <= rf_rd0_raw_in;
        rf_rd1_raw_out <= rf_rd1_raw_in;
        rf_rd0_out <= rf_rd0_in;
        rf_rd1_out <= rf_rd1_in;
        rf_wa_out <= rf_wa_in;
        rf_wd_sel_out <= rf_wd_sel_in;
        rf_we_out <= rf_we_in;
        imm_type_out <= imm_type_in;
        imm_out <= imm_in;
        alu_src1_sel_out <= alu_src1_sel_in;
        alu_src2_sel_out <= alu_src2_sel_in;
        alu_src1_out <= alu_src1_in;
        alu_src2_out <= alu_src2_in;
        alu_func_out <= alu_func_in;
        alu_ans_out <= alu_ans_in;
        pc_add4_out <= pc_add4_in;
        pc_br_out <= pc_br_in;
        pc_jal_out <= pc_jal_in;
        pc_jalr_out <= pc_jalr_in;
        jal_out <= jal_in;
        jalr_out <= jalr_in;
        br_type_out <= br_type_in;
        br_out <= br_in;
        pc_sel_out <= pc_sel_in;
        pc_next_out <= pc_next_in;
        dm_addr_out <= dm_addr_in;
        dm_din_out <= dm_din_in;
        dm_dout_out <= dm_dout_in;
        dm_we_out <= dm_we_in;
        ebreak_out <= ebreak_in;
        jump_local_out <= jump_local_in;
        jump_global_out <= jump_global_in;
        jump_guess_out <= jump_guess_in;
    end
    else begin
        // 停顿
    end
end
endmodule
