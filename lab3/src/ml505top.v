module ml505top (
    input CLK_33MHZ_FPGA,       // 33 Mhz Clock Signal Input
    input [7:0] GPIO_DIP,       // 8 GPIO DIP Switches
    input FPGA_ROTARY_INCA,     // Rotary Encoder Wheel A Signal
    input FPGA_ROTARY_INCB,     // Rotary Encoder Wheel B Signal
    input FPGA_ROTARY_PUSH,     // Rotary Encoder Push Button Signal (Active-high)
    input GPIO_SW_C,            // Compass Center User Pushbutton (Active-high)
    input GPIO_SW_N,            // Compass North User Pushbutton (Active-high)
    input GPIO_SW_E,            // Compass East User Pushbutton (Active-high)
    input GPIO_SW_W,            // Compass West User Pushbutton (Active-high)
    input GPIO_SW_S,            // Compass South User Pushbutton (Active-high)
    input FPGA_CPU_RESET_B,     // CPU_RESET Pushbutton (Active-LOW), signal should be interpreted as logic high when 0

    output PIEZO_SPEAKER,       // Piezo Speaker Output Line (buffered off-FPGA, drives piezo)
    output [7:0] GPIO_LED,      // 8 GPIO LEDs
    output GPIO_LED_C,          // Compass Center LED
    output GPIO_LED_N,          // Compass North LED
    output GPIO_LED_E,          // Compass East LED
    output GPIO_LED_W,          // Compass West LED
    output GPIO_LED_S           // Compass South LED
);
    wire [23:0] tone_to_play;
    wire [11:0] rom_address;

    assign GPIO_LED[7:0] = rom_address[11:4];

    // Synchronized versions of the input buttons and rotary encoder wheel signals
    wire rotary_inca_sync, rotary_incb_sync, rotary_push_sync, 
        button_c_sync, button_n_sync, button_e_sync, button_w_sync, button_s_sync, reset_sync;

    // Debounced versions of the input buttons (already synchronized)
    wire rotary_push_deb, button_c_deb_, button_n_deb, button_e_deb, button_w_deb, button_s_deb, reset_deb;

    // Signals from your rotary decoder
    wire rotary_event, rotary_left;

    // We first pass each one of our asynchronous FPGA inputs through a 1-bit synchronizer
    synchronizer #(
        .width(9)
    ) input_synchronizer (
        .clk(CLK_33MHZ_FPGA),
        .async_signal({
            FPGA_ROTARY_INCA, 
            FPGA_ROTARY_INCB, 
            FPGA_ROTARY_PUSH, 
            GPIO_SW_C, 
            GPIO_SW_N, 
            GPIO_SW_E, 
            GPIO_SW_W, 
            GPIO_SW_S,
            ~FPGA_CPU_RESET_B   // Invert this active-low signal before synchronization so that it can be debounced like other buttons
        }),
        .sync_signal({
            rotary_inca_sync,
            rotary_incb_sync,
            rotary_push_sync,
            button_c_sync,
            button_n_sync,
            button_e_sync,
            button_w_sync,
            button_s_sync,
            reset_sync
        })
    );

    // Our synchronized push button inputs next pass through this multi-signal debouncer which will output a debounced version of each signal
    debouncer #(
        .width(7)
    ) pushbutton_debouncer (
        .clk(CLK_33MHZ_FPGA),
        .glitchy_signal({
            rotary_push_sync,
            button_c_sync,
            button_n_sync,
            button_e_sync,
            button_w_sync,
            button_s_sync,
            reset_sync
        }),
        .debounced_signal({
            rotary_push_deb,
            button_c_deb,
            button_n_deb,
            button_e_deb,
            button_w_deb,
            button_s_deb,
            reset_deb
        })
    );

    // The synchronized rotary wheel A and B inputs are filtered and decoded by the rotary_decoder
    rotary_decoder wheel_decoder (
        .clk(CLK_33MHZ_FPGA),
        .rotary_sync_A(rotary_inca_sync),
        .rotary_sync_B(rotary_incb_sync),
        .rotary_event(rotary_event),
        .rotary_left(rotary_left)
    );

    tone_generator piezo_controller (
        .clk(CLK_33MHZ_FPGA),
        .rst(reset_deb),
        .output_enable(GPIO_DIP[0]),
        .tone_switch_period(tone_to_play),
        .square_wave_out(PIEZO_SPEAKER)
    );

    music_streamer streamer (
        .clk(CLK_33MHZ_FPGA),
        .rst(reset_deb),
        .rotary_event(rotary_event),
        .rotary_left(rotary_left),
        .rotary_push(rotary_push_deb),
        .button_center(button_c_deb),
        .button_north(button_n_deb),
        .button_east(button_e_deb),
        .button_west(button_w_deb),
        .button_south(button_s_deb),
        .led_center(GPIO_LED_C),
        .led_north(GPIO_LED_N),
        .led_east(GPIO_LED_E),
        .led_west(GPIO_LED_W),
        .led_south(GPIO_LED_S),
        .tone(tone_to_play),
        .rom_address(rom_address)
    );
endmodule
