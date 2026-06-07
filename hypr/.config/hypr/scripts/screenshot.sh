#!/usr/bin/env bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
NAME="$DIR/screen_$(date +'%Y%m%d_%H%M%S').png"

case "$1" in
    "full")
        grim "$NAME"
        wl-copy < "$NAME"
        notify-send "Screenshot" "Full screen saved and copied" -i "$NAME"
        ;;
    "area")
        grim -g "$(slurp)" "$NAME"
        if [ -s "$NAME" ]; then
            wl-copy < "$NAME"
            notify-send "Screenshot" "Screen area saved and copied" -i "$NAME"
        else
            rm "$NAME"
        fi
        ;;
esac
