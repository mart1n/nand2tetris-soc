module uart_tx (
    input  logic clk,        // 25MHz clock
    input  logic [7:0] data, // Byte to send
    input  logic start,      // Pulse to start transmission
    output logic tx,         // UART TX line
    output logic ready       // High if ready for next byte
);
    // Calculation: 25,000,000 / 115,200 ≈ 217 clocks per bit
    localparam CLKS_PER_BIT = 217;

    typedef enum {IDLE, START, DATA, STOP} state_t;
    state_t state = IDLE;

    logic [7:0] shift_reg;
    logic [7:0] bit_idx;
    logic [15:0] clk_cnt;

    assign ready = (state == IDLE);

    always_ff @(posedge clk) begin
        case (state)
            IDLE: begin
                tx <= 1'b1;
                clk_cnt <= 0;
                if (start) begin
                    shift_reg <= data;
                    state <= START;
                end
            end
            START: begin
                tx <= 1'b0; // Start bit
                if (clk_cnt < CLKS_PER_BIT - 1) clk_cnt <= clk_cnt + 1;
                else begin
                    clk_cnt <= 0;
                    state <= DATA;
                    bit_idx <= 0;
                end
            end
            DATA: begin
                tx <= shift_reg[bit_idx];
                if (clk_cnt < CLKS_PER_BIT - 1) clk_cnt <= clk_cnt + 1;
                else begin
                    clk_cnt <= 0;
                    if (bit_idx < 7) bit_idx <= bit_idx + 1;
                    else state <= STOP;
                end
            end
            STOP: begin
                tx <= 1'b1; // Stop bit
                if (clk_cnt < CLKS_PER_BIT - 1) clk_cnt <= clk_cnt + 1;
                else state <= IDLE;
            end
        endcase
    end
endmodule
