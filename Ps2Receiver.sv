module Ps2Receiver (
    input  logic clk,           // System clock (25MHz)
    input  logic ps2_clk,       // From Pmod
    input  logic ps2_data,      // From Pmod
    output logic [7:0] scan_code,
    output logic got_code
);
    logic [3:0] bit_cnt = 0;
    logic [10:0] shift_reg = 0;
    logic [1:0] ps2_clk_sync;

    // Synchronize ps2_clk to system clock to avoid metastability
    always_ff @(posedge clk) ps2_clk_sync <= {ps2_clk_sync[0], ps2_clk};

    // Detect falling edge of ps2_clk
    logic falling_edge;
    assign falling_edge = (ps2_clk_sync == 2'b10);

    always_ff @(posedge clk) begin
        got_code <= 0;
        if (falling_edge) begin
            shift_reg <= {ps2_data, shift_reg[10:1]};
            if (bit_cnt == 10) begin
                bit_cnt <= 0;
                // Basic parity/stop bit check can be added here
                scan_code <= shift_reg[8:1];
                got_code <= 1;
            end else begin
                bit_cnt <= bit_cnt + 1;
            end
        end
    end
endmodule
