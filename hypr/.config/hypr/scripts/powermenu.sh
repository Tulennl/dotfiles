#!/usr/bin/env bash

source "$(dirname "$0")/lib/utils.sh"

shutdown="󰐥 Shutdown"
reboot="󰜉 Reboot"
suspend="󰤄 Suspend"
lock="󰌾 Lock"
logout="󰍃 Logout"

options="$shutdown\n$reboot\n$suspend\n$lock\n$logout"

chosen=$(echo -e "$options" | rofi_menu "$HOME/.config/rofi/powermenu.rasi" "System Power" -i)

case $chosen in
    $shutdown)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $suspend)
        systemctl suspend
        ;;
    $lock)
        hyprlock || swaylock
        ;;
    $logout)
        hyprctl dispatch exit
        ;;
esac
