#!/bin/bash

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
    echo -e "Average temperature: $tempaverage°C"
    
    sleep 1
done
