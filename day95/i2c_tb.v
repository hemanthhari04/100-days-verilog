module can_tx (
    input clk,
    input rst,
    input start,
    output reg tx,
    output reg done
);

    reg [31:0] frame;
    reg [5:0] bit_cnt;
    reg sending;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1; // idle is recessive (1)
            bit_cnt <= 0;
            sending <= 0;
            done <= 0;
        end else begin
            if (start && !sending) begin
                // Example frame: SOF + 11-bit ID (0x123) + RTR + IDE + r0 + DLC + data
                frame <= {8'hAB, 11'b00100100011, 1'b0, 1'b0, 1'b0, 4'b1000, 8'h55}; 
                sending <= 1;
                bit_cnt <= 31;
                tx <= 0; // Start of Frame (dominant)
                done <= 0;
            end else if (sending) begin
                tx <= frame[bit_cnt];
                bit_cnt <= bit_cnt - 1;
                if (bit_cnt == 0) begin
                    sending <= 0;
                    tx <= 1;
                    done <= 1;
                end
            end
        end
    end
endmodule
