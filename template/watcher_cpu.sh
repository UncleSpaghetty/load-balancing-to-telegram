#!/bin/bash
# partial code by Paul Colby (http://colby.id.au), no rights reserved

PREV_TOTAL=0
PREV_IDLE=0
last_count=0

. ../tokens.sh

. ../costants.sh

while true; do
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

    echo ${DIFF_USAGE}%
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

    # Wait before checking again.
    sleep 1
done
