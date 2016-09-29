`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000
`define CLK_PER 30

module sync_testbench();

   reg send_sig = 0;
   wire captured_sig;
   reg clk = 0;
   
   task compare;
      input expected, received;
      $display("Expected %b; Got %b", expected, received);
   endtask // compare

   task gen_sig;
      begin
	 #20 send_sig = ~send_sig;
	 #15 send_sig = ~send_sig;
	 #5 send_sig = ~send_sig;
	 #10 send_sig = ~send_sig;
	 #30 send_sig = ~send_sig;
	 #50 send_sig = ~send_sig;
      end
   endtask // gen_sig

   always #(`CLK_PER/2) clk = ~clk;

   initial begin
      fork
	 begin
	    gen_sig();
	 end
	 begin
	    repeat(2) @(posedge clk);
	    #1 compare(1'b0, captured_sig);
	    @(posedge clk);
      	    #1 compare(1'b1, captured_sig);
	    @(posedge clk);
	    #1 compare(1'b0, captured_sig);
	    @(posedge clk);
	    #1 compare(1'b1, captured_sig);
	 end
      join
      #100;
      $finish();
            
   end // initial begin

   synchronizer #(.width(1)) DUT
     (
      .clk(clk),
      .async_signal(send_sig),
      .sync_signal(captured_sig)
      );

endmodule
