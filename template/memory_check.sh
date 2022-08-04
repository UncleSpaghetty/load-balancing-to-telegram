#!/bin/bash

while true ; do
    #check memory usage percentage
    MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
    echo "Memory usage: $MEMORY_USAGE"
    sleep 1
done
