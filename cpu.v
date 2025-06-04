// CPU

module cpu (
    input wire clk,
    input wire reset
);
    // Declare internal signals and wires
    wire [3:0] opcode;
    wire [3:0] operand;
    wire [7:0] instr;
    wire [7:0] alu_result;
    wire zero, carry;

    // Control signals
    wire pc_inc, pc_load, ir_load, regA_load, regR0_load, regR1_load;
    wire [1:0] alu_op;
    wire output_enable, halt;

    // Instantiate submodules
    program_counter pc (
        .clk(clk),
        .reset(reset),
        .load(pc_load),
        .inc(pc_inc),
        .data_in(operand),  // For jump instructions
        .addr_out(addr_out)
    );

    instruction_register ir (
        .clk(clk),
        .reset(reset),
        .load(ir_load),
        .instr_in(instr),
        .opcode(opcode),
        .operand(operand)
    );

    control_unit cu (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .zero(zero),
        .carry(carry),
        .pc_inc(pc_inc),
        .pc_load(pc_load),
        .ir_load(ir_load),
        .regA_load(regA_load),
        .regR0_load(regR0_load),
        .regR1_load(regR1_load),
        .alu_op(alu_op),
        .output_enable(output_enable),
        .halt(halt)
    );

    alu alu_inst (
        .A(regA),         // The register A value
        .B(regR0),        // R0 or R1 depending on the instruction
        .op(alu_op),      // ALU operation (e.g., ADD, SUB)
        .result(alu_result),
        .zero(zero),
        .carry(carry)
    );

    reg8 regA (
        .clk(clk),
        .reset(reset),
        .load(regA_load),
        .data_in(alu_result),
        .data_out(regA)
    );

    reg8 regR0 (
        .clk(clk),
        .reset(reset),
        .load(regR0_load),
        .data_in(operand),  // Immediate value or data for loading
        .data_out(regR0)
    );

    reg8 regR1 (
        .clk(clk),
        .reset(reset),
        .load(regR1_load),
        .data_in(operand),  // Immediate value or data for loading
        .data_out(regR1)
    );

    // Output register (to handle OUT instruction)
    reg8 out_reg (
        .clk(clk),
        .reset(reset),
        .load(output_enable),
        .data_in(regA),  // The value of regA will be sent to output
        .data_out(output_data)
    );

    // ROM for storing the program
    rom rom_inst (
        .addr(addr_out),   // The address from PC
        .instr_out(instr)  // The instruction fetched from ROM
    );

    // Halt logic (reset CPU on halt)
    always @(posedge clk or posedge reset) begin
        if (reset || halt) begin
            // Stop the CPU when halt is activated
            $finish;
        end
    end

endmodule
