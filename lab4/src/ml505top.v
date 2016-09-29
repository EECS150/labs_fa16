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
    // Connection between music_streamer and tone_generator
    wire [23:0] tone_to_play;

    // Synchronized versions of the input buttons and rotary encoder wheel signals
    wire rotary_inca_sync, rotary_incb_sync, rotary_push_sync, 
        button_c_sync, button_n_sync, button_e_sync, button_w_sync, button_s_sync, reset_sync;

    // Debounced versions of the input buttons (already synchronized)
    wire rotary_push_deb, button_c_deb, button_n_deb, button_e_deb, button_w_deb, button_s_deb, reset_deb;

    // Debounced versions of the rotary encoder A and B signals (already synchronized)
    wire rotary_inca_deb, rotary_incb_deb;

    // Pulsed input button signals (from edge detector), you should use these in your design
    wire rotary_push, button_c, button_n, button_e, button_w, button_s, reset;

    // Signals from your rotary decoder
    wire rotary_event, rotary_left;

    // We first pass each one of our asynchronous FPGA inputs through a 1-bit synchronizer
    synchronizer #(
        .width(9)
    ) input_synchronizer (
        .clk(CLK_33MHZ_FPGA),
        .rst(reset),
        .async_signal({
            FPGA_ROTARY_INCA, 
            FPGA_ROTARY_INCB, 
            FPGA_ROTARY_PUSH, 
            GPIO_SW_C, 
            GPIO_SW_N, 
            GPIO_SW_E, 
            GPIO_SW_W, 
            GPIO_SW_S,
            ~FPGA_CPU_RESET_B   // Invert this active-low signal before synchronization so that it can be edge detected like other buttons
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
        .rst(reset),
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

    // The debounced push button signals pass through the edge detector so that your design can use single clock cycle wide button pulses
    edge_detector #(
        .width(7)
    ) pushbutton_edge_detector (
        .clk(CLK_33MHZ_FPGA),
        .rst(reset),
        .signal_in({
            rotary_push_deb,
            button_c_deb,
            button_n_deb,
            button_e_deb,
            button_w_deb,
            button_s_deb,
            reset_deb
        }),
        .edge_detect_pulse({
            rotary_push,
            button_c,
            button_n,
            button_e,
            button_w,
            button_s,
            reset
        })
    );

    // Debouncer for the rotary wheel inputs
    debouncer #(
        .width(2),
        .sampling_pulse_period(10000), 
        .saturating_counter_max(12)
    ) rotary_debouncer (
        .clk(CLK_33MHZ_FPGA),
        .rst(reset),
        .glitchy_signal({
            rotary_inca_sync,
            rotary_incb_sync
        }),
        .debounced_signal({
            rotary_inca_deb,
            rotary_incb_deb
        })
    );

    // The synchronized rotary wheel A and B inputs are filtered and decoded by the rotary_decoder
    rotary_decoder wheel_decoder (
        .clk(CLK_33MHZ_FPGA),
        .rst(reset),
        .rotary_sync_A(rotary_inca_deb),
        .rotary_sync_B(rotary_incb_deb),
        .rotary_event(rotary_event),
        .rotary_left(rotary_left)
    );

    tone_generator piezo_controller (
        .clk(CLK_33MHZ_FPGA),
        .rst(reset),
        .output_enable(GPIO_DIP[0]),
        .tone_switch_period(tone_to_play),
        .square_wave_out(PIEZO_SPEAKER)
    );

    music_streamer streamer (
        .clk(CLK_33MHZ_FPGA),
        .rst(reset),
        .rotary_event(rotary_event),
        .rotary_left(rotary_left),
        .rotary_push(rotary_push),
        .button_center(button_c),
        .button_north(button_n),
        .button_east(button_e),
        .button_west(button_w),
        .button_south(button_s),
        .led_center(GPIO_LED_C),
        .led_north(GPIO_LED_N),
        .led_east(GPIO_LED_E),
        .led_west(GPIO_LED_W),
        .led_south(GPIO_LED_S),
        .tone(tone_to_play),
        .GPIO_leds(GPIO_LED)
    );
endmodule
