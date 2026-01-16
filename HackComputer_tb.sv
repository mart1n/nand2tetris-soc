`timescale 1ns / 1ps

module HackComputer_tb();

    // Inputs to the Top Module
    logic clk100;
    logic reset;
    logic [3:0] switches;
    logic ps2_clk;
    logic ps2_data;

    // Outputs from the Top Module
    logic [3:0] vga_r, vga_g, vga_b;
    logic hsync, vsync;

    // Instantiate the Unit Under Test (UUT)
    Arty_Hack_Top uut (
        .CLK100MHZ(clk100),
        .btn_reset(reset),
        .sw(switches),
        .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b),
        .hsync(hsync), .vsync(vsync),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data)
    );

    // 100MHz Clock Generation (10ns period)
    always #5 clk100 = ~clk100;

    initial begin
        // Initialize Signals
        clk100 = 0;
        reset = 1;      // Start in reset
        switches = 4'b0;
        ps2_clk = 1;
        ps2_data = 1;

        // Wait 100ns for global reset
        #100;
        reset = 0;      // Release reset

        $display("--- Starting Hack CPU Simulation ---");
        $display("Time\t PC\t Instr\t\t ALU Out\t writeM");

        // Run for a specific amount of time
        #2000;

        $display("--- Simulation Finished ---");
        $finish;
    end

    // Monitor internal CPU signals (using hierarchical paths)
    // This helps you see what's happening inside the CPU module
    always @(posedge uut.main_clk) begin
        if (!reset) begin
            $display("%0t\t %h\t %b\t %h\t\t %b",
                     $time, uut.pc, uut.instr, uut.outM, uut.writeM);
        end
    end

endmodule
