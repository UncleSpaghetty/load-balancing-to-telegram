#!/bin/bash

ram_last_count=0

. ./tokens.sh

. ./costants.sh

while true; do

    #check memory usage percentage
    MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
    let "MEMORY_USAGE=${MEMORY_USAGE::-4}"
    # echo "Memory usage: $MEMORY_USAGE%"

    ramcount=0
    ram_now_time=$(date -d "now" +%s)    # +%s turns time to epoch
    ram_end_time=$ram_now_time

    # SETUP RAM TIMEFRAME
    let "ram_end_time=$ram_now_time+$RAM_CHECK_TIMEFRAME"

    # check if the last count is greater than 0
    # so we can use the last timeframe    
    if [ $ram_last_count -gt 0 ]; then
        ram_end_time="$ram_tmp_time"
    fi

    if [ $ram_now_time -ge $ram_end_time ]; then
        # echo "RAM Time expired code:1"
        let "ram_last_count=0"
        let "ram_tmp_total=0"
        let "ram_end_time=$ram_now_time+$RAM_CHECK_TIMEFRAME"
    fi
    
    if [ $MEMORY_USAGE -gt $RAM_PERCENTAGE_CAP ]; then
        let "ramcount=$ram_last_count+1"
        let "ram_start_time=$(date -d "now" +%s)"
        # echo -e "ramcount: $ramcount\nram last count: $ram_last_count"
        
        ram_tmp_value=$MEMORY_USAGE
        let "ram_tmp_total=$ram_tmp_total+$ram_tmp_value"
        let "ram_tmp_average=$ram_tmp_total/$ramcount"
        if [ $ramcount -lt $RAM_CHECK_COUNTER ]; then
            ram_tmp_time=$ram_end_time
        else
            echo -e "TELEGRAM\nMESSAGE"
            TEXT="~~~~RAM usage is over $RAM_PERCENTAGE_CAP%~~~~ RAM average: $ram_tmp_average%"
            curl "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$CHANNEL_ID&text=$TEXT"
            let "ram_last_count=0"
            let "ramcount=$ram_last_count"
            let "ram_tmp_total=0"
        fi
        let "ram_last_count=$ramcount"
    fi

    sleep 1
    
done
