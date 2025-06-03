// ALU Module

module alu (
    input wire [7:0] A,      // First operand (e.g., accumulator)
    input wire [7:0] B,      // Second operand (e.g., register)
    input wire [1:0] op,     // Operation select
    output reg [7:0] result,
    output reg zero,
    output reg carry
);
    reg [8:0] temp; // One extra bit for carry

    always @(*) begin
        case (op)
            2'b00: temp = A + B;         // ADD
            2'b01: temp = A - B;         // SUB
            2'b10: temp = A & B;         // AND
            2'b11: temp = A | B;         // OR
            default: temp = 9'b0;
        endcase

        result = temp[7:0];       // Truncate to 8 bits
        carry = temp[8];          // MSB is the carry
        zero = (result == 8'b0);  // Set zero flag if result is 0
    end
endmodule
