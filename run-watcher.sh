ps aux | grep main.py | awk '{print $2}' | xargs kill -9 2>/dev/null
nohup ./watcher.sh >/dev/null 2>&1 & 
