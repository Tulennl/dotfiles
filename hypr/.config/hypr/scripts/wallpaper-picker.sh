#!/usr/bin/env bash

source "$(dirname "$0")/lib/utils.sh"

WALL_DIR="$HOME/Pictures/Wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper_thumbs"
ROFI_THEME="$HOME/.config/rofi/wallpapers.rasi"

ensure_dir "$THUMB_DIR"

if [ ! -d "$WALL_DIR" ]; then
    notify "Error" "Wallpaper folder not found!"
    exit 1
fi

cd "$WALL_DIR" || exit 1
shopt -s nullglob
images=( *.{jpg,jpeg,png,webp} )

if [ ${#images[@]} -eq 0 ]; then
    notify "Gallery" "No images found in the folder"
    exit 1
fi

rofi_input=""
for img in "${images[@]}"; do
    thumb="$THUMB_DIR/$img"
    if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
        convert "$img" -thumbnail 300x200^ -gravity center -extent 300x200 "$thumb"
    fi
    rofi_input+="$img\0icon\x1f$thumb\n"
done

selected=$(echo -en "$rofi_input" | rofi_menu "$ROFI_THEME" "Gallery" -placeholder "Search Wallpaper...")

if [ -n "$selected" ]; then
    target_wall="$WALL_DIR/$selected"
    
    echo "$target_wall" > "$HOME/.cache/current_wallpaper"
    
    if pgrep -x "awww" > /dev/null || pgrep -x "awww-daemon" > /dev/null; then
        awww img "$target_wall" --transition-type "wipe" --transition-fps 75 --transition-angle 30
    
    elif pgrep -x "swww-daemon" > /dev/null; then
        swww img "$target_wall" --transition-type "wipe" --transition-fps 75 --transition-angle 30
    
    elif pgrep -x "hyprpaper" > /dev/null; then
        hyprctl hyprpaper preload "$target_wall"
        hyprctl hyprpaper wallpaper ",$target_wall"
    fi
    
    notify "Wallpaper Changed" "$selected" "$THUMB_DIR/$selected"
fi
