import wave
import random
import struct
import sys
import zipfile
from xml.dom import minidom
import os
import glob
import shutil

if (os.path.isdir('temp/')):
    shutil.rmtree('temp/')
musicxml_filepath = sys.argv[1]

zip_ref = zipfile.ZipFile(musicxml_filepath, 'r')
zip_ref.extractall('temp/')
zip_ref.close()

xml_filepath = glob.glob("temp/*.xml")
print(xml_filepath)
xmldoc = minidom.parse(xml_filepath[0])
print(xmldoc.toprettyxml())
