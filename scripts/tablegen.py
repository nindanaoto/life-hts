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
            "both":{"time":[],"step":},
            "ferro":{"time":[],"step":},
            "super":{"time":[],"step":}
        },
        "nonrelax":{
            "both":{"time":[37729.9],"step":},
            "ferro":{"time":[],"step":},
            "super":{"time":[],"step":}
        }
    },
    "twist":{
        "relax":{
            "both":{"time":[26575.1,26398.7,26583.2],"step":122},
            "ferro":{"time":[6198.72,6229.56,6212.87],"step":100},
            "super":{"time":[13797,13820,13828.1],"step":100}
        },
        "nonrelax":{
            "both":{"time":[142339],"step":2493},
            "ferro":{"time":[100813],"step":1531},
            "super":{"time":[8485.52,8534.76],"step":119}
        }
    }
}