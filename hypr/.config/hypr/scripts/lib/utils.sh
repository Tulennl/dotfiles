#!/usr/bin/env bash
#
# Shared utility functions for Hyprland scripts.
# Source this file: source "$(dirname "$0")/lib/utils.sh"

# --- Directory & file helpers ---

ensure_dir() {
    mkdir -p "$1"
}

timestamp() {
    date +'%Y%m%d_%H%M%S'
}

# --- Notifications ---

notify() {
    local title="$1" body="$2" icon="${3:-}"
    if [ -n "$icon" ]; then
        notify-send "$title" "$body" -i "$icon"
    else
        notify-send "$title" "$body"
    fi
}

# --- Waybar ---

refresh_waybar() {
    local signal="$1"
    pkill -SIGRTMIN+"$signal" waybar
}

# --- Package updates ---

fetch_updates() {
    OFFICIAL_UPDATES=$(checkupdates 2>/dev/null)
    AUR_UPDATES=$(yay -Qua 2>/dev/null)

    COUNT_OFFICIAL=$(echo "$OFFICIAL_UPDATES" | grep -v '^$' | wc -l)
    COUNT_AUR=$(echo "$AUR_UPDATES" | grep -v '^$' | wc -l)
    TOTAL_COUNT=$((COUNT_OFFICIAL + COUNT_AUR))
}

# --- Rofi helpers ---

rofi_menu() {
    local theme="$1" prompt="$2"
    shift 2
    rofi -dmenu -theme "$theme" -p "$prompt" "$@"
}
