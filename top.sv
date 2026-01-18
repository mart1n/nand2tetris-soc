
module top (
    input  logic CLK100MHZ,      // 100MHz onboard oscillator
    input  logic btn_reset,      // Reset button (from XDC)
    input  logic [3:0] sw,       // Manual switches (keyboard fallback)
    output logic [3:0] led,      // Map to Arty A7 Green LEDs (LD0-LD3)

    // UART
    output logic uart_txd_out, // USB-UART TX

    // PMOD VGA (Headers JB and JC)
    output logic [3:0] vga_r, vga_g, vga_b,
    output logic hsync, vsync,

    // PMOD PS2 (Header JA)
    input  logic ps2_clk,
    input  logic ps2_data
);

    // --- 1. Clock Generation ---
    // Dividing 100MHz to 25MHz for VGA and CPU operations
    logic [1:0] clk_div = 0;
    always_ff @(posedge CLK100MHZ) clk_div <= clk_div + 1;
    logic main_clk;
    assign main_clk = clk_div[1]; // 25MHz

    // --- 2. CPU Signals & Interconnects ---
    logic [15:0] instr, inM, outM, ram_out, screen_out;
    logic [14:0] addrM, pc;
    logic writeM, write_ram, write_screen;
    logic [15:0] keyboard_out;

    // --- 3. Memory Mapping Logic ---
    // RAM: 0x0000 - 0x3FFF (16K)
    // Screen: 0x4000 - 0x5FFF (8K)
    // Keyboard: 0x6000 (1 word)
    assign write_ram    = writeM && (addrM < 15'h4000);
    assign write_screen = writeM && (addrM >= 15'h4000 && addrM < 15'h6000);

    // LED Register Logic: Address 0x6001 (24577 decimal)
    logic [3:0] led_reg;
    always_ff @(posedge main_clk) begin
        if (btn_reset) begin
            led_reg <= 4'b0;
        end else if (writeM && (addrM == 15'h6001)) begin
            led_reg <= outM[3:0]; // Capture the lower 4 bits of the ALU output
        end
    end
    assign led = led_reg;

    // --- Memory Read Mux (Updated) ---
    always_comb begin
        if (addrM < 15'h4000)      inM = ram_out;
        else if (addrM < 15'h6000) inM = screen_out;
        else if (addrM == 15'h6000)inM = keyboard_out;
        else if (addrM == 15'h6001)inM = {12'b0, led_reg}; // Allow CPU to read back LED state
        else                       inM = 16'b0;
    end

    // --- 4. Sub-Module Instantiations ---

    // Hack CPU (with internal ALU)
    HackCPU cpu (
        .clk(main_clk),
        .reset(btn_reset),
        .inM(inM),
        .instruction(instr),
        .outM(outM),
        .writeM(writeM),
        .addressM(addrM),
        .pc(pc)
    );

    // Instruction ROM (32K x 16-bit)
    // F4PGA uses this to initialize the BRAM with your code
    logic [15:0] rom [0:32767];
    initial $readmemb("program.mem", rom);
    assign instr = rom[pc];

    // Data RAM (16K x 16-bit)
    logic [15:0] ram [0:16383];
    always_ff @(posedge main_clk) begin
        if (write_ram) ram[addrM[13:0]] <= outM;
        ram_out <= ram[addrM[13:0]];
    end

    // PS/2 Keyboard Hardware
    logic [7:0] raw_scan;
    logic got_code;
    Ps2Receiver ps2_rx (
        .clk(main_clk), .ps2_clk(ps2_clk), .ps2_data(ps2_data),
        .scan_code(raw_scan), .got_code(got_code)
    );
    HackKeyMapper key_map (
        .clk(main_clk), .scan_code(raw_scan), .got_code(got_code),
        .hack_code(keyboard_out)
    );

// --- 4. UART Debug Logic ---
    // We send the high byte of the PC then the low byte whenever PC changes.
    logic [14:0] prev_pc;
    logic uart_start;
    logic [7:0] uart_byte;
    logic uart_ready;

    uart_tx debug_uart (
        .clk(main_clk),
        .data(uart_byte),
        .start(uart_start),
        .tx(uart_txd_out),
        .ready(uart_ready)
    );

    // Simple state machine to send the 15-bit PC as two bytes
    typedef enum {WAIT, SEND_HI, SEND_LO} debug_state_t;
    debug_state_t dbg_state = WAIT;

    always_ff @(posedge main_clk) begin
        uart_start <= 0;
        if (btn_reset) begin
            dbg_state <= WAIT;
            prev_pc <= 0;
        end else begin
            case (dbg_state)
                WAIT: begin
                    if (pc != prev_pc && uart_ready) begin
                        prev_pc <= pc;
                        uart_byte <= {1'b0, pc[14:8]}; // High 7 bits
                        uart_start <= 1;
                        dbg_state <= SEND_LO;
                    end
                end
                SEND_LO: begin
                    if (uart_ready) begin
                        uart_byte <= pc[7:0]; // Low 8 bits
                        uart_start <= 1;
                        dbg_state <= WAIT;
                    end
                end
            endcase
        end
    end


    // --- 5. VGA & Screen Logic ---
    logic [9:0] vga_x, vga_y;
    logic active_video;
    logic [12:0] vga_word_addr;
    logic [15:0] vga_data_word;

    // Shift coordinates to center 512x256 inside 640x480
    logic [9:0] adj_x, adj_y;
    assign adj_x = vga_x - 64;
    assign adj_y = vga_y - 112;

    // Address = (y * 32) + (x / 16)
    assign vga_word_addr = (adj_y[7:0] * 32) + adj_x[8:4];

    DualPortScreen screen_mem (
        .clk(main_clk),
        .addrA(addrM[12:0]), .dinA(outM), .weA(write_screen), .doutA(screen_out),
        .addrB(vga_word_addr), .doutB(vga_data_word)
    );

    VgaSyncGen vga_sync (
        .pixel_clk(main_clk), .hsync(hsync), .vsync(vsync),
        .active_video(active_video), .x(vga_x), .y(vga_y)
    );

    // Pixel Bit Selection: Hack uses "Little Endian" bit order for screen pixels
    logic pixel_bit;
    assign pixel_bit = vga_data_word[adj_x[3:0]];

    always_comb begin
        if (active_video && adj_x < 512 && adj_y < 256) begin
            vga_r = pixel_bit ? 4'hF : 4'h0;
            vga_g = pixel_bit ? 4'hF : 4'h0;
            vga_b = pixel_bit ? 4'hF : 4'h0;
        end else begin
            vga_r = 4'h0; vga_g = 4'h0; vga_b = 4'h0;
        end
    end

endmodule
