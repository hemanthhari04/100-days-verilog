module digital_lock (
    input clk,
    input rst,
    output [3:0] row,        // row outputs to keypad
    input [3:0] col,         // column inputs from keypad
    output reg unlocked_led  // LED on unlock
);
module keypad_scanner (
    input clk,
    input rst,
    output reg [3:0] row,
    input [3:0] col,
    output reg [3:0] key,
    output reg key_valid
);
    reg [1:0] scan_row = 0;
    reg [19:0] debounce = 0;
    
    always @(posedge clk) begin
        if (debounce < 100_000)
            debounce <= debounce + 1;
        else begin
            debounce <= 0;
            scan_row <= scan_row + 1;
        end
    end

    always @(*) begin
        row = 4'b1111;
        row[scan_row] = 0; // active-low row select
    end

    always @(posedge clk) begin
        key_valid <= 0;
        case (col)
            4'b1110: key <= {scan_row, 2'd0}; // col 0
            4'b1101: key <= {scan_row, 2'd1}; // col 1
            4'b1011: key <= {scan_row, 2'd2}; // col 2
            4'b0111: key <= {scan_row, 2'd3}; // col 3
            default: key <= 4'd15; // no key
        endcase
        if (col != 4'b1111)
            key_valid <= 1;
    end
endmodule
module lock_controller (
    input clk,
    input rst,
    input [3:0] key,
    input key_valid,
    output reg unlocked
);
    reg [1:0] count = 0;
    reg [3:0] code[3:0];   // store 4 digits
    reg [3:0] password[3:0];

    initial begin
        password[0] = 4'd1;
        password[1] = 4'd2;
        password[2] = 4'd3;
        password[3] = 4'd4;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            unlocked <= 0;
        end else if (key_valid) begin
            code[count] <= key;
            count <= count + 1;
            if (count == 3) begin
                if (code[0] == password[0] &&
                    code[1] == password[1] &&
                    code[2] == password[2] &&
                    key == password[3]) begin
                    unlocked <= 1;
                end else begin
                    unlocked <= 0;
                end
                count <= 0;
            end
        end
    end
endmodule
module digital_lock (
    input clk,
    input rst,
    output [3:0] row,
    input [3:0] col,
    output unlocked_led
);
    wire [3:0] key;
    wire key_valid;
    wire unlocked;

    keypad_scanner scanner (
        .clk(clk),
        .rst(rst),
        .row(row),
        .col(col),
        .key(key),
        .key_valid(key_valid)
    );

    lock_controller controller (
        .clk(clk),
        .rst(rst),
        .key(key),
        .key_valid(key_valid),
        .unlocked(unlocked)
    );

    assign unlocked_led = unlocked;
endmodule
