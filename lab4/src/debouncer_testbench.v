`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000
`define CLK_PER 30
`define WID 3
`define SAMP_PER 250
`define SAT_MAX 150

module debouncer_testbench();

   reg [`WID-1:0] in = 0;
   wire [`WID-1:0] out;
   reg [`WID-1:0] fail = 0;
   reg clk = 0;
   reg rst;

   always #(`CLK_PER/2) clk = ~clk;
   
   initial begin
      fork
	 begin
	    repeat (3) @(posedge clk);
	    in[0] = 1;
	    @(posedge clk) in[0] = 0;
	 end
	 begin
	    repeat (3) @(posedge clk);
	    in[1] = 1;
	    @(posedge clk) in[1] = 0;
	    @(posedge clk) in[1] = 1;
	    @(posedge clk) in[1] = 0;
	    @(posedge clk) in[1] = 1;
	    repeat((`SAMP_PER+3)*`SAT_MAX) @(posedge clk);
	    in[1] = 0;
	 end
	 begin
	    repeat (3) @(posedge clk);
	    in[2] = 1;
	    @(posedge clk) in[2] = 0;
	    @(posedge clk) in[2] = 1;
	    @(posedge clk) in[2] = 0;
	    @(posedge clk) in[2] = 1;
	    repeat(4*`SAMP_PER*`SAT_MAX) @(posedge clk);
	    in[2] = 0;
	 end
	 begin
	    @(posedge out[1]);
	    @(negedge in[1]);
	    repeat (5) @(posedge clk);
	    if (out[1] != 0) fail[1] = 1;
	 end
	 begin
	    @(posedge out[2]);
	    @(negedge out[2]);
	    if (in[2] == 1) fail[2] = 1;
	 end
	 begin
	    @(posedge clk);
	    rst = 0;
	    @(posedge clk);
	    rst = 1;
	    @(posedge clk);
	    rst = 0;
	 end // fork begin
      join

      if (fail == 0) $display("Pass");
      if (fail[0] == 1) $display("Input signal 0 wasn't suppose to be long enough to output a 1 at any point");
      if (fail[1] == 1) $display("Output signal didn't go to 0 when input signal went to 0");
      if (fail[2] == 1) $display("Output signal dropped to 0 when it should have stayed at 1");
      #10000;
      $finish();
            
   end // initial begin

   always@(*) fail[0] = out[0];
   
   debouncer #(.width(`WID),
	       .sampling_pulse_period(`SAMP_PER),
	       .saturating_counter_max(`SAT_MAX)) DUT
     (
      .clk(clk),
      .rst(rst),
      .glitchy_signal(in),
      .debounced_signal(out)
      );

endmodule
