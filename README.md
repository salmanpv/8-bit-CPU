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


Files:

8-bit Register Module - reg8.v  
Program Counter - pc.v  
ALU Module - alu.v  
Instruction Reg - ir.v  


