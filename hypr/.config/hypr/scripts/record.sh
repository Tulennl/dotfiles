#!/usr/bin/env bash

source "$(dirname "$0")/lib/utils.sh"

STATE_FILE="/tmp/recording_status"
DIR="$HOME/Videos/Recordings"
ensure_dir "$DIR"
ICON="video-x-generic"

read_state() {
    cat "$STATE_FILE" 2>/dev/null
}

case "$1" in
    "toggle")
        if pgrep -x "wf-recorder" > /dev/null; then
            if [ "$(read_state)" = "paused" ]; then
                pkill -CONT wf-recorder
                sleep 0.1
            fi
            
            pkill -INT wf-recorder
            rm -f "$STATE_FILE"
            notify "Screen Record" "Recording successfully stopped and saved" "$ICON"
            refresh_waybar 9
        else
            NAME="$DIR/rec_$(timestamp).mp4"
            notify "Screen Record" "Select an area to record..." "$ICON"
            
            GEOM=$(slurp)
            if [ -z "$GEOM" ]; then
                exit 0
            fi
            
            wf-recorder -c libx264 -p yuv420p -g "$GEOM" -f "$NAME" &
            echo "recording" > "$STATE_FILE"
            refresh_waybar 9
        fi
        ;;
        
    "pause")
        if pgrep -x "wf-recorder" > /dev/null; then
            if [ "$(read_state)" = "paused" ]; then
                pkill -CONT wf-recorder
                echo "recording" > "$STATE_FILE"
                notify "Screen Record" "Recording resumed" "$ICON"
            else
                pkill -STOP wf-recorder
                echo "paused" > "$STATE_FILE"
                notify "Screen Record" "Recording paused" "$ICON"
            fi
            refresh_waybar 9
        fi
        ;;
        
    "status")
        if ! pgrep -x "wf-recorder" > /dev/null; then
            rm -f "$STATE_FILE"
            echo '{"text": "", "class": "none"}'
        else
            if [ "$(read_state)" = "paused" ]; then
                echo '{"text": "󰏤", "class": "paused", "tooltip": "Recording paused\nLMB: Resume\nRMB: Stop"}'
            else
                echo '{"text": "", "class": "recording", "tooltip": "Recording screen\nLMB: Pause\nRMB: Stop"}'
            fi
        fi
        ;;
esac
