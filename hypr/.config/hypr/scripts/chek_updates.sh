#!/bin/bash

official_updates=$(checkupdates 2>/dev/null)
aur_updates=$(yay -Qua 2>/dev/null)

count_official=$(echo "$official_updates" | grep -v '^$' | wc -l)
count_aur=$(echo "$aur_updates" | grep -v '^$' | wc -l)
total_count=$((count_official + count_aur))

if [ "$total_count" -gt 0 ]; then
    echo "{\"text\": \"󰚰 $total_count\", \"tooltip\": \"Official: $count_official\nAUR: $count_aur\", \"class\": \"pending\"}"
else
    echo "{\"text\": \"󰄬 0\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
