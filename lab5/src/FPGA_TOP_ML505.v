module FPGA_TOP_ML505(
  input   GPIO_SW_C,
  input   USER_CLK,

  input   FPGA_SERIAL_RX,
  output  FPGA_SERIAL_TX
);
  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq     =             100000000;  // 100 MHz
  parameter   UARTBaudRate  =             115200;     // 115.2 KBaud

  //--|Wires|-------------------------------------------------------------------

  wire        Clock, Reset;
  wire  [7:0] DataIn;
  wire        DataInValid;
  wire        DataInReady;
  wire  [7:0] DataOut;
  wire        DataOutValid;
  wire        DataOutReady;
  
  //--|Clock & Reset|-----------------------------------------------------------

  BUFG        clockBuf( .I(               USER_CLK),
                        .O(               Clock));

  ButtonParse        #( .Width(           1),
                        .DebWidth(        20),
                        .EdgeOutWidth(    1)) 
            resetParse( .Clock(           Clock),
                        .Reset(           1'b0),
                        .Enable(          1'b1),
                        .In(              GPIO_SW_C),
                        .Out(             Reset));

  //--|UART|--------------------------------------------------------------------
  
  UART               #( .ClockFreq(       ClockFreq),
                        .BaudRate(        UARTBaudRate))
                  uart( .Clock(           Clock),
                        .Reset(           Reset),
                        .DataIn(          DataIn),
                        .DataInValid(     DataInValid),
                        .DataInReady(     DataInReady),
                        .DataOut(         DataOut),
                        .DataOutValid(    DataOutValid),
                        .DataOutReady(    DataOutReady),
                        .SIn(             FPGA_SERIAL_RX),
                        .SOut(            FPGA_SERIAL_TX));

  //--|Echo|--------------------------------------------------------------------

  reg       has_char;
  reg [7:0] char;

  always @(posedge Clock) begin
    if (Reset) has_char <= 1'b0;
    else has_char <= has_char ? !DataInReady : DataOutValid;
  end

  always @(posedge Clock)
    if (!has_char) char <= DataOut;

  assign DataInValid = has_char;
  assign DataIn = char;
  assign DataOutReady = !has_char;

endmodule
