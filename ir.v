// Instruction Register

module instruction_register (
    input wire clk,
    input wire reset,
    input wire load,
    input wire [7:0] instr_in,
    output reg [3:0] opcode,
    output reg [3:0] operand
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            opcode <= 4'b0000;
            operand <= 4'b0000;
        end else if (load) begin
            opcode <= instr_in[7:4];
            operand <= instr_in[3:0];
        end
    end
endmodule
