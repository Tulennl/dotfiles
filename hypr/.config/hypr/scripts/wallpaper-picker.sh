#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper_thumbs"
ROFI_THEME="$HOME/.config/rofi/wallpapers.rasi"

mkdir -p "$THUMB_DIR"

if [ ! -d "$WALL_DIR" ]; then
    notify-send "Error" "Wallpaper folder not found!"
    exit 1
fi

cd "$WALL_DIR" || exit 1
shopt -s nullglob
images=( *.{jpg,jpeg,png,webp} )

if [ ${#images[@]} -eq 0 ]; then
    notify-send "Gallery" "No images found in the folder"
    exit 1
fi

rofi_input=""
for img in "${images[@]}"; do
    thumb="$THUMB_DIR/$img"
    if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
        if ! convert "$img" -thumbnail 300x200^ -gravity center -extent 300x200 "$thumb" 2>/dev/null; then
            continue
        fi
    fi
    rofi_input+="$img\0icon\x1f$thumb\n"
done

selected=$(echo -en "$rofi_input" | rofi -dmenu \
    -theme "$ROFI_THEME" \
    -p "Gallery" \
    -placeholder "Search Wallpaper...")

if [ -n "$selected" ]; then
    target_wall="$WALL_DIR/$selected"
    
    echo "$target_wall" > "$HOME/.cache/current_wallpaper"
    
    wallpaper_set=false

    if pgrep -x "awww" > /dev/null || pgrep -x "awww-daemon" > /dev/null; then
        if awww img "$target_wall" --transition-type "wipe" --transition-fps 75 --transition-angle 30; then
            wallpaper_set=true
        fi
    elif pgrep -x "swww-daemon" > /dev/null; then
        if swww img "$target_wall" --transition-type "wipe" --transition-fps 75 --transition-angle 30; then
            wallpaper_set=true
        fi
    elif pgrep -x "hyprpaper" > /dev/null; then
        if hyprctl hyprpaper preload "$target_wall" && hyprctl hyprpaper wallpaper ",$target_wall"; then
            wallpaper_set=true
        fi
    else
        notify-send "Wallpaper Error" "No wallpaper daemon running" -i dialog-error
    fi

    if $wallpaper_set; then
        notify-send "Wallpaper Changed" "$selected" -i "$THUMB_DIR/$selected"
    else
        notify-send "Wallpaper Error" "Failed to set wallpaper" -i dialog-error
    fi
fi
