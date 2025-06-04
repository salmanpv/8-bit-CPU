// =======================
// 8-bit CPU - All Modules
// =======================

////////////////////////////
// Instruction Register
module instruction_register (
    input wire clk,
    input wire reset,
    input wire load,
    input wire [7:0] instr_in,
    output reg [3:0] opcode,
    output reg [7:0] operand
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            opcode <= 4'b0000;
            operand <= 8'b0;
        end else if (load) begin
            opcode <= instr_in[7:4];
            operand <= instr_in;
        end
    end
endmodule

////////////////////////////
// 8-bit Register
module reg8 (
    input wire clk,
    input wire reset,
    input wire load,
    input wire [7:0] data_in,
    output reg [7:0] data_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 8'b0;
        else if (load)
            data_out <= data_in;
    end
endmodule

////////////////////////////
// Program Counter (with HALT support)
module program_counter (
    input wire clk,
    input wire reset,
    input wire load,
    input wire inc,
    input wire halt,
    input wire [3:0] data_in,
    output reg [3:0] addr_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            addr_out <= 4'b0000;
        else if (!halt) begin
            if (load)
                addr_out <= data_in;
            else if (inc)
                addr_out <= addr_out + 1;
        end
    end
endmodule

////////////////////////////
// ALU
module alu (
    input wire [7:0] A,
    input wire [7:0] B,
    input wire [1:0] op,
    output reg [7:0] result,
    output reg zero,
    output reg carry
);
    reg [8:0] temp;

    always @(*) begin
        case (op)
            2'b00: temp = A + B;
            2'b01: temp = A - B;
            2'b10: temp = A & B;
            2'b11: temp = A | B;
            default: temp = 9'b0;
        endcase

        result = temp[7:0];
        carry = temp[8];
        zero = (result == 8'b0);
    end
endmodule

////////////////////////////
// ROM (Simplified Test Program)
module rom (
    input wire [3:0] addr,
    output reg [7:0] data
);
    reg [7:0] mem [0:15];

    initial begin
        // Test Program: LDI R0, 5; ADD R0; OUT; HLT
        mem[0] = 8'b0001_0000; // LDI R0
	mem[1] = 8'h05;        // Load value 5
	mem[2] = 8'b0010_0000; // ADD R0 → ACC = 0 + 5 = 5
	mem[3] = 8'b0111_0000; // OUT → Output ACC = 5
	mem[4] = 8'b1111_0000; // HLT → Stop
    end

    always @(*) begin
        data = mem[addr];
    end
endmodule

////////////////////////////
// Control Unit
module control_unit (
    input wire clk,
    input wire reset,
    input wire [3:0] opcode,
    input wire zero,
    input wire carry,
    output reg pc_inc,
    output reg pc_load,
    output reg ir_load,
    output reg regA_load,
    output reg regR0_load,
    output reg regR1_load,
    output reg [1:0] alu_op,
    output reg output_enable,
    output reg halt
);
    reg [1:0] state;
    localparam FETCH = 2'b00, DECODE = 2'b01, EXECUTE = 2'b10;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= FETCH;
            halt <= 0;
        end else begin
            case (state)
                FETCH: begin
                    ir_load <= 1;
                    pc_inc <= 1;
                    state <= DECODE;

                    regA_load <= 0;
                    regR0_load <= 0;
                    regR1_load <= 0;
                    output_enable <= 0;
                    pc_load <= 0;
                    alu_op <= 2'b00;
                end
                DECODE: begin
                    ir_load <= 0;
                    pc_inc <= 0;
                    state <= EXECUTE;
                end
                EXECUTE: begin
                    regA_load <= 0;
                    regR0_load <= 0;
                    regR1_load <= 0;
                    output_enable <= 0;
                    pc_load <= 0;
                    alu_op <= 2'b00;

                    case (opcode)
                        4'b0000: ; // NOP
                        4'b0001: regR0_load <= 1;                     // LDI R0
                        4'b0010: begin alu_op <= 2'b00; regA_load <= 1; end // ADD R0
                        4'b0011: begin alu_op <= 2'b01; regA_load <= 1; end // SUB R0
                        4'b0100: regR1_load <= 1;                     // LDI R1
                        4'b0101: begin alu_op <= 2'b00; regA_load <= 1; end // ADD R1
                        4'b0110: begin alu_op <= 2'b01; regA_load <= 1; end // SUB R1
                        4'b0111: output_enable <= 1;                  // OUT
                        4'b1000: pc_load <= 1;                        // JMP
                        4'b1001: if (zero) pc_load <= 1;             // JZ
                        4'b1010: if (carry) pc_load <= 1;            // JC
                        4'b1111: halt <= 1;                           // HLT
                        default: ;
                    endcase

                    state <= FETCH;
                end
            endcase
        end
    end
endmodule

////////////////////////////
// Top-Level CPU Module
module top_cpu (
    input wire clk,
    input wire reset,
    output wire [7:0] out_data
);
    wire [7:0] instr;
    wire [3:0] opcode;
    wire [7:0] operand;
    wire [3:0] pc_addr;
    wire [7:0] rom_data;

    wire [7:0] regA_out, regR0_out, regR1_out;
    wire [7:0] alu_result;
    wire zero, carry;

    wire pc_inc, pc_load, ir_load;
    wire regA_load, regR0_load, regR1_load;
    wire [1:0] alu_op;
    wire output_enable;
    wire halt;

    rom rom0 (.addr(pc_addr), .data(rom_data));
    program_counter pc0 (
        .clk(clk),
        .reset(reset),
        .load(pc_load),
        .inc(pc_inc),
        .halt(halt),                      // pass halt to PC
        .data_in(operand[3:0]),
        .addr_out(pc_addr)
    );
    instruction_register ir0 (.clk(clk), .reset(reset), .load(ir_load), .instr_in(rom_data), .opcode(opcode), .operand(operand));

    reg8 regA (.clk(clk), .reset(reset), .load(regA_load), .data_in(alu_result), .data_out(regA_out));
    reg8 regR0 (.clk(clk), .reset(reset), .load(regR0_load), .data_in(operand), .data_out(regR0_out));
    reg8 regR1 (.clk(clk), .reset(reset), .load(regR1_load), .data_in(operand), .data_out(regR1_out));

    alu alu0 (
        .A(regA_out),
        .B((opcode[0] == 1'b0) ? regR0_out : regR1_out),
        .op(alu_op),
        .result(alu_result),
        .zero(zero),
        .carry(carry)
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

    assign out_data = output_enable ? regA_out : 8'bz;
endmodule
