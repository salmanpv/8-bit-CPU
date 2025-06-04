# 8-bit-CPU

Simple 8-bit CPU

Note :

| Module          | Width | Why?                       |
| --------------- | ----- | -------------------------- |
| Registers       | 8-bit | Hold actual 8-bit data     |
| ALU             | 8-bit | Perform 8-bit math         |
| Program Counter | 4-bit | Address 16 memory slots    |
| Memory          | 16×8  | 16 bytes, each 8 bits wide |

Spec :

8-bit data width  
8-bit instructions  
A small instruction set (e.g., 6–8 operations)  
Program Counter (PC), Instruction Register (IR)  
A few general-purpose registers (like R0, R1)  
A simple RAM (16 or 32 bytes)  

Registers  
ALU  
Program Counter  
Instruction Decoder / Control Unit  
RAM / ROM  
CPU Top Module (connecting everything)  

| Opcode | Mnemonic      | Instruction Format | Description                            |
| ------ | ------------- | ------------------ | -------------------------------------- |
| `0000` | `NOP`         | -                  | Do nothing. Moves to next instruction. |
| `0001` | `LDI R0, imm` | 2 bytes            | Load immediate 8-bit value into `R0`.  |
| `0010` | `ADD R0`      | 1 byte             | Add `R0` to `A`, result → `A`.         |
| `0011` | `SUB R0`      | 1 byte             | Subtract `R0` from `A`, result → `A`.  |
| `0100` | `LDI R1, imm` | 2 bytes            | Load immediate 8-bit value into `R1`.  |
| `0101` | `ADD R1`      | 1 byte             | Add `R1` to `A`, result → `A`.         |
| `0110` | `SUB R1`      | 1 byte             | Subtract `R1` from `A`, result → `A`.  |
| `0111` | `OUT`         | 1 byte             | Output the value of `A`.               |
| `1000` | `JMP addr`    | 2 bytes            | Jump to 8-bit address unconditionally. |
| `1001` | `JZ addr`     | 2 bytes            | Jump if `zero` flag is set.            |
| `1010` | `JC addr`     | 2 bytes            | Jump if `carry` flag is set.           |
| `1111` | `HLT`         | 1 byte             | Halt execution permanently.            |


The Control Unit (CU) reads the opcode from the instruction and:  
Sets control signals for:  
Register loads  
ALU operations  
Program Counter (increment or jump)  
Output enable  
Advances the CPU through fetch → decode → execute cycles  

| State       | What happens                                 |
| ----------- | -------------------------------------------- |
| **FETCH**   | Load instruction from memory into IR         |
| **DECODE**  | Read opcode & operand, prepare control lines |
| **EXECUTE** | Perform the instruction (ALU, jump, etc.)    |


| Opcode | Mnemonic    | Bytes | Operand Field Used? | Second Byte Used? | Description                              |
| ------ | ----------- | ----- | ------------------- | ----------------- | ---------------------------------------- |
| 0000   | NOP         | 1     | ❌ Ignored           | ❌ No              | Do nothing. Moves to next instruction.   |
| 0001   | LDI R0, imm | 2     | ❌ Ignored           | ✅ Yes (imm8)      | Load immediate 8-bit value into R0.      |
| 0010   | ADD R0      | 1     | ❌ Ignored           | ❌ No              | Add R0 to A, result → A.                 |
| 0011   | SUB R0      | 1     | ❌ Ignored           | ❌ No              | Subtract R0 from A, result → A.          |
| 0100   | LDI R1, imm | 2     | ❌ Ignored           | ✅ Yes (imm8)      | Load immediate 8-bit value into R1.      |
| 0101   | ADD R1      | 1     | ❌ Ignored           | ❌ No              | Add R1 to A, result → A.                 |
| 0110   | SUB R1      | 1     | ❌ Ignored           | ❌ No              | Subtract R1 from A, result → A.          |
| 0111   | OUT         | 1     | ❌ Ignored           | ❌ No              | Output the value of A.                   |
| 1000   | JMP addr    | 2     | ❌ Ignored           | ✅ Yes (addr8)     | Jump to 8-bit address unconditionally.   |
| 1001   | JZ addr     | 2     | ❌ Ignored           | ✅ Yes (addr8)     | Jump to 8-bit address if zero flag set.  |
| 1010   | JC addr     | 2     | ❌ Ignored           | ✅ Yes (addr8)     | Jump to 8-bit address if carry flag set. |
| 1111   | HLT         | 1     | ❌ Ignored           | ❌ No              | Halt execution permanently.              |

Key Connections of top layer CPU:  
The Program Counter outputs the instruction address to ROM.  
The ROM sends the instruction (8-bit) to the Instruction Register.  
The Instruction Register provides the opcode and operand to the Control Unit.  
The Control Unit drives the control signals (e.g., pc_load, regR0_load, alu_op, etc.) to the appropriate modules (e.g., PC, registers, ALU).  
The ALU performs the operation based on the alu_op control signal and the values in the registers.  
The Output Register is updated if there’s an output instruction (OUT).  
The Program Counter is updated after each instruction, based on whether it's a normal instruction or a jump instruction (e.g., JMP, JC, JZ).  

Explanation of the Top-Level CPU Module:  
Program Counter (PC): This generates the address for the instruction to be fetched from ROM. It either increments normally or loads a new address in the case of a jump.  
Instruction Register (IR): Holds the fetched instruction and splits it into opcode and operand.  
Control Unit (CU): It decodes the opcode and generates control signals for the CPU's operation, like whether to load a register, perform an ALU operation, or jump to a new address.  
ALU: The ALU executes arithmetic or logical operations based on the alu_op control signal and the operands provided (either from the registers or the instruction).  
Registers: regA, regR0, and regR1 hold intermediate data. regA holds the accumulator, and regR0/regR1 hold the register values.  
Output Register (Out): If the OUT instruction is executed, the value in regA is moved to out_reg and can be sent to I/O.  
ROM: This holds the program instructions. The Program Counter provides the address to fetch instructions.  
Halt Logic: The CPU halts when the HLT instruction is encountered.  

Yosys, Netlistsvg commands:  

yosys  

read_verilog cpu.v  
hierarchy -check -top top_cpu  
synth  
write_json cpu.json  

netlistsvg cpu.json -o cpu.svg  

Files:

8-bit Register Module - reg8.v  
Program Counter - pc.v  
ALU Module - alu.v  
Instruction Reg - ir.v  


