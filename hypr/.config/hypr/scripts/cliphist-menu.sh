#!/usr/bin/env bash

for cmd in cliphist rofi wl-copy; do
    if ! command -v "$cmd" &>/dev/null; then
        notify-send "Clipboard Error" "Required command not found: $cmd" -i dialog-error
        exit 1
    fi
done

ROFI_THEME="$HOME/.config/rofi/cliphist.rasi"

selected=$(cliphist list | rofi -dmenu -theme "$ROFI_THEME" -p "󰅍 Search")

if [ -n "$selected" ]; then
    if echo "$selected" | cliphist decode | wl-copy; then
        notify-send "Clipboard" "Item copied to clipboard" -i edit-paste
    else
        notify-send "Clipboard Error" "Failed to copy item" -i dialog-error
    fi
fi
