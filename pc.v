// Program Counter

module program_counter (
    input wire clk,
    input wire reset,
    input wire load,
    input wire inc,
    input wire skip,              // NEW: for 2-byte instructions
    input wire [3:0] data_in,
    output reg [3:0] addr_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            addr_out <= 4'b0000;
        else if (load)
            addr_out <= data_in;  // Jump to address
        else if (skip)
            addr_out <= addr_out + 2;  // 2-byte instruction: skip 2 locations
        else if (inc)
            addr_out <= addr_out + 1;  // Normal increment
    end
endmodule

