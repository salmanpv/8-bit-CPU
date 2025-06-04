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

    // FSM States
    reg [1:0] state;
    localparam FETCH = 2'b00, DECODE = 2'b01, EXECUTE = 2'b10;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= FETCH;
            halt <= 0;
        end else begin
            case (state)
                FETCH: begin
                    // Fetch instruction into IR and increment PC
                    ir_load <= 1;
                    pc_inc <= 1;

                    // Clear other controls
                    regA_load <= 0;
                    regR0_load <= 0;
                    regR1_load <= 0;
                    output_enable <= 0;
                    pc_load <= 0;
                    alu_op <= 2'b00;

                    state <= DECODE;
                end

                DECODE: begin
                    // Clear fetch signals
                    ir_load <= 0;
                    pc_inc <= 0;
                    state <= EXECUTE;
                end

                EXECUTE: begin
                    // Clear all relevant control signals before evaluating
                    regA_load <= 0;
                    regR0_load <= 0;
                    regR1_load <= 0;
                    output_enable <= 0;
                    pc_load <= 0;
                    alu_op <= 2'b00;

                    case (opcode)
                        4'b0000: ; // NOP

                        4'b0001: regR0_load <= 1; // LDI R0, imm

                        4'b0010: begin          // ADD R0
                            alu_op <= 2'b00;
                            regA_load <= 1;
                        end

                        4'b0011: begin          // SUB R0
                            alu_op <= 2'b01;
                            regA_load <= 1;
                        end

                        4'b0100: regR1_load <= 1; // LDI R1, imm

                        4'b0101: begin          // ADD R1
                            alu_op <= 2'b00;
                            regA_load <= 1;
                        end

                        4'b0110: begin          // SUB R1
                            alu_op <= 2'b01;
                            regA_load <= 1;
                        end

                        4'b0111: output_enable <= 1; // OUT

                        4'b1000: pc_load <= 1; // JMP addr

                        4'b1001: begin // JZ addr
                            if (zero)
                                pc_load <= 1;
                        end

                        4'b1010: begin // JC addr
                            if (carry)
                                pc_load <= 1;
                        end

                        4'b1111: halt <= 1; // HLT

                        default: ; // Unknown opcode
                    endcase

                    state <= FETCH; // Next cycle: fetch new instruction
                end
            endcase
        end
    end
endmodule
