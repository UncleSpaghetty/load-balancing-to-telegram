#!/bin/bash

PREV_TOTAL=0
PREV_IDLE=0
disk_last_count=0

. ./tokens.sh

. ./costants.sh

while true; do

    # Get the total DISK statistics, i.e. user + system + idle.
    user=$(iostat --dec=0 -x | grep -A1 'avg-cpu' | tail -1 | awk '{print $1}')
    system=$(iostat --dec=0 -x | grep -A1 'avg-cpu' | tail -1 | awk '{print $3}')
    idle=$(iostat --dec=0 -x | grep -A1 'avg-cpu' | tail -1 | awk '{print $6}')

    # echo -e "User: $user%\nSystem: $system%\nIdle: $idle%"

    # SUM up all the disk statistics.
    for i in $(iostat --dec=0 -x | grep -A1 'avg-cpu' -1 | tail -1); do
        diskave=$(($diskave+$i))
    done
    
    # Calculate the average disk statistics, removing the idle.
    diskave=$(($diskave-$idle))
    echo -e "Disk average: $diskave%"

    diskcount=0
    disk_now_time=$(date -d "now" +%s)    # +%s turns time to epoch
    disk_end_time=$disk_now_time

    # SETUP DISK TIMEFRAME
    let "disk_end_time=$disk_now_time+$DISK_CHECK_TIMEFRAME"

    if [ $disk_last_count -gt 0 ]; then
        disk_end_time="$disk_tmp_time"
    fi

    if [ $disk_now_time -ge $disk_end_time ]; then
        echo "Time expired 1"
        let "disk_last_count=0"
        let "disk_tmp_total=0"
    fi

    if [ $diskave -gt $DISK_PERCENTAGE_CAP ]; then
        let "diskcount=$disk_last_count+1"
        let "disk_start_time=$(date -d "now" +%s)"
        # echo -e "Disk count: $diskcount\nDisk last count: $disk_last_count"

        disk_tmp_value=$diskave
        let "disk_tmp_total=$disk_tmp_total+$disk_tmp_value"
        let "disk_tmp_average=$disk_tmp_total/$diskcount"
        if [ $diskcount -lt $DISK_CHECK_COUNTER ]; then
            disk_tmp_time=$disk_end_time
        else
            echo -e "TELEGRAM"
            let "disk_last_count=0"
            let "disk_tmp_total=0"
            let "diskcount=$disk_last_count"
        fi
        let "disk_last_count=$diskcount"
    fi

    diskave=0
    sleep 1
    
done
