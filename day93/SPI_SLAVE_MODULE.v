module spi_slave (
    input sclk,               // SPI clock from master
    input mosi,               // Master Out Slave In
    output reg miso,          // Master In Slave Out
    input ss,                 // Active-low slave select
    output reg [7:0] rx_data, // Received data
    input [7:0] tx_data       // Data to send to master
);

    reg [2:0] bit_cnt;
    reg [7:0] rx_shift, tx_shift;

    always @(posedge sclk or posedge ss) begin
        if (ss) begin
            bit_cnt <= 0;
            rx_shift <= 0;
            tx_shift <= tx_data;
        end else begin
            rx_shift <= {rx_shift[6:0], mosi};
            miso <= tx_shift[7];
            tx_shift <= {tx_shift[6:0], 1'b0};
            bit_cnt <= bit_cnt + 1;
            if (bit_cnt == 7)
                rx_data <= {rx_shift[6:0], mosi};
        end
    end
endmodule
