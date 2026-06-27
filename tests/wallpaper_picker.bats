#!/usr/bin/env bats

load test_helper

setup() {
    setup_sandbox
    mock_command "notify-send" 0
    mock_command "rofi" 0 ""
    mock_command "convert" 0
    mock_command_log "awww" 0
    mock_command_log "swww" 0
    mock_command_log "hyprctl" 0
    mock_pgrep_none
}

teardown() {
    teardown_sandbox
}

# ---------------------------------------------------------------------------
# Precondition checks
# ---------------------------------------------------------------------------

@test "wallpaper-picker: exits 1 when wallpaper directory does not exist" {
    rm -rf "$TEST_HOME/Pictures/Wallpapers"

    run bash "$SCRIPTS_DIR/wallpaper-picker.sh"

    [ "$status" -eq 1 ]
}

@test "wallpaper-picker: exits 1 when wallpaper directory is empty" {
    run bash "$SCRIPTS_DIR/wallpaper-picker.sh"

    [ "$status" -eq 1 ]
}

@test "wallpaper-picker: creates thumbnail cache directory" {
    rm -rf "$TEST_HOME/.cache/wallpaper_thumbs"
    touch "$TEST_HOME/Pictures/Wallpapers/bg.png"

    run bash "$SCRIPTS_DIR/wallpaper-picker.sh"

    [ -d "$TEST_HOME/.cache/wallpaper_thumbs" ]
}

# ---------------------------------------------------------------------------
# Wallpaper backend detection (awww / swww / hyprpaper)
# ---------------------------------------------------------------------------

@test "wallpaper-picker: uses awww when awww-daemon is running" {
    touch "$TEST_HOME/Pictures/Wallpapers/test.png"
    mock_pgrep_for "awww-daemon"
    # rofi returns the selected wallpaper name
    mock_command "rofi" 0 "test.png"

    run bash "$SCRIPTS_DIR/wallpaper-picker.sh"

    [ "$status" -eq 0 ]
    [[ "$(mock_log awww)" == *"test.png"* ]]
}

@test "wallpaper-picker: uses swww when swww-daemon is running" {
    touch "$TEST_HOME/Pictures/Wallpapers/test.jpg"
    mock_pgrep_for "swww-daemon"
    mock_command "rofi" 0 "test.jpg"

    run bash "$SCRIPTS_DIR/wallpaper-picker.sh"

    [ "$status" -eq 0 ]
    [[ "$(mock_log swww)" == *"test.jpg"* ]]
}

@test "wallpaper-picker: uses hyprpaper when hyprpaper is running" {
    touch "$TEST_HOME/Pictures/Wallpapers/wall.jpeg"
    mock_pgrep_for "hyprpaper"
    mock_command "rofi" 0 "wall.jpeg"

    run bash "$SCRIPTS_DIR/wallpaper-picker.sh"

    [ "$status" -eq 0 ]
    local log
    log="$(mock_log hyprctl)"
    [[ "$log" == *"hyprpaper"* ]]
    [[ "$log" == *"wall.jpeg"* ]]
}

# ---------------------------------------------------------------------------
# Wallpaper cache file
# ---------------------------------------------------------------------------

@test "wallpaper-picker: saves selected wallpaper path to cache file" {
    touch "$TEST_HOME/Pictures/Wallpapers/bg.webp"
    mock_pgrep_for "awww"
    mock_command "rofi" 0 "bg.webp"

    run bash "$SCRIPTS_DIR/wallpaper-picker.sh"

    [ "$status" -eq 0 ]
    [ -f "$TEST_HOME/.cache/current_wallpaper" ]
    [[ "$(cat "$TEST_HOME/.cache/current_wallpaper")" == *"bg.webp"* ]]
}

# ---------------------------------------------------------------------------
# No selection
# ---------------------------------------------------------------------------

@test "wallpaper-picker: does nothing when rofi selection is empty" {
    touch "$TEST_HOME/Pictures/Wallpapers/bg.png"
    mock_command "rofi" 0 ""

    run bash "$SCRIPTS_DIR/wallpaper-picker.sh"

    [ "$status" -eq 0 ]
    [ ! -f "$TEST_HOME/.cache/current_wallpaper" ]
}
