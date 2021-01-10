#!/bin/python3

import sys
import re
import statistics as stat

count = []
step = -1

with open(sys.argv[1],"r") as f:
    for data in f:
        if "DTime" in data:
            dtime = float(re.findall("(?<=\().+?(?=\))", data)[0].split(",")[1][6:])
            nextstep = int(re.findall("(?<=\().+?(?=\))", data)[0].split(",")[0][8:])
            if step == nextstep:
                count = count[:-1]
            else:
                step = nextstep
            count.append(dtime)
print(len(count))
print(max(count))
print(min(count))
print(str(stat.mean(count))+" \pm "+str(stat.stdev(count)))
print(stat.median(count))