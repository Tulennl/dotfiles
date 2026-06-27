#!/bin/bash

has_checkupdates=true
has_yay=true

if ! command -v checkupdates &>/dev/null; then
    has_checkupdates=false
fi
if ! command -v yay &>/dev/null; then
    has_yay=false
fi

if ! $has_checkupdates && ! $has_yay; then
    echo '{"text": "󰚰 ?", "tooltip": "Neither checkupdates nor yay found", "class": "error"}'
    exit 1
fi

official_updates=""
aur_updates=""
errors=""

if $has_checkupdates; then
    official_updates=$(checkupdates 2>&1)
    rc=$?
    # checkupdates exits 0 with updates, 2 when up-to-date
    if [ $rc -ne 0 ] && [ $rc -ne 2 ]; then
        errors="checkupdates failed"
        official_updates=""
    elif [ $rc -eq 2 ]; then
        official_updates=""
    fi
fi

if $has_yay; then
    aur_updates=$(yay -Qua 2>&1)
    rc=$?
    if [ $rc -ne 0 ]; then
        errors="${errors:+$errors; }yay -Qua failed"
        aur_updates=""
    fi
fi

count_official=$(echo "$official_updates" | grep -v '^$' | wc -l)
count_aur=$(echo "$aur_updates" | grep -v '^$' | wc -l)
total_count=$((count_official + count_aur))

if [ -n "$errors" ]; then
    echo "{\"text\": \"󰚰 $total_count?\", \"tooltip\": \"$errors\", \"class\": \"error\"}"
elif [ "$total_count" -gt 0 ]; then
    echo "{\"text\": \"󰚰 $total_count\", \"tooltip\": \"Official: $count_official\nAUR: $count_aur\", \"class\": \"pending\"}"
else
    echo "{\"text\": \"󰄬 0\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
