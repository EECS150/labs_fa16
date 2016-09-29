module rotary_decoder_fpga_test (
    input CLK_33MHZ_FPGA,       // 33 Mhz Clock Signal Input
    input FPGA_ROTARY_INCA,     // Rotary Encoder Wheel A Signal
    input FPGA_ROTARY_INCB,     // Rotary Encoder Wheel B Signal
    input FPGA_ROTARY_PUSH,     // Rotary Encoder Push Button Signal (Active-high)
    output [7:0] GPIO_LED      // 8 GPIO LEDs
);
    reg [7:0] number = 0;
    assign GPIO_LED = number;
    
    // Synchronized versions of the input buttons and rotary encoder wheel signals
    wire rotary_inca_sync, rotary_incb_sync, rotary_push_sync;

    // Debounced versions of the input buttons (already synchronized)
    wire rotary_push_deb;

    // Debounced versions of the A and B signals (already synchronized)
    wire rotary_inca_deb, rotary_incb_deb;

    // Signals from your rotary decoder
    wire rotary_event, rotary_left;

    always @ (posedge CLK_33MHZ_FPGA) begin
        if (rotary_event && rotary_left) begin
            number <= number - 1;
        end
        else if (rotary_event && !rotary_left) begin
            number <= number + 1;
        end
        else if (rotary_push_deb) begin
            number <= 0;
        end
        else begin
            number <= number;
        end
    end

    // We first pass each one of our asynchronous FPGA inputs through a 1-bit synchronizer
    synchronizer #(
        .width(3)
    ) input_synchronizer (
        .clk(CLK_33MHZ_FPGA),
        .async_signal({
            FPGA_ROTARY_INCA, 
            FPGA_ROTARY_INCB, 
            FPGA_ROTARY_PUSH
        }),
        .sync_signal({
            rotary_inca_sync,
            rotary_incb_sync,
            rotary_push_sync
        })
    );

    // Our synchronized push button inputs next pass through this multi-signal debouncer which will output a debounced version of each signal
    debouncer #(
        .width(1)
    ) pushbutton_debouncer (
        .clk(CLK_33MHZ_FPGA),
        .glitchy_signal({
            rotary_push_sync
        }),
        .debounced_signal({
            rotary_push_deb
        })
    );

    // Debouncer for the rotary wheel inputs
    debouncer #(
        .width(2),
        .sampling_pulse_period(10000), 
        .saturating_counter_max(12)
    ) rotary_debouncer (
        .clk(CLK_33MHZ_FPGA),
        .glitchy_signal({
            rotary_inca_sync,
            rotary_incb_sync
        }),
        .debounced_signal({
            rotary_inca_deb,
            rotary_incb_deb
        })
    );

    // The synchronized rotary wheel A and B inputs are filtered and decoded by the rotary_decoder
    rotary_decoder wheel_decoder (
        .clk(CLK_33MHZ_FPGA),
        .rotary_sync_A(rotary_inca_deb),
        .rotary_sync_B(rotary_incb_deb),
        .rotary_event(rotary_event),
        .rotary_left(rotary_left)
    );
endmodule
