#!/usr/bin/env bash

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="$STATE_DIR/recording_status"
DIR="$HOME/Videos/Recordings"
mkdir -p "$DIR"

update_waybar() {
    pkill -RTMIN+9 waybar
}

case "$1" in
    "toggle")
        if pgrep -x "wf-recorder" > /dev/null; then
            CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null)
            
            if [ "$CURRENT_STATE" = "paused" ]; then
                pkill -CONT wf-recorder
                sleep 0.1
            fi
            
            pkill -INT wf-recorder
            rm -f "$STATE_FILE"
            notify-send "Screen Record" "Recording successfully stopped and saved" -i video-x-generic
            update_waybar
        else
            NAME="$DIR/rec_$(date +'%Y%m%d_%H%M%S').mp4"
            notify-send "Screen Record" "Select an area to record..." -i video-x-generic
            
            GEOM=$(slurp)
            if [ -z "$GEOM" ]; then
                exit 0
            fi
            
            wf-recorder -c libx264 -p yuv420p -g "$GEOM" -f "$NAME" &
            echo "recording" > "$STATE_FILE"
            update_waybar
        fi
        ;;
        
    "pause")
        if pgrep -x "wf-recorder" > /dev/null; then
            CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null)
            
            if [ "$CURRENT_STATE" = "paused" ]; then
                pkill -CONT wf-recorder
                echo "recording" > "$STATE_FILE"
                notify-send "Screen Record" "Recording resumed" -i video-x-generic
            else
                pkill -STOP wf-recorder
                echo "paused" > "$STATE_FILE"
                notify-send "Screen Record" "Recording paused" -i video-x-generic
            fi
            update_waybar
        fi
        ;;
        
    "status")
        if ! pgrep -x "wf-recorder" > /dev/null; then
            rm -f "$STATE_FILE"
            echo '{"text": "", "class": "none"}'
        else
            CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null)
            if [ "$CURRENT_STATE" = "paused" ]; then
                echo '{"text": "󰏤", "class": "paused", "tooltip": "Recording paused\nLMB: Resume\nRMB: Stop"}'
            else
                echo '{"text": "", "class": "recording", "tooltip": "Recording screen\nLMB: Pause\nRMB: Stop"}'
            fi
        fi
        ;;
esac
