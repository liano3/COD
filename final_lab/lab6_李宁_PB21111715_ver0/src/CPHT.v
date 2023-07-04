`timescale 1ns / 1ps
// 竞争预测
module CPHT(
    input clk,
    input jump_local_if,
    input jump_global_if,
    input jump_local_ex,
    input jump_global_ex,
    input jump_ex,
    output jump_guess_if
);
// 2bit 计数器状态
parameter L = 2'b00;   // 局部对
parameter G = 2'b01;    // 全局对
parameter SG = 2'b10;   // 肯定是全局对
parameter SL = 2'b11;  // 肯定是局部对

reg [1:0] state;
reg [1:0] next_state;

assign jump_guess_if = (state == L || state == SL) ? jump_local_if : jump_global_if;

initial begin
    state = 2'b00;
end
// 状态机
always @(*) begin
    case (state)
        G: begin
            if (jump_local_ex == jump_ex && jump_global_ex != jump_ex)
                next_state = L;
            else if (jump_local_ex != jump_ex && jump_global_ex == jump_ex)
                next_state = SG;
            else
                next_state = G;
        end
        L: begin
            if (jump_local_ex == jump_ex && jump_global_ex != jump_ex)
                next_state = SL;
            else if (jump_local_ex != jump_ex && jump_global_ex == jump_ex)
                next_state = G;
            else
                next_state = L;
        end
        SL: begin
            if (jump_local_ex == jump_ex && jump_global_ex != jump_ex)
                next_state = SL;
            else if (jump_local_ex != jump_ex && jump_global_ex == jump_ex)
                next_state = L;
            else
                next_state = SL;
        end
        SG: begin
            if (jump_local_ex == jump_ex && jump_global_ex != jump_ex)
                next_state = G;
            else if (jump_local_ex != jump_ex && jump_global_ex == jump_ex)
                next_state = SG;
            else
                next_state = SG;
        end
    endcase
end
always @ (posedge clk) begin
    state <= next_state;
end
endmodule
