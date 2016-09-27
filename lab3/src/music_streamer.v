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
    output [11:0] rom_address
);
    // Remove these assignments when creating the FSM
    assign led_center = 1'b1;
    assign led_north = 1'b0;
    assign led_east = 1'b0;
    assign led_west = 1'b0;
    assign led_south = 1'b0;

    reg [11:0] tone_index = 0;      // ROM address
    reg [22:0] clock_counter = 0;   // Clock counter
    wire [11:0] last_address;       // Last address output from ROM
    assign rom_address = tone_index;

    rom music_data (
        .address(tone_index),       // 12 bits
        .data(tone),                // 24 bits
        .last_address(last_address) // 12 bits
    );

    // Copy your lab 2 music streamer here

endmodule
