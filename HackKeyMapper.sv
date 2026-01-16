module HackKeyMapper (
    input  logic clk,
    input  logic [7:0] scan_code,
    input  logic got_code,
    output logic [15:0] hack_code
);
    logic is_break = 0;
    logic [15:0] current_key = 0;

    always_ff @(posedge clk) begin
        if (got_code) begin
            if (scan_code == 8'hF0) begin
                is_break <= 1; // Mark that next code is a release
            end else begin
                if (is_break) begin
                    current_key <= 16'b0; // Clear register when key is released
                    is_break <= 0;
                end else begin
                    case (scan_code)
                        // --- Characters (ASCII) ---
                        8'h1C: current_key <= 16'd65;  // A
                        8'h32: current_key <= 16'd66;  // B
                        8'h21: current_key <= 16'd67;  // C
                        8'h23: current_key <= 16'd68;  // D
                        8'h24: current_key <= 16'd69;  // E
                        8'h2B: current_key <= 16'd70;  // F
                        8'h34: current_key <= 16'd71;  // G
                        8'h33: current_key <= 16'd72;  // H
                        8'h43: current_key <= 16'd73;  // I
                        8'h3B: current_key <= 16'd74;  // J
                        8'h42: current_key <= 16'd75;  // K
                        8'h4B: current_key <= 16'd76;  // L
                        8'h3A: current_key <= 16'd77;  // M
                        8'h31: current_key <= 16'd78;  // N
                        8'h44: current_key <= 16'd79;  // O
                        8'h4D: current_key <= 16'd80;  // P
                        8'h15: current_key <= 16'd81;  // Q
                        8'h2D: current_key <= 16'd82;  // R
                        8'h1B: current_key <= 16'd83;  // S
                        8'h2C: current_key <= 16'd84;  // T
                        8'h3C: current_key <= 16'd85;  // U
                        8'h2A: current_key <= 16'd86;  // V
                        8'h1D: current_key <= 16'd87;  // W
                        8'h22: current_key <= 16'd88;  // X
                        8'h35: current_key <= 16'd89;  // Y
                        8'h1A: current_key <= 16'd90;  // Z

                        // --- Numbers ---
                        8'h45: current_key <= 16'd48;  // 0
                        8'h16: current_key <= 16'd49;  // 1
                        8'h1E: current_key <= 16'd50;  // 2
                        8'h26: current_key <= 16'd51;  // 3
                        8'h25: current_key <= 16'd52;  // 4
                        8'h2E: current_key <= 16'd53;  // 5
                        8'h36: current_key <= 16'd54;  // 6
                        8'h3D: current_key <= 16'd55;  // 7
                        8'h3E: current_key <= 16'd56;  // 8
                        8'h46: current_key <= 16'd57;  // 9

                        // --- Special Hack Keys ---
                        8'h5A: current_key <= 16'd128; // Enter
                        8'h66: current_key <= 16'd129; // Backspace
                        8'h6B: current_key <= 16'd130; // Left Arrow
                        8'h75: current_key <= 16'd131; // Up Arrow
                        8'h74: current_key <= 16'd132; // Right Arrow
                        8'h72: current_key <= 16'd133; // Down Arrow
                        8'h76: current_key <= 16'd140; // ESC
                        8'h29: current_key <= 16'd32;  // Space (Standard ASCII)

                        default: current_key <= 16'b0;
                    endcase
                end
            end
        end
    end

    assign hack_code = current_key;
endmodule
