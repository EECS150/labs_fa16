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
    // FSM localparams and state elements
    localparam PAUSED = 3'd0;
    localparam REGULAR_PLAY = 3'd1;
    localparam REVERSE_PLAY = 3'd2;
    localparam PLAY_SEQ = 3'd3;
    localparam EDIT_SEQ = 3'd4;
    reg [2:0] current_state;
    reg [2:0] next_state;
    reg [22:0] clock_counter = 0;

    // Compass LED assignments
    assign led_center = current_state == PAUSED;
    assign led_north = current_state == REGULAR_PLAY;
    assign led_south = current_state == REVERSE_PLAY;
    assign led_west = current_state == EDIT_SEQ;
    assign led_east = current_state == PLAY_SEQ;

    // ROM addressing and data state elements
    reg [11:0] rom_address = 0;
    wire [23:0] rom_tone_out;
    wire [11:0] last_address;
    assign tone = rom_tone_out;

    rom music_data (
        .address(rom_address),      // 12 bits
        .data(rom_tone_out),        // 24 bits
        .last_address(last_address) // 12 bits
    );

    // Sequencer state elements

    // The RAM for the sequencer
    reg [23:0] sequencer_mem [7:0];
    // The address for the sequencer RAM (shared among PLAY_SEQ and EDIT_SEQ states)
    reg [2:0] sequencer_addr;
    // Holds the tone being edited in the EDIT_SEQ state
    reg [23:0] tone_under_edit;

    // Assignments to the LEDs
    always @ (*) begin
        GPIO_leds = 8'd0;
        case (current_state)
            REGULAR_PLAY, REVERSE_PLAY, PAUSED: begin
                GPIO_leds = rom_address[11:4];
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

    // The following skeleton code should help you get started with the sequencer implementation

    // Update or initialization of the sequencer RAM
    always @ (posedge clk) begin
        if (rst) begin  // Reset the 8 notes to 440 Hz
            sequencer_mem[0] <= 24'd37500;
            sequencer_mem[1] <= 24'd37500;
            sequencer_mem[2] <= 24'd37500;
            sequencer_mem[3] <= 24'd37500;
            sequencer_mem[4] <= 24'd37500;
            sequencer_mem[5] <= 24'd37500;
            sequencer_mem[6] <= 24'd37500;
            sequencer_mem[7] <= 24'd37500;
        end
        else if (current_state == EDIT_SEQ && rotary_push) begin
            // We are in edit mode and the rotary button has been pushed, so save the tone in the RAM
            sequencer_mem[sequencer_addr] <= tone_under_edit;
        end
        else begin
            // Else don't change anything in the RAM (this line isn't really needed)
            sequencer_mem[sequencer_addr] <= sequencer_mem[sequencer_addr];
        end
    end

    // Advancement of the sequencer_addr for the sequencer
    always @ (posedge clk) begin
        sequencer_addr <= sequencer_addr;        
        if (rst) begin
            sequencer_addr <= 0;
        end
        else begin
            if (current_state == PLAY_SEQ) begin
                // Update sequencer_addr if the clock_counter hits the sequencer tempo
            end
            else if (current_state == EDIT_SEQ) begin
                if (button_east) begin
                    // Update sequencer_addr if we press the east button in edit mode
                end
                else if (button_west) begin
                    // if we press the west button in edit mode
                end
            end
        end
    end

    // Registering and modification of the tone_under_edit
    always @ (posedge clk) begin
        tone_under_edit <= tone_under_edit;

        // If we are moving into edit mode from the play mode, register the note in the RAM in the tone_under_edit reg
        if (next_state == EDIT_SEQ && current_state == PLAY_SEQ) begin
            tone_under_edit <= sequencer_mem[sequencer_addr];
        end
        // We are currently in edit mode, if we switch notes or edit the current note, we should update the tone_under_edit
        else if (current_state == EDIT_SEQ) begin
            if (button_east) tone_under_edit <= sequencer_mem[sequencer_addr + 3'd1];
            else if (button_west) tone_under_edit <= sequencer_mem[sequencer_addr - 3'd1];
            else if (rotary_event && rotary_left) begin
                // Update tone_under_edit's pitch
            end
            else if (rotary_event && !rotary_left) begin
                // Update tone_under_edit's pitch
            end
            else tone_under_edit <= tone_under_edit;
        end
    end
endmodule
