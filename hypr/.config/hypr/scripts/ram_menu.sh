#!/bin/bash

get_top_ram() {
    echo "󰆼 [ OPEN FULL MONITOR (All Processes) ]"
    ps -eo rss,comm | awk 'NR>1 {arr[$2]+=$1} END {for (i in arr) { if (arr[i] > 15360) printf "%7.0f MB  |  %s\n", arr[i]/1024, i }}' | sort -rn | head -n 15
}

selected=$(get_top_ram | rofi -dmenu -i -p "󰍛 RAM" -theme-str 'window {width: 450px;} listview {lines: 16;}')

if [[ -z "$selected" ]]; then
    exit 0
fi

if [[ "$selected" == *"OPEN FULL MONITOR"* ]]; then
    kitty --class btop-float -e btop &
else
    proc_name=$(echo "$selected" | awk -F '|' '{print $2}' | xargs)
    
    ans=$(echo -e "No\nYes" | rofi -dmenu -i -p "Kill $proc_name?" -theme-str 'window {width: 300px;} listview {lines: 2;}')
    
    if [[ "$ans" == "Yes" ]]; then
        if pkill -f "$proc_name"; then
            notify-send "Process Terminated" "$proc_name has been closed" -i dialog-information
        else
            notify-send "Process Error" "Failed to terminate $proc_name" -i dialog-error
        fi
    fi
fi
