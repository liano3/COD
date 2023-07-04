module MEM(
    input clk,

    // MEM Data BUS with CPU
	//指令存储器端口
    input [31:0] im_addr,
    output [31:0] im_dout,
	
	//数据存储器端口
    input  [31:0] dm_addr,
    input dm_we,
    input  [31:0] dm_din,
    output [31:0] dm_dout,

    // MEM Debug BUS
    input [31:0] mem_check_addr,
    output [31:0] mem_check_data
);
// TODO:
inst_mem inst_mem0(
    .a(im_addr >> 2),
    .spo(im_dout)
);
data_mem data_mem0(
    .a(dm_addr >> 2),        // input wire [7 : 0] a
    .d(dm_din),        // input wire [31 : 0] d
    .dpra(mem_check_addr),  // input wire [7 : 0] dpra
    .clk(clk),    // input wire clk
    .we(dm_we),      // input wire we
    .spo(dm_dout),    // output wire [31 : 0] spo
    .dpo(mem_check_data)    // output wire [31 : 0] dpo
);
endmodule