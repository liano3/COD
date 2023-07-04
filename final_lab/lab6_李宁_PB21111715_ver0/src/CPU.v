`timescale 1ns / 1ps

/* 
 *   Author: YOU
 *   Last update: 2023.04.20
 */

module CPU(
    input clk, 
    input rst,

    // MEM And MMIO Data BUS
    output [31:0] im_addr,      // Instruction address (The same as current PC)
    input [31:0] im_dout,       // Instruction data (Current instruction)
    output [31:0] mem_addr,     // Memory read/write address
    output [3:0] mem_re,        // Memory reading enable
    output [3:0] mem_we,              // Memory writing enable		            
    output [31:0] mem_din,      // Data ready to write to memory
    input [31:0] mem_dout,	    // Data read from memory

    // Debug BUS with PDU
    output [31:0] current_pc, 	        // Current_pc, pc_out
    output [31:0] next_pc,              // Next_pc, pc_in    
    input [31:0] cpu_check_addr,	    // Check current datapath state (code)
    output [31:0] cpu_check_data,    // Current datapath state data

    output ebreak,             // ebreak signal
    output sign
);
    
    
// Write your CPU here!
// You might need to write these modules:
//      ALU、RF、Control、Add(Or just add-mode ALU)、And(Or just and-mode ALU)、PCReg、Imm、Branch、Mux�????...
wire [31:0] pc_cur_if;
wire [31:0] pc_next;
assign current_pc = pc_cur_if;
assign next_pc = pc_next;
wire [31:0] inst_raw;
assign inst_raw = im_dout;
wire [31:0] dm_dout;
assign dm_dout = mem_dout;
assign im_addr = pc_cur_if;
wire [31:0] alu_ans_mem;
assign mem_addr = alu_ans_mem;
wire [31:0] dm_din_mem;
assign mem_din = dm_din_mem;
wire dm_we_mem;
// assign mem_we = dm_we_mem;

// IF，取指令
// pc
wire stall_if;
PC pc(
    .clk(clk),
    .rst(rst),
    .stall_if(stall_if),
    .pc_next(pc_next),
    .pc_cur(pc_cur_if)
);
// 气泡
wire flush_if;
wire [31:0] inst_if;
Mux2 #(.WIDTH(32)) inst_flush(
    .mux_sr1(inst_raw),
    .mux_sr2(32'h00000033),
    .mux_ctrl(flush_if),
    .mux_out(inst_if)
);
// pc自增
wire [31:0] pc_add4_if;
ADD pc_add(
    .a(pc_cur_if),
    .b(32'h4),
    .sum(pc_add4_if)
);
// pc mux
wire [31:0] pc_jalr_ex;
wire [31:0] alu_ans_ex;
wire [1:0] pc_sel_ex;
wire [31:0] pc_jal_id;
wire [31:0] pc_target;
wire [31:0] pc_add4_ex;
Mux4 #(.WIDTH(32)) pc_mux(
    .mux_sr1(pc_add4_if),   // 预测不跳转
    .mux_sr2(alu_ans_ex),   // 预测不跳转，但是实际跳转
    .mux_sr3(pc_add4_ex),   // 预测跳转，但是实际不跳转
    .mux_sr4(pc_target),    // 预测跳转
    .mux_ctrl(pc_sel_ex),
    .mux_out(pc_next)
);

// 分支预测
wire br_ex;
wire jal_ex;
wire jalr_ex;
wire jump_ex;
assign jump_ex = br_ex | jal_ex | jalr_ex;
// jalr 需要栈，暂时不做
// assign jump_ex = br_ex | jal_ex;
wire [31:0] pc_cur_ex;
wire flush_id;
wire stall_id;
wire flush_ex;

wire jump_local_if;
wire jump_global_if;
BHR bhr(
    .clk(clk),
    .pc_if(pc_cur_if),
    .pc_ex(pc_cur_ex),
    .jump_ex(jump_ex),
    .flush_id(flush_id),
    .flush_ex(flush_ex),
    .stall_if(stall_if),
    .stall_id(stall_id),
    .jump_local_if(jump_local_if)
);

GHR ghr(
    .clk(clk),
    .pc_if(pc_cur_if),
    .pc_ex(pc_cur_ex),
    .jump_ex(jump_ex),
    .flush_id(flush_id),
    .flush_ex(flush_ex),
    .stall_if(stall_if),
    .stall_id(stall_id),
    .jump_global_if(jump_global_if)
);

wire jump_local_ex;
wire jump_global_ex;
wire jump_guess_if;
CPHT cpht(
    .clk(clk),
    .jump_local_if(jump_local_if),
    .jump_global_if(jump_global_if),
    .jump_local_ex(jump_local_ex),
    .jump_global_ex(jump_global_ex),
    .jump_ex(jump_ex),
    .jump_guess_if(jump_guess_if)
);

wire [31:0] inst_ex;
wire jump_guess_ex;
Count count(
    .clk(clk),
    .rst(rst),
    .inst_ex(inst_ex),
    .jump_guess_ex(jump_guess_ex),
    .jump_ex(jump_ex)
);

// IF/ID
wire [31:0] pc_cur_id;
wire [31:0] inst_id;
wire [4:0] rf_ra0_id;
wire [4:0] rf_ra1_id;
wire [4:0] rf_wa_id;
wire [31:0] pc_add4_id;
wire jump_local_id;
wire jump_global_id;
wire jump_guess_id;
SEG_REG IF_ID(
    .clk(clk),
    .flush(flush_id),
    .stall(stall_id),
    .ebreak_in(1'h0),
    .pc_cur_in(pc_cur_if),
    .inst_in(inst_if),
    .rf_ra0_in(inst_if[19:15]),
    .rf_ra1_in(inst_if[24:20]),
    .rf_re0_in(1'h0),
    .rf_re1_in(1'h0),
    .rf_rd0_raw_in(32'h0),
    .rf_rd1_raw_in(32'h0),
    .rf_rd0_in(32'h0),
    .rf_rd1_in(32'h0),
    .rf_wa_in(inst_if[11:7]),
    .rf_wd_sel_in(2'h0),
    .rf_we_in(1'h0),
    .imm_type_in(3'h0),
    .imm_in(32'h0),
    .alu_src1_sel_in(1'h0),
    .alu_src2_sel_in(1'h0),
    .alu_src1_in(32'h0),
    .alu_src2_in(32'h0),
    .alu_func_in(4'h0),
    .alu_ans_in(32'h0),
    .pc_add4_in(pc_add4_if),
    .pc_br_in(32'h0),
    .pc_jal_in(32'h0),
    .pc_jalr_in(32'h0),
    .jal_in(1'h0),
    .jalr_in(1'h0),
    .br_type_in(3'h0),
    .br_in(1'h0),
    .pc_sel_in(2'h0),
    .pc_next_in(32'h0),
    .dm_addr_in(32'h0),
    .dm_din_in(32'h0),
    .dm_dout_in(32'h0),
    .dm_we_in(1'h0),
    .jump_local_in(jump_local_if),
    .jump_global_in(jump_global_if),
    .jump_guess_in(jump_guess_if),

    .pc_cur_out(pc_cur_id),
    .inst_out(inst_id),
    .rf_ra0_out(rf_ra0_id),
    .rf_ra1_out(rf_ra1_id),
    .rf_wa_out(rf_wa_id),
    .pc_add4_out(pc_add4_id),
    .jump_local_out(jump_local_id),
    .jump_global_out(jump_global_id),
    .jump_guess_out(jump_guess_id)
);


// ID，译�?
// rf
wire rf_we_wb;
wire [31:0] rf_wd_wb;
wire [4:0] rf_wa_wb;
wire [31:0] rf_rd0_raw_id;
wire [31:0] rf_rd1_raw_id;
wire [31:0] rf_rd_dbg_id;
RF rf(
    .clk(clk),
    .we(rf_we_wb),
    .wd(rf_wd_wb),
    .wa(rf_wa_wb),
    .ra0(rf_ra0_id),
    .ra1(rf_ra1_id),
    .rd0(rf_rd0_raw_id),
    .rd1(rf_rd1_raw_id),
    .ra_dbg(cpu_check_addr[4:0]),
    .rd_dbg(rf_rd_dbg_id)
);
// imm
wire [2:0] imm_type_id;
wire [31:0] imm_id;
IMM Immediate(
    .inst(inst_id),
    .imm_type(imm_type_id),
    .imm(imm_id)
);
// ctrl
wire rf_re0_id;
wire rf_re1_id;
wire [1:0] rf_wd_sel_id;
wire rf_we_id;
wire alu_src1_sel_id;
wire alu_src2_sel_id;
wire [3:0] alu_func_id;
wire jal_id;
wire jalr_id;
wire [2:0] br_type_id;
wire mem_we_id;
wire ebreak_id;
Control ctrl(
    .inst(inst_id),
    .rf_re0(rf_re0_id),
    .rf_re1(rf_re1_id),
    .rf_wd_sel(rf_wd_sel_id),
    .rf_we(rf_we_id),
    .imm_type(imm_type_id),
    .alu_src1_sel(alu_src1_sel_id),
    .alu_src2_sel(alu_src2_sel_id),
    .alu_func(alu_func_id),
    .jal(jal_id),
    .jalr(jalr_id),
    .br_type(br_type_id),
    .ebreak(ebreak_id),
    .mem_we(mem_we_id)
);
// // 加一个ADD处理jal指令
// ADD jal_add(
//     .a(pc_cur_id),
//     .b(imm_id),
//     .sum(pc_jal_id)
// );
// ID/EX
wire stall_ex;
wire [4:0] rf_ra0_ex;
wire [4:0] rf_ra1_ex;
wire rf_re0_ex;
wire rf_re1_ex;
wire [31:0] rf_rd0_raw_ex;
wire [31:0] rf_rd1_raw_ex;
wire [4:0] rf_wa_ex;
wire [1:0] rf_wd_sel_ex;
wire rf_we_ex;
wire [2:0] imm_type_ex;
wire [31:0] imm_ex;
wire alu_src1_sel_ex;
wire alu_src2_sel_ex;
wire [3:0] alu_func_ex;

wire [2:0] br_type_ex;
wire dm_we_ex;
wire ebreak_ex;
SEG_REG ID_EX(
    .clk(clk),
    .flush(flush_ex),
    .stall(stall_ex),
    .ebreak_in(ebreak_id),
    .pc_cur_in(pc_cur_id),
    .inst_in(inst_id),
    .rf_ra0_in(rf_ra0_id),
    .rf_ra1_in(rf_ra1_id),
    .rf_re0_in(rf_re0_id),
    .rf_re1_in(rf_re1_id),
    .rf_rd0_raw_in(rf_rd0_raw_id),
    .rf_rd1_raw_in(rf_rd1_raw_id),
    .rf_rd0_in(32'h0),
    .rf_rd1_in(32'h0),
    .rf_wa_in(rf_wa_id),
    .rf_wd_sel_in(rf_wd_sel_id),
    .rf_we_in(rf_we_id),
    .imm_type_in(imm_type_id),
    .imm_in(imm_id),
    .alu_src1_sel_in(alu_src1_sel_id),
    .alu_src2_sel_in(alu_src2_sel_id),
    .alu_src1_in(32'h0),
    .alu_src2_in(32'h0),
    .alu_func_in(alu_func_id),
    .alu_ans_in(32'h0),
    .pc_add4_in(pc_add4_id),
    .pc_br_in(32'h0),
    .pc_jal_in(32'h0),
    .pc_jalr_in(32'h0),
    .jal_in(jal_id),
    .jalr_in(jalr_id),
    .br_type_in(br_type_id),
    .br_in(1'h0),
    .pc_sel_in(2'h0),
    .pc_next_in(32'h0),
    .dm_addr_in(32'h0),
    .dm_din_in(32'h0), // diff
    .dm_dout_in(32'h0),
    .dm_we_in(mem_we_id),
    .jump_local_in(jump_local_id),
    .jump_global_in(jump_global_id),
    .jump_guess_in(jump_guess_id),

    .ebreak_out(ebreak_ex),
    .pc_cur_out(pc_cur_ex),
    .inst_out(inst_ex),
    .rf_ra0_out(rf_ra0_ex),
    .rf_ra1_out(rf_ra1_ex),
    .rf_re0_out(rf_re0_ex),
    .rf_re1_out(rf_re1_ex),
    .rf_rd0_raw_out(rf_rd0_raw_ex),
    .rf_rd1_raw_out(rf_rd1_raw_ex),
    .rf_wa_out(rf_wa_ex),
    .rf_wd_sel_out(rf_wd_sel_ex),
    .rf_we_out(rf_we_ex),
    .imm_type_out(imm_type_ex),
    .imm_out(imm_ex),
    .alu_src1_sel_out(alu_src1_sel_ex),
    .alu_src2_sel_out(alu_src2_sel_ex),
    .alu_func_out(alu_func_ex),
    .pc_add4_out(pc_add4_ex),
    .jal_out(jal_ex),
    .jalr_out(jalr_ex),
    .br_type_out(br_type_ex),
    .dm_we_out(dm_we_ex),
    .jump_local_out(jump_local_ex),
    .jump_global_out(jump_global_ex),
    .jump_guess_out(jump_guess_ex)
);


// EX, 计算
AND jalr_and(
    .a(32'hfffffffe),
    .b(alu_ans_ex),
    .out(pc_jalr_ex)
);
wire [31:0] alu_src1_ex;
wire [31:0] rf_rd0_ex;
Mux2 #(.WIDTH(32)) alu_sel1(
    .mux_sr1(rf_rd0_ex),
    .mux_sr2(pc_cur_ex),
    .mux_ctrl(alu_src1_sel_ex),
    .mux_out(alu_src1_ex)
);
wire [31:0] alu_src2_ex;
wire [31:0] rf_rd1_ex;
Mux2 #(.WIDTH(32)) alu_sel2(
    .mux_sr1(rf_rd1_ex),
    .mux_sr2(imm_ex),
    .mux_ctrl(alu_src2_sel_ex),
    .mux_out(alu_src2_ex)
);
// alu
alu #(.WIDTH(32)) alu0(
    .a(alu_src1_ex),
    .b(alu_src2_ex),
    .func(alu_func_ex),
    .y(alu_ans_ex)
);
// branch
Branch branch(
    .op1(rf_rd0_ex),
    .op2(rf_rd1_ex),
    .br_type(br_type_ex),
    .br(br_ex)
);
encoder pc_sel_gen(
    .jump_ex(jump_ex),
    .ebreak(ebreak_ex),
    .jump_guess_if(jump_guess_if),
    .jump_guess_ex(jump_guess_ex),
    .pc_sel(pc_sel_ex)
);
wire [31:0] rf_rd0_fd;
wire rf_rd0_fe;
Mux2 rf_rd0_fwd(
    .mux_sr1(rf_rd0_raw_ex),
    .mux_sr2(rf_rd0_fd),
    .mux_ctrl(rf_rd0_fe),
    .mux_out(rf_rd0_ex)
);
wire [31:0] rf_rd1_fd;
wire rf_rd1_fe;
Mux2 rf_rd1_fwd(
    .mux_sr1(rf_rd1_raw_ex),
    .mux_sr2(rf_rd1_fd),
    .mux_ctrl(rf_rd1_fe),
    .mux_out(rf_rd1_ex)
);

BTB btb(
    .clk(clk),
    .pc_if(pc_cur_if),
    .pc_ex(pc_cur_ex),
    .pc_add4_ex(pc_add4_ex),
    .pc_next(pc_next),
    .pc_sel_ex(pc_sel_ex),
    .jal_ex(jal_ex),
    .jalr_ex(jalr_ex),
    .pc_target(pc_target)
);

// EX/MEM
wire flush_mem;
wire [31:0] pc_cur_mem;
wire [31:0] inst_mem;
wire [4:0] rf_ra0_mem;
wire [4:0] rf_ra1_mem;
wire rf_re0_mem;
wire rf_re1_mem;
wire [31:0] rf_rd0_raw_mem;
wire [31:0] rf_rd1_raw_mem;
wire [31:0] rf_rd0_mem;
wire [31:0] rf_rd1_mem;
wire [4:0] rf_wa_mem;
wire [1:0] rf_wd_sel_mem;
wire rf_we_mem;
wire [2:0] imm_type_mem;
wire [31:0] imm_mem;
wire alu_src1_sel_mem;
wire alu_src2_sel_mem;
wire [31:0] alu_src1_mem;
wire [31:0] alu_src2_mem;
wire [3:0] alu_func_mem;
// wire [31:0] alu_ans_mem;
wire [31:0] pc_add4_mem;
wire [31:0] pc_br_mem;
wire [31:0] pc_jal_mem;
wire [31:0] pc_jalr_mem;
wire jal_mem;
wire jalr_mem;
wire [2:0] br_type_mem;
wire br_mem;
wire [1:0] pc_sel_mem;
wire [31:0] pc_next_mem;
wire [31:0] dm_addr_mem;
// wire [31:0] dm_din_mem;
// wire dm_we_mem; 
wire ebreak_mem;
assign ebreak = ebreak_mem;
SEG_REG EX_MEM(
    .clk(clk),
    .flush(flush_mem),
    .stall(1'h0),
    .ebreak_in(ebreak_ex),
    .pc_cur_in(pc_cur_ex),
    .inst_in(inst_ex),
    .rf_ra0_in(rf_ra0_ex),
    .rf_ra1_in(rf_ra1_ex),
    .rf_re0_in(rf_re0_ex),
    .rf_re1_in(rf_re1_ex),
    .rf_rd0_raw_in(rf_rd0_raw_ex),
    .rf_rd1_raw_in(rf_rd1_raw_ex),
    .rf_rd0_in(rf_rd0_ex),
    .rf_rd1_in(rf_rd1_ex),
    .rf_wa_in(rf_wa_ex),
    .rf_wd_sel_in(rf_wd_sel_ex),
    .rf_we_in(rf_we_ex),
    .imm_type_in(imm_type_ex),
    .imm_in(imm_ex),
    .alu_src1_sel_in(alu_src1_sel_ex),
    .alu_src2_sel_in(alu_src2_sel_ex),
    .alu_src1_in(alu_src1_ex),
    .alu_src2_in(alu_src2_ex),
    .alu_func_in(alu_func_ex),
    .alu_ans_in(alu_ans_ex),
    .pc_add4_in(pc_add4_ex),
    .pc_br_in(alu_ans_ex),
    .pc_jal_in(alu_ans_ex),
    .pc_jalr_in(pc_jalr_ex),
    .jal_in(jal_ex),
    .jalr_in(jalr_ex),
    .br_type_in(br_type_ex),
    .br_in(br_ex),
    .pc_sel_in(pc_sel_ex),
    .pc_next_in(pc_next),
    .dm_addr_in(alu_ans_ex),
    .dm_din_in(rf_rd1_ex),
    .dm_dout_in(32'h0),
    .dm_we_in(dm_we_ex),
    .jump_local_in(1'h0),
    .jump_global_in(1'h0),
    .jump_guess_in(1'h0),

    .ebreak_out(ebreak_mem),
    .pc_cur_out(pc_cur_mem),
    .inst_out(inst_mem),
    .rf_ra0_out(rf_ra0_mem),
    .rf_ra1_out(rf_ra1_mem),
    .rf_re0_out(rf_re0_mem),
    .rf_re1_out(rf_re1_mem),
    .rf_rd0_raw_out(rf_rd0_raw_mem),
    .rf_rd1_raw_out(rf_rd1_raw_mem),
    .rf_rd0_out(rf_rd0_mem),
    .rf_rd1_out(rf_rd1_mem),
    .rf_wa_out(rf_wa_mem),
    .rf_wd_sel_out(rf_wd_sel_mem),
    .rf_we_out(rf_we_mem),
    .imm_type_out(imm_type_mem),
    .imm_out(imm_mem),
    .alu_src1_sel_out(alu_src1_sel_mem),
    .alu_src2_sel_out(alu_src2_sel_mem),
    .alu_src1_out(alu_src1_mem),
    .alu_src2_out(alu_src2_mem),
    .alu_func_out(alu_func_mem),
    .alu_ans_out(alu_ans_mem),
    .pc_add4_out(pc_add4_mem),
    .pc_br_out(pc_br_mem),
    .pc_jal_out(pc_jal_mem),
    .pc_jalr_out(pc_jalr_mem),
    .jal_out(jal_mem),
    .jalr_out(jalr_mem),
    .br_type_out(br_type_mem),
    .br_out(br_mem),
    .pc_sel_out(pc_sel_mem),
    .pc_next_out(pc_next_mem),
    .dm_addr_out(dm_addr_mem),
    .dm_din_out(dm_din_mem),
    .dm_we_out(dm_we_mem)
);

// 生成 mem 段的控制信号
mem_ctrl mem_ctrl0 (
    .inst_mem(inst_mem),
    .dm_addr_mem(dm_addr_mem),
    .mem_re(mem_re),
    .mem_we(mem_we),
    .sign(sign)
);

// MEM, 读写内存
// MEM/WB
wire [31:0] pc_cur_wb;
wire [31:0] inst_wb;
wire [4:0] rf_ra0_wb;
wire [4:0] rf_ra1_wb;
wire rf_re0_wb;
wire rf_re1_wb;
wire [31:0] rf_rd0_raw_wb;
wire [31:0] rf_rd1_raw_wb;
wire [31:0] rf_rd0_wb;
wire [31:0] rf_rd1_wb;
// wire [4:0] rf_wa_wb;
wire [1:0] rf_wd_sel_wb;
// wire rf_we_wb;
wire [2:0] imm_type_wb;
wire [31:0] imm_wb;
wire alu_src1_sel_wb;
wire alu_src2_sel_wb;
wire [31:0] alu_src1_wb;
wire [31:0] alu_src2_wb;
wire [3:0] alu_func_wb;
wire [31:0] alu_ans_wb;
wire [31:0] pc_add4_wb;
wire [31:0] pc_br_wb;
wire [31:0] pc_jal_wb;
wire [31:0] pc_jalr_wb;
wire jal_wb;
wire jalr_wb;
wire [2:0] br_type_wb;
wire br_wb;
wire [1:0] pc_sel_wb;
wire [31:0] pc_next_wb;
wire [31:0] dm_addr_wb;
wire [31:0] dm_din_wb;
wire [31:0] dm_dout_wb;
wire dm_we_wb;
SEG_REG MEM_WB(
    .clk(clk),
    .flush(1'h0),
    .stall(1'h0),
    .ebreak_in(ebreak_mem),
    .pc_cur_in(pc_cur_mem),
    .inst_in(inst_mem),
    .rf_ra0_in(rf_ra0_mem),
    .rf_ra1_in(rf_ra1_mem),
    .rf_re0_in(rf_re0_mem),
    .rf_re1_in(rf_re1_mem),
    .rf_rd0_raw_in(rf_rd0_raw_mem),
    .rf_rd1_raw_in(rf_rd1_raw_mem),
    .rf_rd0_in(rf_rd0_mem),
    .rf_rd1_in(rf_rd1_mem),
    .rf_wa_in(rf_wa_mem),
    .rf_wd_sel_in(rf_wd_sel_mem),
    .rf_we_in(rf_we_mem),
    .imm_type_in(imm_type_mem),
    .imm_in(imm_mem),
    .alu_src1_sel_in(alu_src1_sel_mem),
    .alu_src2_sel_in(alu_src2_sel_mem),
    .alu_src1_in(alu_src1_mem),
    .alu_src2_in(alu_src2_mem),
    .alu_func_in(alu_func_mem),
    .alu_ans_in(alu_ans_mem),
    .pc_add4_in(pc_add4_mem),
    .pc_br_in(pc_br_mem),
    .pc_jal_in(pc_jal_mem),
    .pc_jalr_in(pc_jalr_mem),
    .jal_in(jal_mem),
    .jalr_in(jalr_mem),
    .br_type_in(br_type_mem),
    .br_in(br_mem),
    .pc_sel_in(pc_sel_mem),
    .pc_next_in(pc_next_mem),
    .dm_addr_in(dm_addr_mem),
    .dm_din_in(dm_din_mem),
    .dm_dout_in(dm_dout),
    .dm_we_in(dm_we_mem),
    .jump_local_in(1'h0),
    .jump_global_in(1'h0),
    .jump_guess_in(1'h0),

    .pc_cur_out(pc_cur_wb),
    .inst_out(inst_wb),
    .rf_ra0_out(rf_ra0_wb),
    .rf_ra1_out(rf_ra1_wb),
    .rf_re0_out(rf_re0_wb),
    .rf_re1_out(rf_re1_wb),
    .rf_rd0_raw_out(rf_rd0_raw_wb),
    .rf_rd1_raw_out(rf_rd1_raw_wb),
    .rf_rd0_out(rf_rd0_wb),
    .rf_rd1_out(rf_rd1_wb),
    .rf_wa_out(rf_wa_wb),
    .rf_wd_sel_out(rf_wd_sel_wb),
    .rf_we_out(rf_we_wb),
    .imm_type_out(imm_type_wb),
    .imm_out(imm_wb),
    .alu_src1_sel_out(alu_src1_sel_wb),
    .alu_src2_sel_out(alu_src2_sel_wb),
    .alu_src1_out(alu_src1_wb),
    .alu_src2_out(alu_src2_wb),
    .alu_func_out(alu_func_wb),
    .alu_ans_out(alu_ans_wb),
    .pc_add4_out(pc_add4_wb),
    .pc_br_out(pc_br_wb),
    .pc_jal_out(pc_jal_wb),
    .pc_jalr_out(pc_jalr_wb),
    .jal_out(jal_wb),
    .jalr_out(jalr_wb),
    .br_type_out(br_type_wb),
    .br_out(br_wb),
    .pc_sel_out(pc_sel_wb),
    .pc_next_out(pc_next_wb),
    .dm_addr_out(dm_addr_wb),
    .dm_din_out(dm_din_wb),
    .dm_dout_out(dm_dout_wb),
    .dm_we_out(dm_we_wb)
);

// WB
Mux4 #(.WIDTH(32)) rf_wb_mux(
    .mux_sr1(alu_ans_wb),
    .mux_sr2(pc_add4_wb),
    .mux_sr3(dm_dout_wb),
    .mux_sr4(imm_wb),
    .mux_ctrl(rf_wd_sel_wb),
    .mux_out(rf_wd_wb)
);

// 冒险处理
Hazard hazard(
    .ebreak_ex(ebreak_ex),
    .rf_ra0_ex(rf_ra0_ex),
    .rf_ra1_ex(rf_ra1_ex),
    .rf_re0_ex(rf_re0_ex),
    .rf_re1_ex(rf_re1_ex),
    .rf_wa_mem(rf_wa_mem),
    .rf_we_mem(rf_we_mem),
    .rf_wd_sel_mem(rf_wd_sel_mem),
    .alu_ans_mem(alu_ans_mem),
    .pc_add4_mem(pc_add4_mem),
    .imm_mem(imm_mem),
    .rf_wa_wb(rf_wa_wb),
    .rf_we_wb(rf_we_wb),
    .rf_wd_wb(rf_wd_wb),
    .pc_sel_ex(pc_sel_ex),

    .rf_rd0_fe(rf_rd0_fe),
    .rf_rd1_fe(rf_rd1_fe),
    .rf_rd0_fd(rf_rd0_fd),
    .rf_rd1_fd(rf_rd1_fd),
    .stall_if(stall_if),
    .stall_id(stall_id),
    .stall_ex(stall_ex),
    .flush_if(flush_if),
    .flush_id(flush_id),
    .flush_ex(flush_ex),
    .flush_mem(flush_mem),

    .rf_re0_id(rf_re0_id),
    .rf_re1_id(rf_re1_id),
    .rf_ra0_id(rf_ra0_id),
    .rf_ra1_id(rf_ra1_id),
    .rf_we_ex(rf_we_ex),
    .rf_wa_ex(rf_wa_ex),
    .rf_wd_sel_ex(rf_wd_sel_ex)
);

// DEBUG
wire [31:0] check_data_if;
wire [31:0] check_data_id;
wire [31:0] check_data_ex;
wire [31:0] check_data_mem;
wire [31:0] check_data_wb;
wire [31:0] check_data_hzd;

Check_Data_SEL check_data_sel_iF(
    .pc_cur(pc_cur_if),
    .instruction(inst_if),
    .rf_ra0(inst_if[19:15]),
    .rf_ra1(inst_if[24:20]),
    .rf_re0(1'h0),
    .rf_re1(1'h0),
    .rf_rd0_raw(32'h0),
    .rf_rd1_raw(32'h0),
    .rf_rd0(32'h0),
    .rf_rd1(32'h0),
    .rf_wa(inst_if[11:7]),
    .rf_wd_sel(2'h0),
    .rf_wd(32'h0),
    .rf_we(1'h0),
    .immediate(32'h0),
    .alu_sr1(32'h0),
    .alu_sr2(32'h0),
    .alu_func(4'h0),
    .alu_ans(32'h0),
    .pc_add4(pc_add4_if),
    .pc_br(32'h0),
    .pc_jal(32'h0),
    .pc_jalr(32'h0),
    .pc_sel(2'h0),
    .pc_next(32'h0),
    .dm_addr(32'h0),
    .dm_din(32'h0),
    .dm_dout(32'h0),
    .dm_we(1'h0),

    .check_addr(cpu_check_addr[4:0]),
    .check_data(check_data_if)
);

Check_Data_SEL check_data_sel_id(
    .pc_cur(pc_cur_id),
    .instruction(inst_id),
    .rf_ra0(rf_ra0_id),
    .rf_ra1(rf_ra1_id),
    .rf_re0(rf_re0_id),
    .rf_re1(rf_re1_id),
    .rf_rd0_raw(rf_rd0_raw_id),
    .rf_rd1_raw(rf_rd1_raw_id),
    .rf_rd0(32'h0),
    .rf_rd1(32'h0),
    .rf_wa(rf_wa_id),
    .rf_wd_sel(rf_wd_sel_id),
    .rf_wd(32'h0),
    .rf_we(rf_we_id),
    .immediate(imm_id),
    .alu_sr1(32'h0),
    .alu_sr2(32'h0),
    .alu_func(alu_func_id),
    .alu_ans(32'h0),
    .pc_add4(pc_add4_id),
    .pc_br(32'h0),
    .pc_jal(32'h0),
    .pc_jalr(32'h0),
    .pc_sel(2'h0),
    .pc_next(32'h0),
    .dm_addr(32'h0),
    .dm_din(32'h0),
    .dm_dout(32'h0),
    .dm_we(mem_we_id), // diff

    .check_addr(cpu_check_addr[4:0]),
    .check_data(check_data_id)
);

Check_Data_SEL check_data_sel_ex(
    .pc_cur(pc_cur_ex),
    .instruction(inst_ex),
    .rf_ra0(rf_ra0_ex),
    .rf_ra1(rf_ra1_ex),
    .rf_re0(rf_re0_ex),
    .rf_re1(rf_re1_ex),
    .rf_rd0_raw(rf_rd0_raw_ex),
    .rf_rd1_raw(rf_rd1_raw_ex),
    .rf_rd0(rf_rd0_ex),
    .rf_rd1(rf_rd1_ex),
    .rf_wa(rf_wa_ex),
    .rf_wd_sel(rf_wd_sel_ex),
    .rf_wd(32'h0),
    .rf_we(rf_we_ex),
    .immediate(imm_ex),
    .alu_sr1(alu_src1_ex),
    .alu_sr2(alu_src2_ex),
    .alu_func(alu_func_ex),
    .alu_ans(alu_ans_ex),
    .pc_add4(pc_add4_ex),
    .pc_br(alu_ans_ex),
    .pc_jal(alu_ans_ex),
    .pc_jalr(pc_jalr_ex),
    .pc_sel(pc_sel_ex),
    .pc_next(pc_next),
    .dm_addr(alu_ans_ex),
    .dm_din(rf_rd1_ex),
    .dm_dout(32'h0),
    .dm_we(dm_we_ex),

    .check_addr(cpu_check_addr[4:0]),
    .check_data(check_data_ex)
);

Check_Data_SEL check_data_sel_mem(
    .pc_cur(pc_cur_mem),
    .instruction(inst_mem),
    .rf_ra0(rf_ra0_mem),
    .rf_ra1(rf_ra1_mem),
    .rf_re0(rf_re0_mem),
    .rf_re1(rf_re1_mem),
    .rf_rd0_raw(rf_rd0_raw_mem),
    .rf_rd1_raw(rf_rd1_raw_mem),
    .rf_rd0(rf_rd0_mem),
    .rf_rd1(rf_rd1_mem),
    .rf_wa(rf_wa_mem),
    .rf_wd_sel(rf_wd_sel_mem),
    .rf_wd(32'h0),
    .rf_we(rf_we_mem),
    .immediate(imm_mem),
    .alu_sr1(alu_src1_mem),
    .alu_sr2(alu_src2_mem),
    .alu_func(alu_func_mem),
    .alu_ans(alu_ans_mem),
    .pc_add4(pc_add4_mem),
    .pc_br(pc_br_mem),
    .pc_jal(pc_jal_mem),
    .pc_jalr(pc_jalr_mem),
    .pc_sel(pc_sel_mem),
    .pc_next(pc_next_mem),
    .dm_addr(dm_addr_mem),
    .dm_din(dm_din_mem),
    .dm_dout(dm_dout),
    .dm_we(dm_we_mem),

    .check_addr(cpu_check_addr[4:0]),
    .check_data(check_data_mem)
);

Check_Data_SEL check_data_sel_wb(
    .pc_cur(pc_cur_wb),
    .instruction(inst_wb),
    .rf_ra0(rf_ra0_wb),
    .rf_ra1(rf_ra1_wb),
    .rf_re0(rf_re0_wb),
    .rf_re1(rf_re1_wb),
    .rf_rd0_raw(rf_rd0_raw_wb),
    .rf_rd1_raw(rf_rd1_raw_wb),
    .rf_rd0(rf_rd0_wb),
    .rf_rd1(rf_rd1_wb),
    .rf_wa(rf_wa_wb),
    .rf_wd_sel(rf_wd_sel_wb),
    .rf_wd(rf_wd_wb),
    .rf_we(rf_we_wb),
    .immediate(imm_wb),
    .alu_sr1(alu_src1_wb),
    .alu_sr2(alu_src2_wb),
    .alu_func(alu_func_wb),
    .alu_ans(alu_ans_wb),
    .pc_add4(pc_add4_wb),
    .pc_br(pc_br_wb),
    .pc_jal(pc_jal_wb),
    .pc_jalr(pc_jalr_wb),
    .pc_sel(pc_sel_wb),
    .pc_next(pc_next_wb),
    .dm_addr(dm_addr_wb),
    .dm_din(dm_din_wb),
    .dm_dout(dm_dout),
    .dm_we(dm_we_wb),

    .check_addr(cpu_check_addr[4:0]),
    .check_data(check_data_wb)
);

Check_Data_SEL_HZD check_data_sel_hzd(
    .rf_ra0_ex(rf_ra0_ex),
    .rf_ra1_ex(rf_ra1_ex),
    .rf_re0_ex(rf_re0_ex),
    .rf_re1_ex(rf_re1_ex),
    .rf_wa_mem(rf_wa_mem),
    .rf_we_mem(rf_we_mem),
    .rf_wd_sel_mem(rf_wd_sel_mem),
    .alu_ans_mem(alu_ans_mem),
    .pc_add4_mem(pc_add4_mem),
    .imm_mem(imm_mem),
    .rf_wa_wb(rf_wa_wb),
    .rf_we_wb(rf_we_wb),
    .rf_wd_wb(rf_wd_wb),
    .pc_sel_ex(pc_sel_ex),

    .rf_rd0_fe(rf_rd0_fe),
    .rf_rd1_fe(rf_rd1_fe),
    .rf_rd0_fd(rf_rd0_fd),
    .rf_rd1_fd(rf_rd1_fd),
    .stall_if(stall_if),
    .stall_id(stall_id),
    .stall_ex(stall_ex),
    .flush_if(flush_if),
    .flush_id(flush_id),
    .flush_ex(flush_ex),
    .flush_mem(flush_mem),

    .check_addr(cpu_check_addr[4:0]),
    .check_data(check_data_hzd)
);
wire [31:0] check_data;
Check_Data_SEG_SEL check_data_seg_sel(
    .check_data_if(check_data_if),
    .check_data_id(check_data_id),
    .check_data_ex(check_data_ex),
    .check_data_mem(check_data_mem),
    .check_data_wb(check_data_wb),
    .check_data_hzd(check_data_hzd),

    .check_addr(cpu_check_addr[7:5]),
    .check_data(check_data)
);

Mux2 cpu_check_data_sel(
    .mux_sr1(check_data),
    .mux_sr2(rf_rd_dbg_id),
    .mux_ctrl(cpu_check_addr[12]),
    .mux_out(cpu_check_data)
);
endmodule