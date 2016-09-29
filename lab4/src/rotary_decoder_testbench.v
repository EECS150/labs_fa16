`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000
`define CLK_PER 30

module rotary_decoder_testbench();

   reg A = 0;
   reg B = 0;
   wire out_event, out_left;
   reg clk = 0;
   reg rst;

   task gen_sig_right;
      begin
	 @(posedge clk) A = ~A;
	 @(posedge clk) B = ~B;
	 @(posedge clk) B = ~B;
	 @(posedge clk) A = ~A;
      end
   endtask 

   task gen_sig_left;
      begin
	 @(posedge clk) B = ~B;
	 @(posedge clk) A = ~A;
	 @(posedge clk) A = ~A;
	 @(posedge clk) B = ~B;
      end
   endtask

   always #(`CLK_PER/2) clk = ~clk;

   initial begin
      fork
	 begin
	    @(posedge clk);
	    rst = 0;
	    @(posedge clk);
	    rst = 1;
	    @(posedge clk);
	    rst = 0;
	    gen_sig_right();
	    gen_sig_left();
	 end // fork begin
	 begin
	    @(posedge out_event) begin
 	       #1 if (out_left == 1'b0) $display("Got expected value for first event");
	       else $display("Did not get expected value for first event: expected output of 0 at first event");
	    end
	    @(posedge out_event) begin  
	       #1 if (out_left == 1'b1) $display("Got expected value for first event");
	       else $display("Did not get expected value for first event: expected output of 0 at first event");
	    end
	 end
      join
      
      #100;
      $finish();
            
   end // initial begin

   rotary_decoder DUT
     (
      .clk(clk),
      .rst(rst),
      .rotary_sync_A(A),
      .rotary_sync_B(B),
      .rotary_event(out_event),
      .rotary_left(out_left)
      );

endmodule
