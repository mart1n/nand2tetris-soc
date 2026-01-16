module DualPortScreen (
    input  logic clk,
    // Port A (CPU)
    input  logic [12:0] addrA, // 8K words (16-bit) = 512x256 pixels
    input  logic [15:0] dinA,
    input  logic        weA,
    output logic [15:0] doutA,
    // Port B (VGA)
    input  logic [12:0] addrB,
    output logic [15:0] doutB
);
    // 8192 x 16-bit memory (Exactly 512x256 pixels)
    (* ram_style = "block" *) logic [15:0] mem [0:8191];

    always_ff @(posedge clk) begin
        if (weA) mem[addrA] <= dinA;
        doutA <= mem[addrA];
    end

    always_ff @(posedge clk) begin
        doutB <= mem[addrB];
    end
endmodule
