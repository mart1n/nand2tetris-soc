module HackALU (
    input  logic [15:0] x, y,       // 16-bit inputs
    input  logic        zx, nx,     // x control bits (zero, negate)
    input  logic        zy, ny,     // y control bits (zero, negate)
    input  logic        f,          // function bit (1 for add, 0 for and)
    input  logic        no,         // output negate bit
    output logic [15:0] out,        // 16-bit output
    output logic        zr,         // zero flag (1 if out == 0)
    output logic        ng          // negative flag (1 if out < 0)
);

    logic [15:0] x_z, x_n;
    logic [15:0] y_z, y_n;
    logic [15:0] f_out;
    logic [15:0] final_out;

    always_comb begin
        // --- X Input Logic ---
        // zx: zero the x input
        x_z = zx ? 16'b0 : x;
        // nx: bitwise negate the x input
        x_n = nx ? ~x_z : x_z;

        // --- Y Input Logic ---
        // zy: zero the y input
        y_z = zy ? 16'b0 : y;
        // ny: bitwise negate the y input
        y_n = ny ? ~y_z : y_z;

        // --- Function Logic ---
        // f: 1 for addition, 0 for bitwise AND
        if (f)
            f_out = x_n + y_n;
        else
            f_out = x_n & y_n;

        // --- Output Logic ---
        // no: bitwise negate the output
        final_out = no ? ~f_out : f_out;

        out = final_out;

        // --- Status Flags ---
        // zr: True if out is zero
        zr = (final_out == 16'b0);
        // ng: True if out is negative (Most Significant Bit is 1)
        ng = final_out[15];
    end

endmodule
