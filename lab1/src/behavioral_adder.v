module behavioral_adder (
    input [3:0] a,
    input [3:0] b,
    output [4:0] sum
);

    assign sum = a + b;
endmodule