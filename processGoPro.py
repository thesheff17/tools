#!/usr/bin/env python3

import glob
import subprocess
from datetime import datetime
startTime = datetime.now()

dir1 = "/Volumes/msdos/DCIM/100GOPRO/*.MP4"
dir2 = "/Volumes/ARCANITE/"

with open("./processGoPro.txt", "w") as f:
    for each in glob.glob(dir1):
        f.write("file '" + each + "'\n")

command1 = "ffmpeg -f concat -safe 0 -i processGoPro.txt -c copy " + dir2 + "output.mp4"
subprocess.call(command1, shell=True)

print(datetime.now() - startTime)
print ("processGoPro.py completed")
