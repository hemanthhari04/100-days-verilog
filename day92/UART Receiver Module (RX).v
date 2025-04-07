module uart_rx (
    input clk,
    input rst,
    input rx,              // UART RX line
    output reg [7:0] data_out, // Received data
    output reg done        // Indicates reception complete
);

    parameter CLK_FREQ = 50000000;  // 50 MHz
    parameter BAUD_RATE = 9600;
    localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;
    localparam HALF_TICK = BAUD_TICK / 2;

    reg [15:0] baud_cnt;
    reg [3:0] bit_cnt;
    reg [7:0] rx_shift;
    reg receiving;
    reg rx_sync;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_cnt <= 0;
            bit_cnt <= 0;
            rx_shift <= 0;
            receiving <= 0;
            done <= 0;
            data_out <= 0;
        end else begin
            done <= 0;
            rx_sync <= rx;

            if (!receiving) begin
                if (!rx_sync) begin // Start bit detected
                    receiving <= 1;
                    baud_cnt <= HALF_TICK;
                    bit_cnt <= 0;
                end
            end else begin
                if (baud_cnt < BAUD_TICK - 1)
                    baud_cnt <= baud_cnt + 1;
                else begin
                    baud_cnt <= 0;
                    if (bit_cnt < 8) begin
                        rx_shift <= {rx_sync, rx_shift[7:1]};
                        bit_cnt <= bit_cnt + 1;
                    end else begin
                        data_out <= {rx_sync, rx_shift[7:1]};
                        done <= 1;
                        receiving <= 0;
                    end
                end
            end
        end
    end
endmodule
