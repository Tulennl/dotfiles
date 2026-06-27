#!/usr/bin/env bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
NAME="$DIR/screen_$(date +'%Y%m%d_%H%M%S').png"

case "$1" in
    "full")
        if grim "$NAME"; then
            wl-copy < "$NAME"
            notify-send "Screenshot" "Full screen saved and copied" -i "$NAME"
        else
            notify-send "Screenshot Error" "Failed to capture full screen" -i dialog-error
            rm -f "$NAME"
        fi
        ;;
    "area")
        GEOM=$(slurp)
        if [ -z "$GEOM" ]; then
            exit 0
        fi
        if grim -g "$GEOM" "$NAME" && [ -s "$NAME" ]; then
            wl-copy < "$NAME"
            notify-send "Screenshot" "Screen area saved and copied" -i "$NAME"
        else
            notify-send "Screenshot Error" "Failed to capture area" -i dialog-error
            rm -f "$NAME"
        fi
        ;;
esac
