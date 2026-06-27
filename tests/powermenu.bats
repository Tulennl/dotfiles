#!/usr/bin/env bats

load test_helper

setup() {
    setup_sandbox
    mock_command_log "systemctl" 0
    mock_command_log "hyprlock" 0
    mock_command_log "hyprctl" 0
    mock_command "swaylock" 0
}

teardown() {
    teardown_sandbox
}

@test "powermenu: shutdown calls systemctl poweroff" {
    mock_command "rofi" 0 "󰐥 Shutdown"

    run bash "$SCRIPTS_DIR/powermenu.sh"

    [ "$status" -eq 0 ]
    [[ "$(mock_log systemctl)" == *"poweroff"* ]]
}

@test "powermenu: reboot calls systemctl reboot" {
    mock_command "rofi" 0 "󰜉 Reboot"

    run bash "$SCRIPTS_DIR/powermenu.sh"

    [ "$status" -eq 0 ]
    [[ "$(mock_log systemctl)" == *"reboot"* ]]
}

@test "powermenu: suspend calls systemctl suspend" {
    mock_command "rofi" 0 "󰤄 Suspend"

    run bash "$SCRIPTS_DIR/powermenu.sh"

    [ "$status" -eq 0 ]
    [[ "$(mock_log systemctl)" == *"suspend"* ]]
}

@test "powermenu: lock invokes hyprlock" {
    mock_command "rofi" 0 "󰌾 Lock"

    run bash "$SCRIPTS_DIR/powermenu.sh"

    [ "$status" -eq 0 ]
    [ -f "$TEST_HOME/.mock_hyprlock_log" ]
}

@test "powermenu: logout calls hyprctl dispatch exit" {
    mock_command "rofi" 0 "󰍃 Logout"

    run bash "$SCRIPTS_DIR/powermenu.sh"

    [ "$status" -eq 0 ]
    local log
    log="$(mock_log hyprctl)"
    [[ "$log" == *"dispatch"* ]]
    [[ "$log" == *"exit"* ]]
}

@test "powermenu: no selection exits cleanly" {
    mock_command "rofi" 0 ""

    run bash "$SCRIPTS_DIR/powermenu.sh"

    [ "$status" -eq 0 ]
}
