import wave
import random
import struct
import sys
import zipfile
from xml.dom import minidom
import os
import glob
import shutil

# Remove the temp directory from previous runs
if (os.path.isdir('temp/')):
    shutil.rmtree('temp/')

# Fetch the filepath to the compressed MusicXML file (.mxl)
musicxml_filepath = sys.argv[1]

# Unzip the compressed file to the temp directory
zip_ref = zipfile.ZipFile(musicxml_filepath, 'r')
zip_ref.extractall('temp/')
zip_ref.close()

# Fetch and parse the XML file in the temp directory
xml_filepath = glob.glob("temp/*.xml")
print(xml_filepath)
xmldoc = minidom.parse(xml_filepath[0])

# Print the XML tree for debugging
print(xmldoc.toprettyxml())

# For the first part in the sheet music
parts = xmldoc.getElementsByTagName('part')[0]

# Extract the time signature of the piece from the first measure, compound/irrational time signatures aren't supported yet
time_signature = parts.getElementsByTagName('measure')[0].getElementsByTagName('attributes')[0].getElementsByTagName('time')[0]

# Each measure has beats_per_measure beats and each beat is 1/beat_unit note
beats_per_measure = int(time_signature.getElementsByTagName('beats')[0].childNodes[0].nodeValue)
beat_unit = int(time_signature.getElementsByTagName('beat-type')[0].childNodes[0].nodeValue)

print("time signature: beats_per_measure %d beat_unit %d" % (beats_per_measure, beat_unit))

# To actually assign a amount of time that each note should be held, we use a tempo like 120 beats per minute
# Then, we discover how many beats each note is by looking at its duration and referencing the beats_per_measure and beat_unit

# Loop through every measure and pull each note
for measure in parts.getElementsByTagName('measure'):
    print("measure %d" % (int(measure.getAttribute('number'))))
    for note in measure.getElementsByTagName('note'):
        rest_check = note.getElementsByTagName('rest')
        if (len(rest_check) > 0):
            duration = int(note.getElementsByTagName('duration')[0].childNodes[0].nodeValue)
            print("\trest note, duration %d" % (duration))
        else:
            note_pitch = note.getElementsByTagName('pitch').item(0)
            step = note_pitch.getElementsByTagName('step')[0].childNodes[0].nodeValue
            octave = int(note_pitch.getElementsByTagName('octave')[0].childNodes[0].nodeValue)
            alter = note_pitch.getElementsByTagName('alter')
            if (len(alter) > 0):
                alter = int(alter[0].childNodes[0].nodeValue)
            else:
                alter = 0
            duration = int(note.getElementsByTagName('duration')[0].childNodes[0].nodeValue)
            print("\tnote with step %s octave %d alter %d duration %d" % (step, octave, alter, duration))

# Translate each note to the equivalent frequency and to the individual half-periods of 32nd notes

# Take the list of notes and gen a Verilog async memory from a command line argument 

