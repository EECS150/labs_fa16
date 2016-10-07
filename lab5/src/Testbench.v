`timescale 1ns/1ps

module Testbench();
  // 1 / (100 MHz) = 10ns
  localparam ClockFreq = 100_000_00;
  localparam Cycle = 10;
  
  reg  Clock, Reset;
  
  reg  [7:0] DataIn;
  reg  DataInValid;
  wire DataInReady;
  wire [7:0] DataOut;
  wire DataOutValid;
  reg  DataOutReady;
  wire FPGA_SERIAL_RX;
  wire FPGA_SERIAL_TX;

  initial Clock = 1'b0;
  always #(5) Clock = ~Clock;

  initial begin
    // Reset
    DataInValid = 1'b0;
    DataOutReady = 1'b0;
    Reset = 1'b1;
    #(10*Cycle);
    Reset = 1'b0;
    #(Cycle);

    // Wait until DataInReady, send a character
    while (DataInReady == 1'b0) begin #(Cycle); end
    DataIn = 8'h21;
    DataInValid = 1'b1;
    #(Cycle);
    DataInValid = 1'b0;

    // Wait until it comes out the other side
    while (!DataOutValid) #(Cycle);
    if (DataOut !== 8'h21) begin
      // Wrong character came out
      $display("Simulation Failed: Got output %d", DataOut);
      $finish();
    end
    #(Cycle * 10);
    if (DataOut !== 8'h21) begin
      $display("Simulation Failed: UART did not hold DataOut until DataOutReady");
      $finish();
    end
    if (FPGA_SERIAL_TX !== 1'b1) begin
      $display("Simulation Failed: UART TX idle signal was not high");
      $finish();
    end
    DataOutReady = 1'b1;
    #(Cycle);
    if (DataOutValid) begin
      $display("Simulation Failed: UART did not clear Valid bit after Ready");
      $finish();
    end

    $display("Test Successful, got output %d", 8'h21);
    $finish();
  end

  UART               #( .ClockFreq(       ClockFreq))
                 uart1( .Clock(           Clock),
                        .Reset(           Reset),
                        .DataIn(          DataIn),
                        .DataInValid(     DataInValid),
                        .DataInReady(     DataInReady),
                        .DataOut(         ),
                        .DataOutValid(    ),
                        .DataOutReady(    ),
                        .SIn(             FPGA_SERIAL_RX),
                        .SOut(            FPGA_SERIAL_TX));

  UART               #( .ClockFreq(       ClockFreq))
                 uart2( .Clock(           Clock),
                        .Reset(           Reset),
                        .DataIn(          ),
                        .DataInValid(     ),
                        .DataInReady(     ),
                        .DataOut(         DataOut),
                        .DataOutValid(    DataOutValid),
                        .DataOutReady(    DataOutReady),
                        .SIn(             FPGA_SERIAL_TX),
                        .SOut(            FPGA_SERIAL_RX));

endmodule
