`timescale 1ns/1ps

module i2c_tb;

    reg clk, rst, start;
    reg [6:0] addr;
    reg [7:0] data;
    wire scl;
    wire sda;
    wire done;

    // SDA pullup simulation
    tri1 sda_pullup;
    assign sda_pullup = sda; // Simulates pull-up resistor on SDA

    // Instantiate I2C Master
    i2c_master uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .addr(addr),
        .data(data),
        .scl(scl),
        .sda(sda_pullup),
        .done(done)
    );

    // Clock generation (50 MHz)
    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("i2c.vcd");
        $dumpvars(0, i2c_tb);

        rst = 1;
        start = 0;
        addr = 7'h50;
        data = 8'h55;

        #50 rst = 0;

        #100;
        start = 1;
        #20;
        start = 0;

        wait(done);
        $display("I2C write done!");

        #100;
        $finish;
    end

endmodule
