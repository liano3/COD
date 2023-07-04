`timescale 1ns / 1ps
// 生成 mem 的控制信号，mem_re 和 mem_we 和 sign
module mem_ctrl(
    input [31:0] inst_mem,
    input [31:0] dm_addr_mem,
    output reg [3:0] mem_re,
    output reg [3:0] mem_we,
    output sign
);
assign sign = (inst_mem[6:0] == 7'b0000011 && (inst_mem[14:12] == 3'b000 || inst_mem[14:12] == 3'b001));
always @(*) begin
    if (inst_mem[6:0] == 7'b0000011) begin
        mem_we = 4'b0000;
        case (inst_mem[14:12])
            3'b000: mem_re = 4'b0001 << dm_addr_mem[1:0];
            3'b100: mem_re = 4'b0001 << dm_addr_mem[1:0];
            3'b001: mem_re = 4'b0011 << dm_addr_mem[1:0];
            3'b101: mem_re = 4'b0011 << dm_addr_mem[1:0];
            3'b010: mem_re = 4'b1111;
            default: mem_re = 4'b0000;
        endcase
    end
    else if (inst_mem[6:0] == 7'b0100011) begin
        mem_re = 4'b0000;
        case (inst_mem[14:12])
            3'b000: mem_we = 4'b0001 << dm_addr_mem[1:0];
            3'b001: mem_we = 4'b0011 << dm_addr_mem[1:0];
            3'b010: mem_we = 4'b1111;
            default: mem_we = 4'b0000;
        endcase
    end
    else begin
        mem_re = 4'b0000;
        mem_we = 4'b0000;
    end
end
endmodule
