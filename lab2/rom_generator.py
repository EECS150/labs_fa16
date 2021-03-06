import wave
import random
import struct
import sys
import math

generated_verilog_filepath = sys.argv[1]
memory_file = sys.argv[2]
memory_depth = int(sys.argv[3])
memory_width = int(sys.argv[4])
address_bits = int(math.ceil(math.log(memory_depth, 2)))
data_bits = memory_width

with open(memory_file, 'r') as memory_data:
    data = memory_data.read()

data = data.split('\n')

verilog_file = open(generated_verilog_filepath, 'w')
verilog_file.write("module rom (input [%d:0] address, output reg [%d:0] data);\n" % (address_bits - 1, data_bits - 1))
verilog_file.write("\talways @ (*) begin\n")
verilog_file.write("\t\tcase(address)\n")

for i in range(0, memory_depth):
    if (i >= len(data) or len(data[i]) == 0): # Write a 0
        verilog_file.write("\t\t\t%d'd%d: data = %d'd%d;\n" % (address_bits, i, data_bits, 0))
    else:
        verilog_file.write("\t\t\t%d'd%d: data = %d'd%d;\n" % (address_bits, i, data_bits, int(data[i])))

verilog_file.write("\t\tendcase\n")
verilog_file.write("\tend\n")
verilog_file.write("endmodule\n")
verilog_file.close()

