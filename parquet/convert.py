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
this script will convert json files to parquet files
./convert.py prefix
"""

import glob
import timeit
import sys
from pyspark.sql import SparkSession


if __name__ == "__main__":

    start = timeit.default_timer()

    spark = SparkSession.builder.appName("Python Spark SQL data source example").getOrCreate()

    files = glob.glob('*.json')

    for each in files:
        print ("converting file " + each + " to parquet format...")
        filename = each.split(".")
        filename1 = filename
        filename1 = "./" + sys.argv[1] + "-" + filename[0] + ".parquet" 
        dataDF = spark.read.json(each)
        dataDF.write.parquet(filename1)

    stop = timeit.default_timer()

    print('Total time in seconds: ', stop - start)