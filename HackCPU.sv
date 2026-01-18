module HackCPU (
    input  logic [15:0] inM,          // M value input (contents of RAM[A])
    input  logic [15:0] instruction,  // Instruction for execution
    input  logic        reset,        // Signals whether to re-start the current program
    output logic [15:0] outM,         // M value output
    output logic        writeM,       // Write to M?
    output logic [14:0] addressM,     // Address in data memory (of M)
    output logic [14:0] pc,           // Address of next instruction
    input  logic        clk           // Clock signal
);

    // Internal Registers
    logic [15:0] regA;
    logic [15:0] regD;
    logic [15:0] pcReg;

    // --- Instruction Decoding ---
    // bit 15: 0 = A-instruction, 1 = C-instruction
    logic isAInst, isCInst;
    assign isAInst = !instruction[15];
    assign isCInst = instruction[15];

    // --- ALU Input Selection ---
    // The 'a' bit (instruction[12]) selects between A-register and Memory input
    logic [15:0] aluInY;
    assign aluInY = (instruction[12]) ? inM : regA;

    // ALU Output and Flags
    logic [15:0] aluOut;
    logic zr, ng;

    // --- ALU Instantiation ---
    HackALU alu (
        .x  (regD),             // ALU X is always from D-register
        .y  (aluInY),            // ALU Y is A or M
        .zx (instruction[11]),   // Mapping control bits directly
        .nx (instruction[10]),
        .zy (instruction[9]),
        .ny (instruction[8]),
        .f  (instruction[7]),
        .no (instruction[6]),
        .out(aluOut),
        .zr (zr),
        .ng (ng)
    );

    // --- Register Load Logic ---
    // Load A if it's an A-instruction OR if C-instruction dest bit d1 is set
    logic loadA;
    assign loadA = isAInst || (isCInst && instruction[5]);

    // Load D if it's a C-instruction and dest bit d2 is set
    logic loadD;
    assign loadD = isCInst && instruction[4];

    // Write to Memory if it's a C-instruction and dest bit d3 is set
    assign writeM = isCInst && instruction[3];

    // --- Sequential Logic (Clocked) ---
    always_ff @(posedge clk) begin
        if (reset) begin
            regA  <= 16'b0;
            regD  <= 16'b0;
            pcReg <= 16'b0;
        end else begin
            // A Register: Stores instruction literal or ALU output
            if (loadA)
                regA <= isAInst ? instruction : aluOut;

            // D Register: Stores ALU output
            if (loadD)
                regD <= aluOut;

            // Program Counter Logic
            if (jump)
                pcReg <= regA;
            else
                pcReg <= pcReg + 1;
        end
    end

    // --- Jump Logic ---
    logic jump;
    always_comb begin
        // Jump bits: j1 (out < 0), j2 (out = 0), j3 (out > 0)
        logic out_lt_0, out_eq_0, out_gt_0;
        out_lt_0 = ng;
        out_eq_0 = zr;
        out_gt_0 = !ng && !zr;

        if (isCInst) begin
            jump = (instruction[2] && out_lt_0) ||
                   (instruction[1] && out_eq_0) ||
                   (instruction[0] && out_gt_0);
        end else begin
            jump = 1'b0;
        end
    end

    // --- Output Assignments ---
    assign outM     = aluOut;
    assign addressM = regA[14:0];
    assign pc       = pcReg[14:0];

endmodule
