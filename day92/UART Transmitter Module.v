module uart_tx (
    input clk,            // System Clock
    input rst,            // Reset
    input [7:0] data_in,  // Data to transmit
    input send,           // Trigger to start transmission
    output reg tx,        // UART TX line
    output reg busy       // Indicates transmission in progress
);

    parameter CLK_FREQ = 50000000;  // 50 MHz
    parameter BAUD_RATE = 9600;
    localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_cnt;
    reg [3:0] bit_cnt;
    reg [9:0] tx_shift;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_cnt <= 0;
            bit_cnt <= 0;
            tx_shift <= 10'b1111111111;
            tx <= 1;
            busy <= 0;
        end else begin
            if (send && !busy) begin
                // Load start bit, data, and stop bit
                tx_shift <= {1'b1, data_in, 1'b0};  // {Stop, Data[7:0], Start}
                busy <= 1;
                bit_cnt <= 0;
                baud_cnt <= 0;
            end else if (busy) begin
                if (baud_cnt < BAUD_TICK - 1)
                    baud_cnt <= baud_cnt + 1;
                else begin
                    baud_cnt <= 0;
                    tx <= tx_shift[0];
                    tx_shift <= {1'b1, tx_shift[9:1]};
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 9) begin
                        busy <= 0;
                        tx <= 1; // Idle state
                    end
                end
            end
        end
    end
endmodule
