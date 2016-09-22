`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000
`define SAMPLE_PERIOD 22675.7

module tone_generator_testbench();
    reg clock;
    reg output_enable;
    reg reset;

    wire [23:0] tone_to_play;
    wire sq_wave;

    initial clock = 0;
    always #(30.3/2) clock <= ~clock;

    tone_generator piezo_controller (
        .clk(clock),
        .rst(reset),
        .output_enable(output_enable),
        .tone_switch_period(tone_to_play),
        .square_wave_out(sq_wave)
    );

    music_streamer streamer (
        .clk(clock),
        .rst(reset),
        .tone(tone_to_play)
    );

    initial begin
        reset <= 1;
        #10;
        reset <= 0;
        output_enable <= 1;
        #(2 * `SECOND);
        #(2 * `SECOND);
        $finish();
    end

    integer file;
    initial begin
        file = $fopen("output.txt", "w");
        forever begin
            $fwrite(file, "%h\n", sq_wave);
            #(`SAMPLE_PERIOD);
        end
    end

endmodule
