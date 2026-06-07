#!/bin/bash

shutdown="󰐥 Shutdown"
reboot="󰜉 Reboot"
suspend="󰤄 Suspend"
lock="󰌾 Lock"
logout="󰍃 Logout"

options="$shutdown\n$reboot\n$suspend\n$lock\n$logout"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "System Power" -theme ~/.config/rofi/powermenu.rasi)

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
