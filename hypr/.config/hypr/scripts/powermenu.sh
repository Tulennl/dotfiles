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
        systemctl poweroff || notify-send "Power Error" "Failed to power off" -i dialog-error
        ;;
    $reboot)
        systemctl reboot || notify-send "Power Error" "Failed to reboot" -i dialog-error
        ;;
    $suspend)
        systemctl suspend || notify-send "Power Error" "Failed to suspend" -i dialog-error
        ;;
    $lock)
        if ! hyprlock && ! swaylock; then
            notify-send "Lock Error" "Neither hyprlock nor swaylock available" -i dialog-error
        fi
        ;;
    $logout)
        hyprctl dispatch exit || notify-send "Logout Error" "Failed to exit session" -i dialog-error
        ;;
esac
