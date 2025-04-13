`timescale 1ns/1ps

module can_tb;

    reg clk = 0, rst = 1, start = 0;
    wire tx;
    wire [10:0] id;
    wire [7:0] data;
    wire valid;
    wire done;

    always #10 clk = ~clk;

    // Transmitter instance
    can_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx(tx),
        .done(done)
    );

    // Receiver instance
    can_rx rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx), // Connect TX to RX for loopback
        .id(id),
        .data(data),
        .valid(valid)
    );

    initial begin
        $dumpfile("can.vcd");
        $dumpvars(0, can_tb);

        #50 rst = 0;

        #100;
        start = 1;
        #20;
        start = 0;

        wait(done);
        wait(valid);

        $display("CAN Frame Received -> ID: %h, Data: %h", id, data);

        #100;
        $finish;
    end

endmodule
