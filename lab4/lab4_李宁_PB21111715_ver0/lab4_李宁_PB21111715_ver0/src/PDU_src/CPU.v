`timescale 1ns / 1ps
// CPU 顶层模块
module CPU(
    input clk, 
    input rst,

    // MEM And MMIO Data BUS
    output [31:0] im_addr,
    input [31:0] im_dout,
    output [31:0] mem_addr,
    output  mem_we,		            
    output [31:0] mem_din,
    input [31:0] mem_dout,	        

    // Debug BUS with PDU
    output [31:0] current_pc, 	            // current_pc
    output [31:0] next_pc,
    input [31:0] cpu_check_addr,	        // Check current datapath state (code)
    output [31:0] cpu_check_data      // Current datapath state data

);
wire [31:0] pc_cur;
wire [31:0] pc_next;
wire [31:0] inst;
assign inst = im_dout;
wire [31:0] mem_rd;
assign mem_rd = mem_dout;
// TODO:
PC pc(
    .clk(clk),
    .rst(rst),
    .pc_next(pc_next),
    .pc_cur(pc_cur)
);
wire [31:0] pc_add4;
ADD add0(
    .a(pc_cur),
    .b(32'h4),
    .sum(pc_add4)
);
wire [31:0] pc_jalr;
wire [31:0] alu_res;
AND and0(
    .a(alu_res),
    .b(32'hfffffffe),
    .out(pc_jalr)
);
wire [31:0] rd0;
wire [31:0] rd1;
wire [2:0] br_type;
wire br;
Branch branch0(
    .op1(rd0),
    .op2(rd1),
    .br_type(br_type),
    .br(br)
);
wire jal, jalr;
PC_MUX pc_mux0(
    .pc_add4(pc_add4),
    .alu_res(alu_res),
    .pc_jalr(pc_jalr),
    .jal(jal),
    .jalr(jalr),
    .br(br),
    .pc_next(pc_next)
);
wire [31:0] wb_data;
wire wb_en;
wire [31:0] rd_dbg;
RF rf(
    .clk(clk),
    .we(wb_en),
    .wa(inst[11:7]),
    .wd(wb_data),
    .ra0(inst[19:15]),
    .ra1(inst[24:20]),
    .rd0(rd0),
    .rd1(rd1),
    .ra_dbg(cpu_check_addr[4:0]),
    .rd_dbg(rd_dbg)
);
wire alu_op1_sel;
wire [31:0] alu_op1;
MUX1 alu_sel1(
    .sr0(rd0),
    .sr1(pc_cur),
    .alu_sel(alu_op1_sel),
    .sr_out(alu_op1)
);
wire [31:0] imm;
wire alu_op2_sel;
wire [31:0] alu_op2;
MUX1 alu_sel2(
    .sr0(rd1),
    .sr1(imm),
    .alu_sel(alu_op2_sel),
    .sr_out(alu_op2)
);
wire [3:0] alu_ctrl;
alu #(.WIDTH(32)) alu0(
    .a(alu_op1),
    .b(alu_op2),
    .func(alu_ctrl),
    .y(alu_res)
);
wire [1:0] wb_sel;
MUX2 wb_mux(
    .sr0(alu_res),
    .sr1(pc_add4),
    .sr2(mem_rd),
    .sr3(imm),
    .wb_sel(wb_sel),
    .sr_out(wb_data)
);
wire [2:0] imm_type;
Control control(
    .inst(inst),
    .jal(jal),
    .jalr(jalr),
    .br_type(br_type),
    .wb_en(wb_en),
    .wb_sel(wb_sel),
    .mem_we(mem_we),
    .alu_op1_sel(alu_op1_sel),
    .alu_op2_sel(alu_op2_sel),
    .alu_ctrl(alu_ctrl),
    .imm_type(imm_type)
);
IMM imm0(
    .inst(inst),
    .imm_type(imm_type),
    .imm(imm)
);
wire [31:0] check_data;
CHECK check(
    .pc_in(pc_next),
    .pc_out(pc_cur),
    .instruction(inst),
    .rf_ra0(inst[19:15]),
    .rf_ra1(inst[24:20]),
    .rf_rd0(rd0),
    .rf_rd1(rd1),
    .rf_wa(inst[11:7]),
    .rf_wd(wb_data),
    .rf_we(wb_en),
    .imm(imm),
    .alu_sr1(alu_op1),
    .alu_sr2(alu_op2),
    .alu_func(alu_ctrl),
    .alu_ans(alu_res),
    .pc_jalr(pc_jalr),
    .dm_addr(alu_res),
    .dm_din(mem_din),
    .dm_dout(mem_rd),
    .dm_we(mem_we),
    .check_addr(cpu_check_addr),
    .check_data(check_data)
);
MUX1 check_mux(
    .sr0(check_data),
    .sr1(rd_dbg),
    .alu_sel(cpu_check_addr[12]),
    .sr_out(cpu_check_data)
);
assign current_pc = pc_cur;
assign next_pc = pc_next;
assign im_addr = pc_cur;
assign mem_addr = alu_res;
assign mem_din = rd1;
endmodule