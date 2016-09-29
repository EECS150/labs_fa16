`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000
`define CLK_PER 30

module edge_detector_testbench();

   reg send_sig = 0;
   wire captured_sig;
   reg clk = 0;
   reg rst;
   integer in_up, out_up;

   task gen_sig;
      begin
	 repeat (2) @(posedge clk);
	 in_up = $time;
	 $display("High sent on %d", in_up);
	 send_sig = ~send_sig;
      end
   endtask // gen_sig

   always #(`CLK_PER/2) clk = ~clk;

   initial begin
      fork
	 begin
	    gen_sig();
	 end
	 begin
	    @(posedge clk);
	    rst = 0;
	    @(posedge clk);
	    rst = 1;
	    @(posedge clk);
	    rst = 0;
	 end
	 begin
	    @(posedge captured_sig) out_up = $time;
	    $display("Edge detected on %d", out_up);
	 end
	 begin
	    @(posedge captured_sig);
	    @(posedge clk);
	    #1 if (captured_sig != 0) begin
	       $display("Edge detect output was high for too long");
	       $display("Output needs to high for only one pulse");
	    end
	 end
      join
      $display("Time diff was %d", out_up-in_up);
      
      if (out_up - in_up > 5*`CLK_PER) $display("Took too long to detect");
      else $display("Passed");
      #100;
      $finish();
            
   end // initial begin

   edge_detector #(.width(1)) DUT
     (
      .clk(clk),
      .rst(rst),
      .signal_in(send_sig),
      .edge_detect_pulse(captured_sig)
      );

endmodule
