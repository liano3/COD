module MEM(
    input clk,

    // MEM Data BUS with CPU
	// IM port
    input [31:0] im_addr,
    output [31:0] im_dout,
	
	// DM port
    input  [31:0] dm_addr,
    input [3:0] dm_re,
    input [3:0] dm_we,
    input sign,
    input  [31:0] dm_din,
    output [31:0] dm_dout,

    // MEM Debug BUS
    input [31:0] mem_check_addr,
    output [31:0] mem_check_data
);
// TODO: Your IP here.
// Remember that we need [9:2]?
wire [7:0] dm_out0;
wire [7:0] dm_out1;
wire [7:0] dm_out2;
wire [7:0] dm_out3;

wire [7:0] dm_in0;
wire [7:0] dm_in1;
wire [7:0] dm_in2;
wire [7:0] dm_in3;

inst_mem inst (
    .a(im_addr[10:2]),      // input wire [7 : 0] a
    .spo(im_dout)  // output wire [31 : 0] spo
);
mem_in mem_in0 (
    .data(dm_din),
    .we(dm_we),
    .byte0(dm_in0),
    .byte1(dm_in1),
    .byte2(dm_in2),
    .byte3(dm_in3)
);
data_mem data (
    .a(dm_addr[9:2]),        // input wire [7 : 0] a
    .d(dm_in0),        // input wire [31 : 0] d
    .dpra(mem_check_addr),  // input wire [7 : 0] dpra
    .clk(clk),    // input wire clk
    .we(dm_we[0]),      // input wire we
    .spo(dm_out0),    // output wire [31 : 0] spo
    .dpo(mem_check_data[7:0])    // output wire [31 : 0] dpo
);
data_mem1 data1 (
    .a(dm_addr[9:2]),        // input wire [7 : 0] a
    .d(dm_in1),        // input wire [31 : 0] d
    .dpra(mem_check_addr),  // input wire [7 : 0] dpra
    .clk(clk),    // input wire clk
    .we(dm_we[1]),      // input wire we
    .spo(dm_out1),    // output wire [31 : 0] spo
    .dpo(mem_check_data[15:8])    // output wire [31 : 0] dpo
);
data_mem2 data2 (
    .a(dm_addr[9:2]),        // input wire [7 : 0] a
    .d(dm_in2),        // input wire [31 : 0] d
    .dpra(mem_check_addr),  // input wire [7 : 0] dpra
    .clk(clk),    // input wire clk
    .we(dm_we[2]),      // input wire we
    .spo(dm_out2),    // output wire [31 : 0] spo
    .dpo(mem_check_data[23:16])    // output wire [31 : 0] dpo
);
data_mem3 data3 (
    .a(dm_addr[9:2]),        // input wire [7 : 0] a
    .d(dm_in3),        // input wire [31 : 0] d
    .dpra(mem_check_addr),  // input wire [7 : 0] dpra
    .clk(clk),    // input wire clk
    .we(dm_we[3]),      // input wire we
    .spo(dm_out3),    // output wire [31 : 0] spo
    .dpo(mem_check_data[31:24])    // output wire [31 : 0] dpo
);
mem_out mem_out0 (
    .byte0(dm_out0),
    .byte1(dm_out1),
    .byte2(dm_out2),
    .byte3(dm_out3),
    .re(dm_re),
    .sign(sign),
    .data(dm_dout)
);

endmodule