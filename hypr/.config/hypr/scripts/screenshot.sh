#!/usr/bin/env bash

source "$(dirname "$0")/lib/utils.sh"

DIR="$HOME/Pictures/Screenshots"
ensure_dir "$DIR"
NAME="$DIR/screen_$(timestamp).png"

case "$1" in
    "full")
        grim "$NAME"
        wl-copy < "$NAME"
        notify "Screenshot" "Full screen saved and copied" "$NAME"
        ;;
    "area")
        grim -g "$(slurp)" "$NAME"
        if [ -s "$NAME" ]; then
            wl-copy < "$NAME"
            notify "Screenshot" "Screen area saved and copied" "$NAME"
        else
            rm "$NAME"
        fi
        ;;
esac
