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
# Loop through every measure and pull each note

# Translate each note to the equivalent frequency and to the individual half-periods of 32nd notes

# Take the list of notes and gen a Verilog async memory from a command line argument 

