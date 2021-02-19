#!/bin/python3

import statistics as stat

data = {
    "2d":{
        "relax":{
            "both":{"time":[648.28,649.155,668.538],"step":102},
            "ferro":{"time":[254.013,256.828,257.214],"step":100},
            "super":{"time":[334.309,353.904,333.609],"step":102}
        },
        "nonrelax":{
            "both":{"time":[4476.89,4455.78,4470.47],"step":2874},
            "ferro":{"time":[2712.67,2692.32,2687.44],"step":1828},
            "super":{"time":[177.866,177.222,177.434],"step":100}
        }
    },
    "straight":{
        "relax":{
            "both":{"time":[22604.5,22743.9,24172.9],"step":113},
            "ferro":{"time":[6670.33,6663.87,6658.72],"step":100},
            "super":{"time":[14415.8,14354,14472.6],"step":100}
        },
        "nonrelax":{
            "both":{"time":[37729.9,37528.9,37581.7],"step":635},
            "ferro":{"time":[25180.5,24595,24454.7],"step":512},
            "super":{"time":[6326.48,6298.95,6233.1],"step":100}
        }
    },
    "twist":{
        "relax":{
            "both":{"time":[26575.1,26398.7,26583.2],"step":122},
            "ferro":{"time":[6198.72,6229.56,6212.87],"step":100},
            "super":{"time":[13797,13820,13828.1],"step":100}
        },
        "nonrelax":{
            "both":{"time":[142339,141778,140961],"step":2493},
            "ferro":{"time":[100813,101289,100959],"step":1531},
            "super":{"time":[8485.52,8534.76,8551.8],"step":119}
        }
    }
}

physical_model = [["both","両方"],["super","超伝導体のみ"],["ferro","磁性体のみ"]]
geometry_model = [["2d","2次元モデル"],["straight","直線モデル"],["twist","ツイモスト線モデル"]]
relaxation = [["nonrelax","緩和法なし"],["relax","緩和法あり"]]

print("\\toprule")
print("緩和法&なし&あり\\\\")
print("\\midrule")
for geo in geometry_model:
    for phys in physical_model:
        linestr = geo[1]+'/'+phys[1]+'&'
        for relax in relaxation:
            datum = data[geo[0]][relax[0]][phys[0]]
            linestr += "$"+str(stat.mean(datum["time"]))+"\\pm"+str(stat.stdev((datum["time"])))+'('+str(+datum["step"])+')$&'
        linestr=linestr[:-1]
        linestr+='\\\\'
        print(linestr)
print("\\bottomrule")

print("反復法")
# lgmres = {"time":[21437.2,21269.6,21126.3],"step":114,"memory":[123.461,128.453,128.672]}
lgmres = {"time":[22023,21881.6,21989],"step":102,"memory":[124.672,124.543,122.629]}
gmres = {"time":[34572.9,34340.2,34927.7],"step":100,"memory":[120.906,124.398,122.395]}
directmem = [1057.43,965.535,993.309]
print("GMRES&$"+str(stat.mean(gmres["time"]))+"\pm"+str(stat.stdev((gmres["time"])))+"("+str(gmres["step"])+")$\\\\")
print("LGMRES&$"+str(stat.mean(lgmres["time"]))+"\pm"+str(stat.stdev((lgmres["time"])))+"("+str(lgmres["step"])+")$\\\\")
print(str(stat.mean(directmem))+"\pm"+str(stat.stdev(directmem))+"$&$"+str(stat.mean(gmres["memory"]))+"\pm"+str(stat.stdev((gmres["memory"])))+"$&$"+str(stat.mean(lgmres["memory"]))+"\pm"+str(stat.stdev((lgmres["memory"])))+"$")