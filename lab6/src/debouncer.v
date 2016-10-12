`include "util.vh"

module debouncer #(
    parameter width = 1,
    parameter sampling_pulse_period = 25000, 
    parameter saturating_counter_max = 150,
    parameter sampling_counter_width = `log2(sampling_pulse_period),
    parameter saturating_counter_width = `log2(saturating_counter_max))
(
    input clk,
    input rst,
    input [width-1:0] glitchy_signal,
    output [width-1:0] debounced_signal
);

    // Create your debouncer circuit here
    // This module takes in a vector of 1-bit synchronized, but possibly glitchy signals
    // and should output a vector of 1-bit signals that hold high when their respective counter saturates

    // Remove this line once you create your synchronizer
    assign debounced_signal = 0;

    reg [sampling_counter_width - 1:0] wrapping_counter = 0;
    reg [saturating_counter_width - 1:0] saturating_counter [width-1:0];

    initial begin:INITIALIZE_SAT_COUNTER
        integer k;
        for (k = 0; k < width; k = k + 1) begin
            saturating_counter[k] <= 0;
        end
    end
endmodule
