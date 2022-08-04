#!/bin/bash

while true; do

    user=$(iostat --dec=0 -x | grep -A1 'avg-cpu' | tail -1 | awk '{print $1}')
    system=$(iostat --dec=0 -x | grep -A1 'avg-cpu' | tail -1 | awk '{print $3}')
    idle=$(iostat --dec=0 -x | grep -A1 'avg-cpu' | tail -1 | awk '{print $6}')

    # echo -e "User: $user%\nSystem: $system%\nIdle: $idle%"

    for i in $(iostat --dec=0 -x | grep -A1 'avg-cpu' -1 | tail -1); do
        diskave=$(($diskave+$i))
    done

    diskave=$(($diskave-$idle))
    echo -e "$diskave%"

    sleep 1
    diskave=0
    
done
