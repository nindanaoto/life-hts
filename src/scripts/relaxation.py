#!/bin/python3

import sys
import re
import statistics as stat
import numpy as np

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
            count.append([])
        elif "optimal relaxation factor = " in data:
            count[-1].append(float(data.split("=")[1][1:-2]))
print(len(count))
# print(count)
numrelax = [np.count_nonzero(np.array(count[i])<1.0) for i in range(len(count))]
print(np.count_nonzero(numrelax))
# print("$"+str(stat.mean(count))+" \pm "+str(stat.stdev(count))+"$(max "+str(max(count))+")")
# print(stat.median(count))
# print(stat.mode(count))