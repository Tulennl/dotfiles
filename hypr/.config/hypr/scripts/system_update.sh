#!/usr/bin/env bash

source "$(dirname "$0")/lib/utils.sh"

clear
echo "󰍉 Checking repositories for updates..."

fetch_updates

clean_list=$(cat <(echo "$OFFICIAL_UPDATES") <(echo "$AUR_UPDATES") | sort -u | grep -v '^$')

if [ "$TOTAL_COUNT" -eq 0 ]; then
    echo "󰄲 System is already up to date!"
    sleep 1.5
    exit 0
fi

fzf_list=$(cat <(echo "--> 󰏖 [ FULL SYSTEM UPGRADE (yay -Syu) ] <--") <(echo "$clean_list"))

HEADER_TEXT=$(echo -e "󰏗 INTERACTIVE UPDATE MANAGER\n" \
                      "============================================================\n" \
                      " Navigation : [↑/↓] or [Ctrl-J / Ctrl-K]\n" \
                      " Selection  : [Tab]   - select multiple packages individually\n" \
                      " Action     : [Enter] - install selected (or current line)\n" \
                      " Hotkey     : [Ctrl-A] - IMMEDIATELY UPGRADE ENTIRE SYSTEM\n" \
                      "------------------------------------------------------------\n" \
                      " Available updates: $TOTAL_COUNT (Pacman: $COUNT_OFFICIAL | AUR: $COUNT_AUR)")

fzf_output=$(echo "$fzf_list" | env SHELL=/bin/bash fzf -m \
    --expect=ctrl-a \
    --header="$HEADER_TEXT" \
    --preview="if [ {1} = '-->' ]; then echo 'Syncing databases and performing full system upgrade.'; else pacman -Si {1} 2>/dev/null || yay -Si {1}; fi" \
    --preview-window=right:55%:wrap \
    --prompt="Search package > ")

key_pressed=$(echo "$fzf_output" | head -n 1)
selected_items=$(echo "$fzf_output" | tail -n +2)

if [ "$key_pressed" = "ctrl-a" ] || [[ "$selected_items" == *"--> 󰏖 [ FULL"* ]]; then
    echo -e "\n󰑓 Running FULL system upgrade..."
    yay -Syu
    refresh_waybar 8

elif [ -n "$selected_items" ]; then
    pkg_names=$(echo "$selected_items" | grep -v '-->' | awk '{print $1}' | tr '\n' ' ')
    
    if [ -z "$pkg_names" ]; then
        echo "Canceled."
        exit 0
    fi

    echo -e "\nPackages selected for installation:"
    echo -e "\033[0;32m$pkg_names\033[0m\n"
    
    echo -n "Upgrade only these packages? (y/N): "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        yay -Sy $pkg_names
        refresh_waybar 8
    fi
else
    echo "Upgrade canceled."
fi

echo -e "\nProcess completed. Press any key to close the window."
read -n 1
