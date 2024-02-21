ps aux | grep watcher.sh | awk '{print $2}' | xargs kill -9 2>/dev/null
nohup ./watcher.sh >/dev/null 2>&1 & 
