#!/bin/bash
# partial code by Paul Colby (http://colby.id.au), no rights reserved

PREV_TOTAL=0
PREV_IDLE=0

last_count=0
ram_last_count=0
disk_last_count=0
temp_last_count=0

. ./tokens.sh

# echo -e "Bot token: $BOT_TOKEN\nChannel id: $CHANNEL_ID"

. ./costants.sh

echo "CPU CAP: $CPU_PERCENTAGE_CAP%"
echo "RAM CAP: $RAM_PERCENTAGE_CAP%"
echo "DISK CAP: $DISK_PERCENTAGE_CAP%"
echo "TEMP CAP: $TEMP_PERCENTAGE_CAP%"

while true; do

    time=$(date -d "now")
    echo -e "Time: $time"

    ##############################################################################
    #    CPU CHECK
    ##############################################################################

    # Get the total CPU statistics, discarding the 'cpu ' prefix.
    CPU=(`sed -n 's/^cpu\s//p' /proc/stat`)
    IDLE=${CPU[3]} # Just the idle CPU time.

    # Calculate the total CPU time.
    TOTAL=0
    for VALUE in "${CPU[@]}"; do
        let "TOTAL=$TOTAL+$VALUE"
    done

    # Calculate the CPU usage since we last checked.
    let "DIFF_IDLE=$IDLE-$PREV_IDLE"
    let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
    let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"

    echo "CPU usage: ${DIFF_USAGE}%"

    count=0

    now_time=$(date -d "now" +%s)    # +%s turns time to epoch
    end_time=$now_time

    # SETUP TIMEFRAME
    let "end_time+=$CPU_CHECK_TIMEFRAME"
    
    if [ $last_count -gt 0 ]; then
        end_time="$tmp_time"
    fi
    if [ $now_time -ge $end_time ]; then
        echo "Time expired 1"
        let "last_count=0"
        let "tmp_total=0"
    fi

    # echo -e "Count: $last_count\nStart time: $now_time\nEnd time: $end_time"

    #   SETUP CPU% USAGE LIMIT
    if [ $DIFF_USAGE -ge $CPU_PERCENTAGE_CAP ]; then

        let "count=$last_count+1"
        let "start_time=$(date -d "now" +%s)"

        tmp_value=$DIFF_USAGE
        let "tmp_total=$tmp_total+$tmp_value"
        let "tmp_average=$tmp_total/$count"

        #CHECK IF IT IS THE FIRST CYCLE
        if [ $count -gt 1 ]; then
            let "end_time=$tmp_time"
        fi

        # echo -e "Count: $count\nStart time: $start_time\nEnd time: $end_time"

        if [ $count -lt $CPU_CHECK_COUNTER ]; then

            #CHECK IF THE TIMEFRAME IS EXPIRED
            if [ $start_time -ge $end_time ]; then
                # echo "Time expired"
                let "last_count=0"
                let "tmp_total=0"
            fi

            # echo -e "cpu grater than $CPU_PERCENTAGE_CAP\nCounter: $count"
            let "last_count=$count"
            let "tmp_time=$end_time"
        else
            echo -e "TELEGRAM\nMESSAGE"
            TEXT="~~~~CPU usage is over $CPU_PERCENTAGE_CAP%~~~~ CPU average: $tmp_average%"
            curl "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$CHANNEL_ID&text=$TEXT"
            let "last_count=0"
        fi
    fi

    # Remember the total and idle CPU times for the next check.
    PREV_TOTAL="$TOTAL"
    PREV_IDLE="$IDLE"

    ##############################################################################
    #    RAM CHECK
    ##############################################################################

    #check memory usage percentage
    MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
    let "MEMORY_USAGE=${MEMORY_USAGE::-4}"

    echo "Memory usage: $MEMORY_USAGE%"

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

    ##############################################################################
    #    DISK USAGE CHECK
    ##############################################################################

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
            echo -e "TELEGRAM\nMESSAGE"
            TEXT="~~~~DISK usage is over $DISK_PERCENTAGE_CAP%~~~~ DISK average: $disk_tmp_average%"
            curl "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$CHANNEL_ID&text=$TEXT"
            let "disk_last_count=0"
            let "disk_tmp_total=0"
            let "diskcount=$disk_last_count"
        fi
        let "disk_last_count=$diskcount"
    fi

    # Reset disk average
    diskave=0

    ##############################################################################
    #    TEMPERATURE CHECK
    ##############################################################################

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

    # Wait before checking again.
    sleep 1
done
