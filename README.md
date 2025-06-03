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

| Opcode | Instruction | Description            |
| ------ | ----------- | ---------------------- |
| 0000   | NOP         | No operation           |
| 0001   | LDI R, imm  | Load immediate to R    |
| 0010   | ADD R       | Add R to Accumulator   |
| 0011   | SUB R       | Sub R from Accumulator |
| 0100   | JMP addr    | Jump to address        |
| 0101   | JC addr     | Jump if carry          |
| 0110   | JZ addr     | Jump if zero           |
| 0111   | OUT         | Output Accumulator     |
| 1111   | HLT         | Halt                   |

