module tone_generator (
    input output_enable,
    input [23:0] tone_switch_period, 
    input clk,
    input rst,
    output square_wave_out
);

    reg [23:0] clock_counter = 0;
    assign square_wave_out = 0;

    // Copy your lab 2 tone_generator here
endmodule
