//-----------------------------------------------------------------------------
// UC Berkeley EECS 151/251A FPGA Lab
// Lab 1, Fall 2016
// Module: ml505top.v
// Desc: Talks to the world outside your design.
//-----------------------------------------------------------------------------

module ml505top (
    input  CLK_33MHZ_FPGA,
    input  [7:0] GPIO_DIP,
    output [7:0] GPIO_LED
);

    structural_adder st_add (
        .a(GPIO_DIP[3:0]),
        .b(GPIO_DIP[7:4]),
        .sum(GPIO_LED[4:0])
    );

    // Uncomment this for lab sections 5.3 and 5.4
    /*
    behavioral_adder be_add (
        .a(GPIO_DIP[3:0]),
        .b(GPIO_DIP[7:4]),
        .sum(GPIO_LED[4:0])
    );
    */
    
    // Uncomment this for lab section 6
    /*
    tone_generator piezo_controller (
        .clk(CLK_33MHZ_FPGA),
        .output_enable(GPIO_DIP[0]),
        .square_wave_out(connect to piezo output)
    );
    */
    
    assign GPIO_LED[7:5] = 3'b0;
endmodule
