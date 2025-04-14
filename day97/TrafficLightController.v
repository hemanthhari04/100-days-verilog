module traffic_light_controller (
    input clk,          // 1Hz clock for simplicity
    input rst,          // synchronous reset
    input ped_btn,      // pedestrian crossing button
    output reg car_red,
    output reg car_yellow,
    output reg car_green,
    output reg ped_walk
);

    typedef enum reg [1:0] {
        CARS_GREEN = 2'b00,
        CARS_YELLOW = 2'b01,
        CARS_RED_WALK = 2'b10
    } state_t;

    state_t state = CARS_GREEN;
    reg [3:0] timer = 0;         // 4-bit counter for timing (up to 15 seconds)
    reg ped_request = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= CARS_GREEN;
            timer <= 0;
            ped_request <= 0;
            car_red <= 0;
            car_yellow <= 0;
            car_green <= 1;
            ped_walk <= 0;
        end else begin
            // Latch pedestrian request
            if (ped_btn)
                ped_request <= 1;

            case (state)
                CARS_GREEN: begin
                    car_green <= 1;
                    car_yellow <= 0;
                    car_red <= 0;
                    ped_walk <= 0;

                    if (ped_request) begin
                        timer <= 0;
                        state <= CARS_YELLOW;
                    end
                end

                CARS_YELLOW: begin
                    car_green <= 0;
                    car_yellow <= 1;
                    if (timer < 3) begin // Yellow lasts 3 seconds
                        timer <= timer + 1;
                    end else begin
                        timer <= 0;
                        state <= CARS_RED_WALK;
                    end
                end

                CARS_RED_WALK: begin
                    car_yellow <= 0;
                    car_red <= 1;
                    ped_walk <= 1;
                    if (timer < 5) begin // Walk signal lasts 5 seconds
                        timer <= timer + 1;
                    end else begin
                        timer <= 0;
                        ped_request <= 0;
                        state <= CARS_GREEN;
                    end
                end
            endcase
        end
    end
endmodule
