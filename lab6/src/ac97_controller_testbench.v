`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000
`define SYSTEM_CLK_PERIOD 30.3
`define BIT_CLK_PERIOD 81.38

module ac97_controller_testbench();
    reg system_clock = 0;
    reg bit_clk = 0;
    reg system_reset = 0;
    reg square_wave = 0;
    wire sdata_out, sync, reset_b;

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
        // Pulse the system reset to the ac97 controller
        @(posedge system_clock);
        system_reset <= 1'b1;
        @(posedge system_clock);
        system_reset <= 1'b0;

        // Observe the waveform for 20ms to verify that reset_b was held low for t_RSTLOW seconds
        // Then observe the correct data being sent over sdata_out
        // Verify that sync is asserted according to the timing diagram in the spec
        #(20 * `MS);
        $finish();
    end

    ac97_controller DUT (
        .sdata_in(),    // Leave unconnected for this lab
        .bit_clk(bit_clk),
        .sdata_out(sdata_out),
        .sync(sync),
        .reset_b(reset_b),
        .system_clock(system_clock),
        .system_reset(system_reset),
        .square_wave(square_wave)
    );
endmodule
