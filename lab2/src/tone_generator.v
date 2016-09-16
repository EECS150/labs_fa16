module tone_generator (
    input output_enable,
    input clk,
    output square_wave_out
);

    reg [23:0] clock_counter;
    assign square_wave_out = 0;

endmodule
