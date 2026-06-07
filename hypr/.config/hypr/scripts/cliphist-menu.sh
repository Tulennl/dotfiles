#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/cliphist.rasi"

selected=$(cliphist list | rofi -dmenu -theme "$ROFI_THEME" -p "󰅍 Search")

if [ -n "$selected" ]; then
    echo "$selected" | cliphist decode | wl-copy
    notify-send "Clipboard" "Item copied to clipboard" -i edit-paste
fi
