#!/usr/bin/env bash

source "$(dirname "$0")/lib/utils.sh"

ROFI_THEME="$HOME/.config/rofi/cliphist.rasi"

selected=$(cliphist list | rofi_menu "$ROFI_THEME" "󰅍 Search")

if [ -n "$selected" ]; then
    echo "$selected" | cliphist decode | wl-copy
    notify "Clipboard" "Item copied to clipboard" "edit-paste"
fi
