module clock_divider #(parameter DIV = 50000000) (
    input clk,
    output reg slow_clk = 0
);
    reg [31:0] count = 0;

    always @(posedge clk) begin
        if (count == DIV/2) begin
            slow_clk <= ~slow_clk;
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end
endmodule
module snake_game (
    input clk,
    input rst,
    input btn_up, btn_down, btn_left, btn_right,
    output reg [7:0] row,  // row select (active low)
    output reg [7:0] col   // column data
);
    typedef enum reg [1:0] {UP = 2'b00, DOWN = 2'b01, LEFT = 2'b10, RIGHT = 2'b11} dir_t;
    dir_t direction = RIGHT;

    reg [2:0] snake_x[0:15];
    reg [2:0] snake_y[0:15];
    reg [4:0] length = 3;
    reg [3:0] i;
    reg [2:0] frame_row = 0;

    wire game_clk;
    clock_divider #(25000000) clkdiv(.clk(clk), .slow_clk(game_clk)); // ~2Hz

    // direction control
    always @(posedge clk) begin
        if (btn_up)    direction <= UP;
        else if (btn_down)  direction <= DOWN;
        else if (btn_left)  direction <= LEFT;
        else if (btn_right) direction <= RIGHT;
    end

    // snake movement
    always @(posedge game_clk or posedge rst) begin
        if (rst) begin
            snake_x[0] <= 4; snake_y[0] <= 4;
            snake_x[1] <= 3; snake_y[1] <= 4;
            snake_x[2] <= 2; snake_y[2] <= 4;
            length <= 3;
            direction <= RIGHT;
        end else begin
            for (i = length-1; i > 0; i = i - 1) begin
                snake_x[i] <= snake_x[i-1];
                snake_y[i] <= snake_y[i-1];
            end
            case (direction)
                UP:    snake_y[0] <= snake_y[0] - 1;
                DOWN:  snake_y[0] <= snake_y[0] + 1;
                LEFT:  snake_x[0] <= snake_x[0] - 1;
                RIGHT: snake_x[0] <= snake_x[0] + 1;
            endcase
        end
    end

    // matrix display scan
    always @(posedge clk) begin
        frame_row <= frame_row + 1;
        row <= ~(1 << frame_row); // active low row select
        col <= 8'b00000000;

        for (i = 0; i < length; i = i + 1) begin
            if (snake_y[i] == frame_row)
                col[snake_x[i]] <= 1;
        end
    end
endmodule
module snake_top (
    input clk,
    input rst,
    input btn_up, btn_down, btn_left, btn_right,
    output [7:0] row,
    output [7:0] col
);
    snake_game snake(
        .clk(clk),
        .rst(rst),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .row(row),
        .col(col)
    );
endmodule
