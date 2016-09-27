module debouncer #(
    parameter width = 1,
    parameter sampling_pulse_period = 25000, 
    parameter saturating_counter_max = 120) 
(
    input clk,
    input [width-1:0] glitchy_signal,
    output [width-1:0] debounced_signal
);

    // Create your debouncer circuit here
    // This module takes in a vector of 1-bit synchronized, but possibly glitchy signals
    // and should output a vector of 1-bit signals that pulse high for one clock cycle when their respective counter saturates

    // Remove this line once you create your synchronizer
    assign debounced_signal = 0;
endmodule
