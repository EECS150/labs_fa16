module synchronizer_fpga_test (
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

    assign GPIO_LED[7:0] = {button_c_sync, button_n_sync, button_e_sync, button_w_sync, button_s_sync, reset_sync, rotary_push_sync, 1'b0};

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
endmodule
