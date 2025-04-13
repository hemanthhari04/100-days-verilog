module can_rx (
    input clk,
    input rst,
    input rx,
    output reg [10:0] id,
    output reg [7:0] data,
    output reg valid
);

    reg [5:0] bit_cnt;
    reg [31:0] shift_reg;
    reg receiving;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bit_cnt <= 0;
            receiving <= 0;
            valid <= 0;
        end else begin
            if (!receiving && rx == 0) begin // Start of frame
                receiving <= 1;
                bit_cnt <= 31;
                valid <= 0;
            end else if (receiving) begin
                shift_reg[bit_cnt] <= rx;
                bit_cnt <= bit_cnt - 1;
                if (bit_cnt == 0) begin
                    receiving <= 0;
                    id <= shift_reg[30:20];
                    data <= shift_reg[7:0];
                    valid <= 1;
                end
            end
        end
    end
endmodule
