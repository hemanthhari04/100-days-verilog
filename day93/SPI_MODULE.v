module spi_master (
    input clk,                // System clock
    input rst,                // Reset
    input [7:0] mosi_data,    // Data to send to slave
    input start,              // Start transfer
    output reg sclk,          // SPI clock
    output reg mosi,          // Master Out Slave In
    input miso,               // Master In Slave Out
    output reg [7:0] miso_data, // Data received from slave
    output reg busy,          // Transfer in progress
    output reg done           // Transfer complete
);

    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    localparam CLK_DIV = 4;  // Adjust to control SCLK speed
    reg [1:0] clk_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sclk <= 0;
            mosi <= 0;
            miso_data <= 0;
            busy <= 0;
            done <= 0;
            shift_reg <= 0;
            bit_cnt <= 0;
            clk_cnt <= 0;
        end else begin
            done <= 0;

            if (start && !busy) begin
                busy <= 1;
                shift_reg <= mosi_data;
                bit_cnt <= 0;
                clk_cnt <= 0;
                sclk <= 0;
            end else if (busy) begin
                clk_cnt <= clk_cnt + 1;

                if (clk_cnt == (CLK_DIV - 1)) begin
                    clk_cnt <= 0;
                    sclk <= ~sclk;

                    if (sclk == 0) begin
                        mosi <= shift_reg[7]; // Send MSB first
                    end else begin
                        shift_reg <= {shift_reg[6:0], miso}; // Shift in data
                        bit_cnt <= bit_cnt + 1;

                        if (bit_cnt == 7) begin
                            busy <= 0;
                            done <= 1;
                            miso_data <= {shift_reg[6:0], miso};
                        end
                    end
                end
            end
        end
    end
endmodule
