module tone_generator (
    input disable_output,
    input clk,
    output square_wave_out
);

    reg [11:0] clock_counter;

    always @ (posedge clk) begin
        clock_counter <= clock_counter + 1;
    end 
endmodule