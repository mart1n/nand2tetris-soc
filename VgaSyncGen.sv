module VgaSyncGen (
    input  logic pixel_clk,
    output logic hsync, vsync,
    output logic active_video,
    output logic [9:0] x,
    output logic [9:0] y
);
    // 640x480 @ 60Hz timing constants
    localparam H_VISIBLE = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48, H_TOTAL = 800;
    localparam V_VISIBLE = 480, V_FRONT = 10, V_SYNC = 2, V_BACK = 33, V_TOTAL = 525;

    logic [9:0] h_cnt = 0, v_cnt = 0;

    always_ff @(posedge pixel_clk) begin
        if (h_cnt == H_TOTAL - 1) begin
            h_cnt <= 0;
            if (v_cnt == V_TOTAL - 1) v_cnt <= 0;
            else v_cnt <= v_cnt + 1;
        end else h_cnt <= h_cnt + 1;
    end

    assign hsync = ~(h_cnt >= (H_VISIBLE + H_FRONT) && h_cnt < (H_VISIBLE + H_FRONT + H_SYNC));
    assign vsync = ~(v_cnt >= (V_VISIBLE + V_FRONT) && v_cnt < (V_VISIBLE + V_FRONT + V_SYNC));
    assign active_video = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);
    assign x = h_cnt;
    assign y = v_cnt;
endmodule
