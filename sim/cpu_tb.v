`timescale 1ns/1ps

module cpu_tb;
    reg clk;
    reg reset;
    wire [7:0] out_data;

    // Instantiate the top-level CPU
    top_cpu cpu (
        .clk(clk),
        .reset(reset),
        .out_data(out_data)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulation control
    initial begin
        // Dump waveform to VCD file
        $dumpfile("dump.vcd");
        $dumpvars(1, cpu_tb);

        $display("Time\tclk\treset\tout_data");
        $monitor("%4t\t%b\t%b\t%h", $time, clk, reset, out_data);

        // Apply reset
        reset = 1;
        #10;
        reset = 0;

        // Let the CPU run for some cycles
        #200;

        // End simulation
        $display("Simulation finished.");
        $finish;
    end
endmodule
