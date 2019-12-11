#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (c) Dan Sheffner Digital Imaging Software Solutions, INC
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish, dis-
# tribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the fol-
# lowing conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABIL-
# ITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

"""
This program will compress all files using snappy
make sure you pass "*.json" with quote marks or this will not work!
./snappyfiles.py "*.json"

sudo apt-get install libsnappy-dev
pip3 install python-snappy
"""

import glob
import sys
from multiprocessing import Pool, cpu_count
import subprocess
import os
import sys
import timeit


def processfiles(command1):
    print ("compressing " + filename[-1])
    subprocess.run(command1, shell=True)

if __name__ == "__main__":
    start = timeit.default_timer()
    files = glob.glob(sys.argv[1])
    commands = []

    for each in files:
        filename = each.split(" ")
        commands.append("python3 -m snappy -c " + each + " " + filename + ".snappy")
    
    num_of_cpu = cpu_count()

    # simulate smaller server/pool if needed
    # num_of_cpu = 2

    pool = Pool(processes=num_of_cpu)
    pool.map(processfiles, commands)
    
    stop = timeit.default_timer()

    print ('Total time in seconds: ', stop - start)  
    print ("gzipfiles.py completed")
