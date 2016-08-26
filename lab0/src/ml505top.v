//-----------------------------------------------------------------------------
// UC Berkeley EECS 151/251A FPGA Lab
// Lab 0, Fall 2016
// Module: ml505top.v
// Desc: Talks to the world outside your design.
//-----------------------------------------------------------------------------

module ml505top (
	input  [4:0] GPIO_COMPSW,
	input  CLK_33MHZ_FPGA,
    input  [7:0] GPIO_DIP,
    output [7:0] GPIO_LED
);

    // AND gate example (LED 0 shows (GPIO 1)*(GPIO 2)):
    and (GPIO_LED[0], GPIO_DIP[0], GPIO_DIP[1]);

endmodule
