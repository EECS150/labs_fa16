module debouncer_fpga_test (
    input CLK_33MHZ_FPGA,       // 33 Mhz Clock Signal Input
    input FPGA_ROTARY_PUSH,     // Rotary Encoder Push Button Signal (Active-high)
    input GPIO_SW_C,            // Compass Center User Pushbutton (Active-high)
    input GPIO_SW_N,            // Compass North User Pushbutton (Active-high)
    input GPIO_SW_E,            // Compass East User Pushbutton (Active-high)
    input GPIO_SW_W,            // Compass West User Pushbutton (Active-high)
    input GPIO_SW_S,            // Compass South User Pushbutton (Active-high)
    input FPGA_CPU_RESET_B,     // CPU_RESET Pushbutton (Active-LOW), signal should be interpreted as logic high when 0

    output [7:0] GPIO_LED      // 8 GPIO LEDs
);
    // Synchronized versions of the input buttons and rotary encoder wheel signals
    wire rotary_push_sync, button_c_sync, button_n_sync, button_e_sync, button_w_sync, button_s_sync, reset_sync;
    wire rotary_push_deb, button_c_deb, button_n_deb, button_e_deb, button_w_deb, button_s_deb, reset_deb;
    wire rotary_push, button_c, button_n, button_e, button_w, button_s, reset;

    reg [7:0] number = 0;
    assign GPIO_LED[7:0] = number;

    always @ (posedge CLK_33MHZ_FPGA) begin
        if (rotary_push || button_c || button_n || button_e || button_w || reset) begin
            number <= number + 1;
        end
        else if (button_s) begin
            number <= number - 1;
        end
        else begin
            number <= number;
        end
    end

    // We first pass each one of our asynchronous FPGA inputs through a 1-bit synchronizer
    synchronizer #(
        .width(7)
    ) input_synchronizer (
        .clk(CLK_33MHZ_FPGA),
        .async_signal({
            FPGA_ROTARY_PUSH, 
            GPIO_SW_C, 
            GPIO_SW_N, 
            GPIO_SW_E, 
            GPIO_SW_W, 
            GPIO_SW_S,
            ~FPGA_CPU_RESET_B   // Invert this active-low signal before synchronization so that it can be debounced like other buttons
        }),
        .sync_signal({
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

    // The debounced push button signals pass through the edge detector so that your design can use single clock cycle wide button pulses
    edge_detector #(
        .width(7)
    ) pushbutton_edge_detector (
        .clk(CLK_33MHZ_FPGA),
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
endmodule
