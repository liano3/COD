`timescale 1ns / 1ps
// 拆分要写入 mem 的数据
module mem_in(
    input [31:0] data,
    input [3:0] we,
    output reg [7:0] byte0,
    output reg [7:0] byte1,
    output reg [7:0] byte2,
    output reg [7:0] byte3
);
always @(*) begin
    byte0 = 8'h0;
    byte1 = 8'h0;
    byte2 = 8'h0;
    byte3 = 8'h0;
    case (we)
        4'b1111: begin 
            byte3 = data[31:24]; 
            byte2 = data[23:16]; 
            byte1 = data[15:8]; 
            byte0 = data[7:0]; 
        end
        4'b0011: begin 
            byte1 = data[15:8]; 
            byte0 = data[7:0]; 
        end
        4'b1100: begin 
            byte3 = data[15:8];  
            byte2 = data[7:0]; 
        end
        4'b0001: byte0 = data[7:0];
        4'b0010: byte1 = data[7:0];
        4'b0100: byte2 = data[7:0];
        4'b1000: byte3 = data[7:0];
        default: begin 
            byte3 = 8'h0; 
            byte2 = 8'h0; 
            byte1 = 8'h0; 
            byte0 = 8'h0; 
        end
    endcase
end
endmodule
