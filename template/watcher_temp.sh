#!/bin/bash

temp_last_count=0

. ./tokens.sh

. ./costants.sh

while true; do

    # total temperature in celsius
    templist=$(cat /sys/class/thermal/thermal_zone*/temp)
    
    for temp in $templist; do
        temp=${temp::-3}
        temptotal=$(($temptotal+$temp))
        tempcount=$(cat /sys/class/thermal/thermal_zone*/temp | wc -l)
        tempaverage=$(($temptotal/$tempcount))
    done

    temptotal=0
    echo -e "Temperature: $tempaverage°C\n"

    temp_tmp_count=0

    temp_now_time=$(date -d "now" +%s)    # +%s turns time to epoch
    temp_end_time=$temp_now_time

    # SETUP TEMP TIMEFRAME
    let "temp_end_time=$temp_now_time+$TEMP_CHECK_TIMEFRAME"

    # check if the last count is greater than 0
    # so we can use the last timeframe
    if [ $temp_last_count -gt 0 ]; then
        temp_end_time="$temp_tmp_time"
    fi

    if [ $temp_now_time -ge $temp_end_time ]; then
        # echo "TEMP Time expired code:1"
        let "temp_last_count=0"
        let "temp_tmp_total=0"
        let "temp_end_time=$temp_now_time+$TEMP_CHECK_TIMEFRAME"
    fi

    if [ $tempaverage -gt $TEMP_PERCENTAGE_CAP ]; then
        let "temp_tmp_count=$temp_last_count+1"
        let "temp_start_time=$(date -d "now" +%s)"
        # echo -e "tempcount: $temp_tmp_count\ntemp last count: $temp_last_count"
        
        temp_tmp_value=$tempaverage
        let "temp_tmp_total=$temp_tmp_total+$temp_tmp_value"
        let "temp_tmp_average=$temp_tmp_total/$temp_tmp_count"
        if [ $temp_tmp_count -lt $TEMP_CHECK_COUNTER ]; then
            temp_tmp_time=$temp_end_time
        else
            echo -e "TELEGRAM\nMESSAGE"
            TEXT="~~~~Temperature is over $TEMP_PERCENTAGE_CAP~~~~ Temperature average: $temp_tmp_average°C"
            curl "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$CHANNEL_ID&text=$TEXT"
            let "temp_last_count=0"
            let "temp_tmp_total=0"
            let "temp_tmp_count=$temp_last_count"
        fi
        let "temp_last_count=$temp_tmp_count"
    fi
    
    sleep 1
    
done
