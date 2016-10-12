module music_streamer (
    input clk,
    input rst,
    input rotary_event,
    input rotary_left,
    input rotary_push,
    input button_center,
    input button_north,
    input button_east,
    input button_west,
    input button_south,
    output led_center,
    output led_north,
    output led_east,
    output led_west,
    output led_south,
    output [23:0] tone,
    output reg [7:0] GPIO_leds
);
    wire [23:0] rom_tone_out;
    assign tone = rom_tone_out;

    localparam PAUSED = 3'd0;
    localparam REGULAR_PLAY = 3'd1;
    localparam REVERSE_PLAY = 3'd2;
    localparam PLAY_SEQ = 3'd3;
    localparam EDIT_SEQ = 3'd4;
    reg [2:0] current_state;
    reg [2:0] next_state;

    assign led_center = current_state == PAUSED;
    assign led_north = current_state == REGULAR_PLAY;
    assign led_south = current_state == REVERSE_PLAY;
    assign led_west = current_state == EDIT_SEQ;
    assign led_east = current_state == PLAY_SEQ;

    reg [11:0] tone_index = 0;
    reg [22:0] clock_counter = 0;
    reg [22:0] tempo = 23'd1320000;
    reg [22:0] tempo_seq = 23'd6600000;
    wire [11:0] last_address;
    
    reg [23:0] sequencer_mem [7:0];
    reg [2:0] sequencer_addr;
    reg [23:0] tone_under_edit;

    rom music_data (
        .address(tone_index),       // 12 bits
        .data(rom_tone_out),        // 24 bits
        .last_address(last_address) // 12 bits
    );

    // Assignments to the LEDs
    always @ (*) begin
        GPIO_leds = 8'd0;
        case (current_state)
            REGULAR_PLAY, REVERSE_PLAY, PAUSED: begin
                GPIO_leds = tone_index[11:4];
            end
            PLAY_SEQ, EDIT_SEQ: begin
                GPIO_leds[0] = sequencer_addr == 3'd0;
                GPIO_leds[1] = sequencer_addr == 3'd1;
                GPIO_leds[2] = sequencer_addr == 3'd2;
                GPIO_leds[3] = sequencer_addr == 3'd3;
                GPIO_leds[4] = sequencer_addr == 3'd4;
                GPIO_leds[5] = sequencer_addr == 3'd5;
                GPIO_leds[6] = sequencer_addr == 3'd6;
                GPIO_leds[7] = sequencer_addr == 3'd7;
            end
        endcase
    end

endmodule
