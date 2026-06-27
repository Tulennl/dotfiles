#!/usr/bin/env bash

source "$(dirname "$0")/lib/utils.sh"

fetch_updates

if [ "$TOTAL_COUNT" -gt 0 ]; then
    echo "{\"text\": \"󰚰 $TOTAL_COUNT\", \"tooltip\": \"Official: $COUNT_OFFICIAL\nAUR: $COUNT_AUR\", \"class\": \"pending\"}"
else
    echo "{\"text\": \"󰄬 0\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
