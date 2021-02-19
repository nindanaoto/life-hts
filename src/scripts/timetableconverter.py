#!/bin/python3

import sys
import csv

if len(sys.argv)!=5:
    print("ivalid number of arguments")
    print("dim isvector read_filename write_filename")
    exit()

dim = int(sys.argv[1])
isvector = int(sys.argv[2])
read_filename = sys.argv[3]
write_filename = sys.argv[4]
header = ['time']
value_dim = 0
csv_writers = []
if(dim==2):
    header += ['x coord 0', 'y coord 0','z coord 0','x coord 1', 'y coord 1','z coord 1','x coord 2', 'y coord 2','z coord 2']
elif(dim==3):
    header += ['x coord 0', 'y coord 0','z coord 0','x coord 1', 'y coord 1','z coord 1','x coord 2', 'y coord 2','z coord 2','x coord 3', 'y coord 3','z coord 3']
else:
    print("dim Error")
    exit()
if(isvector):
    header += ['x scalar', 'y scalar', 'z scalar']
    value_dim = 3
else:
    header += ['scalar']
    value_dim = 1
with open(read_filename,"r") as f:
    read_file = csv.reader(f, delimiter=' ')
    maxtimestep = -1
    for row in read_file:
        current_time = int(row[0])
        data = [r for r in row if r != '']
        if current_time > maxtimestep:
            csv_writers.append(csv.writer(open(write_filename+'.'+row[0],'w')))
            csv_writers[current_time].writerow(header)
            maxtimestep = current_time
        csv_writers[current_time].writerow(data[1:-dim*value_dim])
print('Finish')
