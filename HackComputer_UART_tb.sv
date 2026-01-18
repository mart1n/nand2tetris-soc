`timescale 1ns / 1ps

module Arty_Hack_SoC_tb();

    // --- Clock and Reset ---
    logic clk100 = 0;
    logic btn_reset;

    // --- I/O Signals ---
    logic [3:0] sw;
    logic [3:0] led;
    logic uart_tx_out;
    logic [3:0] vga_r, vga_g, vga_b;
    logic hsync, vsync;
    logic ps2_clk, ps2_data;

    // --- Instantiate the SoC ---
    Arty_Hack_Top uut (
        .CLK100MHZ(clk100),
        .btn_reset(btn_reset),
        .sw(sw),
        .led(led),
        .uart_txd_out(uart_tx_out),
        .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b),
        .hsync(hsync), .vsync(vsync),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data)
    );

    // 100MHz Clock (10ns period)
    always #5 clk100 = ~clk100;

    // --- UART Monitor Logic ---
    // This helper logic samples the TX line and prints bytes to the console
    localparam BIT_PERIOD = 8680; // 1/115200 in ns
    logic [7:0] captured_byte;

    initial begin
        // Initialize
        btn_reset = 1;
        sw = 4'b0000;
        ps2_clk = 1;
        ps2_data = 1;

        // Release Reset
        #100;
        btn_reset = 0;
        $display("Time\t\tPC\tInstr\t\tALU_Out\tLEDs");

        // Run simulation for enough time to see UART activity
        #100000;
        $finish;
    end

    // --- Simulation Monitoring ---

    // 1. Monitor CPU Instructions
    always @(posedge uut.main_clk) begin
        if (!btn_reset && uut.cpu.isCInst) begin
            $display("%0t\t%h\t%b\t%h\t%b",
                     $time, uut.pc, uut.instr, uut.outM, led);
        end
    end

    // 2. Monitor UART Serial Line
    // This looks for the start bit and waits to sample the center of each bit
    always @(negedge uart_tx_out) begin
        if (!btn_reset) begin
            #(BIT_PERIOD / 2); // Wait for middle of start bit
            #(BIT_PERIOD);     // Skip start bit
            for (int i = 0; i < 8; i = i + 1) begin
                captured_byte[i] = uart_tx_out;
                #(BIT_PERIOD);
            end
            $display("[UART INFO] Byte Received: %h", captured_byte);
        end
    end

endmodule
