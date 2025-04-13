module i2c_master (
    input clk,           // System clock
    input rst,           // Reset
    input start,         // Trigger I2C transmission
    input [6:0] addr,    // 7-bit slave address
    input [7:0] data,    // 8-bit data to send
    output reg scl,      // I2C clock line
    inout sda,           // I2C data line (bidirectional)
    output reg done      // Indicates transfer done
);

    reg [3:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg sda_out, sda_oe;

    assign sda = sda_oe ? sda_out : 1'bz;

    localparam IDLE  = 4'd0,
               START = 4'd1,
               ADDR  = 4'd2,
               ACK1  = 4'd3,
               DATA  = 4'd4,
               ACK2  = 4'd5,
               STOP  = 4'd6,
               DONE  = 4'd7;

    reg [7:0] clk_div;
    wire tick = (clk_div == 8'd100); // Adjust for slower SCL

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div <= 0; scl <= 1;
            state <= IDLE; done <= 0;
            sda_out <= 1; sda_oe <= 1;
        end else begin
            clk_div <= clk_div + 1;
            if (!tick) return;

            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        sda_out <= 0; sda_oe <= 1;
                        state <= START;
                    end
                end

                START: begin
                    scl <= 0;
                    shift_reg <= {addr, 1'b0}; // write = 0
                    bit_cnt <= 7;
                    state <= ADDR;
                end

                ADDR: begin
                    sda_out <= shift_reg[7];
                    shift_reg <= {shift_reg[6:0], 1'b0};
                    scl <= 1; state <= ACK1;
                end

                ACK1: begin
                    scl <= 0; bit_cnt <= bit_cnt - 1;
                    if (bit_cnt == 0) begin
                        sda_oe <= 0; state <= DATA;
                        shift_reg <= data; bit_cnt <= 7;
                    end else state <= ADDR;
                end

                DATA: begin
                    sda_oe <= 1;
                    sda_out <= shift_reg[7];
                    shift_reg <= {shift_reg[6:0], 1'b0};
                    scl <= 1; state <= ACK2;
                end

                ACK2: begin
                    scl <= 0; bit_cnt <= bit_cnt - 1;
                    if (bit_cnt == 0) begin
                        sda_oe <= 0; state <= STOP;
                    end else state <= DATA;
                end

                STOP: begin
                    sda_oe <= 1;
                    sda_out <= 0; scl <= 1;
                    sda_out <= 1; state <= DONE;
                end

                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
