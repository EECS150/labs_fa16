import wave
import random
import struct
import sys

output_wav = wave.open('output.wav', 'w')
output_wav.setparams((2, 2, 44100, 0, 'NONE', 'not compressed'))

values = []

filepath = sys.argv[1]
with open(filepath, 'r') as samples_file:
    data = samples_file.read()

for note in data:
    value = 0
    if (note == '0'):
        value = -20000
    elif (note == '1'):
        value = 20000
    else:
        continue
    packed_value = struct.pack('h', value)
    values.append(packed_value)
    values.append(packed_value)

value_str = ''.join(values)
output_wav.writeframes(value_str)
output_wav.close()
sys.exit(0)
