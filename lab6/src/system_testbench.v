`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000
`define SYSTEM_CLK_PERIOD 30.3
`define BIT_CLK_PERIOD 81.38

module system_testbench();
    // Clocks
    reg system_clock = 0;
    reg bit_clk = 0;

    // GPIO DIP switches
    reg [7:0] gpio_switches;

    // AC97 signals to codec
    wire sdata_out, sync, reset_b;

    // Piezo speaker output
    wire piezo_out;

    // Button inputs
    reg button_c, button_n, button_e, button_w, button_s, rotary_push, button_reset_b;

    // Rotary wheel inputs
    reg rotary_A, rotary_B;

    // LEDs
    wire [7:0] gpio_leds;
    wire led_c, led_n, led_e, led_w, led_s;

    always #(`SYSTEM_CLK_PERIOD/2) system_clock = ~system_clock;
    always @ (*) begin
        forever begin
            #(`BIT_CLK_PERIOD/2);
            bit_clk = ~bit_clk;
            if (~reset_b) begin
                bit_clk = 0;
                @(posedge reset_b);
                #(`BIT_CLK_PERIOD * 20);
            end
        end
    end


    initial begin
        // Enable piezo and audio controller output
        gpio_switches[0] <= 1'b1;
        gpio_switches[7] <= 1'b1;

        // Simulate pushing the CPU_RESET button and holding it for a while
        // Verify that the reset signal into the ac97 controller only pulses once
        // Verify that the reset signal to the codec is held for t_RSTLOW seconds
        button_reset_b <= 1'b0;
        #(500 * `MS);
        button_reset_b <= 1'b1;
        #(20 * `MS);

        // Verify that all the lines going to the codec are well defined (not X)
        // This includes reset_b, sync, and sdata_out


        $finish();
    end

ml505top DUT (
    .CLK_33MHZ_FPGA(system_clock),
    .GPIO_DIP(gpio_switches),
    .FPGA_ROTARY_INCA(rotary_A),
    .FPGA_ROTARY_INCB(rotary_B),
    .FPGA_ROTARY_PUSH(rotary_push),
    .GPIO_SW_C(button_c),
    .GPIO_SW_N(button_n),
    .GPIO_SW_E(button_e),
    .GPIO_SW_W(button_w),
    .GPIO_SW_S(button_s),
    .FPGA_CPU_RESET_B(button_reset_b),

    .PIEZO_SPEAKER(piezo_out),
    .GPIO_LED(gpio_leds),
    .GPIO_LED_C(led_c),
    .GPIO_LED_N(led_n),
    .GPIO_LED_E(led_e),
    .GPIO_LED_W(led_w),
    .GPIO_LED_S(led_s),

    .AUDIO_BIT_CLK(bit_clk),
    .AUDIO_SDATA_IN(),       // Leave unconnected for this lab
    .AUDIO_SDATA_OUT(sdata_out),
    .AUDIO_SYNC(sync),
    .FLASH_AUDIO_RESET_B(reset_b)
);
endmodule
