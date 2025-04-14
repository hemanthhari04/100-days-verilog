module pwm_led_controller (
    input clk,         // 50 MHz clock (or adjust as needed)
    input rst,         // reset
    output reg led_pwm // connect to LED pin
);
    reg [7:0] duty = 0;        // brightness level (0-255)
    reg [7:0] counter = 0;     // PWM counter
    reg [23:0] fade_counter = 0;
    reg direction = 0;         // 0 = up, 1 = down

    // PWM logic: sets led_pwm HIGH for 'duty' counts out of 256
    always @(posedge clk) begin
        counter <= counter + 1;
        led_pwm <= (counter < duty);
    end

    // Auto fade in and out
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            duty <= 0;
            fade_counter <= 0;
            direction <= 0;
        end else begin
            // Slow down fading using another counter
            fade_counter <= fade_counter + 1;
            if (fade_counter == 50000) begin // adjust fade speed here
                fade_counter <= 0;
                if (direction == 0) begin
                    if (duty < 255)
                        duty <= duty + 1;
                    else
                        direction <= 1;
                end else begin
                    if (duty > 0)
                        duty <= duty - 1;
                    else
                        direction <= 0;
                end
            end
        end
    end
endmodule
