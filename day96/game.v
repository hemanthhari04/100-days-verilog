module reaction_time_tester (
    input clk,              // 50 MHz clock
    input rst,              // active high reset
    input btn,              // button input
    output reg led,         // GO signal LED
    output reg [7:0] reaction_time  // reaction time (in ms units approx.)
);

    // States
    typedef enum reg [1:0] {
        IDLE = 2'b00,
        WAIT_RANDOM = 2'b01,
        WAIT_REACTION = 2'b10,
        SHOW_RESULT = 2'b11
    } state_t;

    state_t state = IDLE;

    reg [25:0] delay_counter = 0;       // ~1s max at 50 MHz
    reg [25:0] reaction_counter = 0;
    reg [25:0] random_delay = 26'd20000000; // ~0.4 sec (can vary this)
    reg btn_prev;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            delay_counter <= 0;
            reaction_counter <= 0;
            reaction_time <= 0;
            led <= 0;
            btn_prev <= 0;
        end else begin
            btn_prev <= btn;

            case (state)
                IDLE: begin
                    led <= 0;
                    reaction_time <= 0;
                    if (btn && !btn_prev) begin
                        delay_counter <= 0;
                        random_delay <= 26'd30000000; // you could randomize this in sim
                        state <= WAIT_RANDOM;
                    end
                end

                WAIT_RANDOM: begin
                    if (delay_counter < random_delay) begin
                        delay_counter <= delay_counter + 1;
                    end else begin
                        led <= 1; // Show the "GO!" LED
                        reaction_counter <= 0;
                        state <= WAIT_REACTION;
                    end
                end

                WAIT_REACTION: begin
                    if (!btn && btn_prev) begin // button released (can also use press)
                        reaction_time <= reaction_counter[25:18]; // approx ms
                        state <= SHOW_RESULT;
                    end else begin
                        reaction_counter <= reaction_counter + 1;
                    end
                end

                SHOW_RESULT: begin
                    // stays here showing result until reset
                    led <= 0;
                end
            endcase
        end
    end
endmodule
