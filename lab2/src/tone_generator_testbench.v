`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000
// The SAMPLE_PERIOD corresponds to a 44100 kHz sampling rate
`define SAMPLE_PERIOD 22675.7

module tone_generator_testbench();
    reg clock;
    reg output_enable;
    wire sq_wave;

    initial clock = 0;
    always #(30.3/2) clock <= ~clock;

    tone_generator piezo_controller (
        .clk(clock),
        .output_enable(output_enable),
        .square_wave_out(sq_wave)
    );

    initial begin
        output_enable <= 0;
        #(500 * `MS);
	output_enable <= 1;
        #(1 * `SECOND);
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
