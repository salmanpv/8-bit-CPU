// ROM

module rom (
    input wire [3:0] addr,        // Address input (e.g., program counter value)
    output reg [7:0] instruction  // Instruction output
);

    // Define the instruction set (for example, 16 instructions)
    reg [7:0] memory [0:15];      // Memory for storing 16 instructions

    // Load the instruction based on the address
    always @(*) begin
        instruction = memory[addr];  // Output the instruction stored at the address
    end

    // Initialize memory (the instruction set)
    initial begin
        memory[0] = 8'b00010000;  // LDI R0, imm (example)
        memory[1] = 8'b00100000;  // ADD R0 (example)
        memory[2] = 8'b00110000;  // SUB R0 (example)
        // Add the rest of your instruction set...
    end
endmodule
