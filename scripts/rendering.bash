seq 8 | xargs -t -P8 -n1 pvpython screenshot.py 
ffmpeg -r 20 -i animh%04d.png -vcodec libx264 -pix_fmt yuv420p -r 60 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" ../animj.mp4