#!/bin/python3

import sys
import re
import statistics as stat

count = []
step = -1

with open(sys.argv[1],"r") as f:
    for data in f:
        if "TimeStep" in data:
            nextstep = int(re.findall("(?<=\().+?(?=\))", data)[0].split(",")[0][8:])
            if step == nextstep:
                count = count[:-1]
            else:
                step = nextstep
            count.append(0)
        elif "Residual" == data[:8]:
            count[-1] = int(data[9:].split(":")[0])
print(len(count))
print(max(count))
print("$"+str(stat.mean(count))+" \pm "+str(stat.stdev(count))+"$(max "+str(max(count))+")")
print(stat.median(count))
print(stat.mode(count))