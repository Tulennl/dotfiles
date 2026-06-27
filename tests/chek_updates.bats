#!/usr/bin/env bats

load test_helper

setup() {
    setup_sandbox
}

teardown() {
    teardown_sandbox
}

# ---------------------------------------------------------------------------
# JSON output
# ---------------------------------------------------------------------------

@test "chek_updates: zero updates emits updated JSON" {
    mock_command "checkupdates" 0 ""
    mock_command "yay" 0 ""

    run bash "$SCRIPTS_DIR/chek_updates.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *'"text": "󰄬 0"'* ]]
    [[ "$output" == *'"class": "updated"'* ]]
    [[ "$output" == *'System up to date'* ]]
}

@test "chek_updates: official-only updates emits pending JSON with correct count" {
    mock_command "checkupdates" 0 "linux 6.9.1-1 -> 6.9.2-1
mesa 24.0.8-1 -> 24.1.0-1"
    mock_command "yay" 0 ""

    run bash "$SCRIPTS_DIR/chek_updates.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *'"text": "󰚰 2"'* ]]
    [[ "$output" == *'"class": "pending"'* ]]
    [[ "$output" == *'Official: 2'* ]]
    [[ "$output" == *'AUR: 0'* ]]
}

@test "chek_updates: AUR-only updates emits pending JSON" {
    mock_command "checkupdates" 0 ""
    mock_command "yay" 0 "aur-pkg 1.0-1 -> 1.1-1"

    run bash "$SCRIPTS_DIR/chek_updates.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *'"text": "󰚰 1"'* ]]
    [[ "$output" == *'Official: 0'* ]]
    [[ "$output" == *'AUR: 1'* ]]
}

@test "chek_updates: mixed official + AUR updates" {
    mock_command "checkupdates" 0 "pkg-a 1-1 -> 2-1
pkg-b 1-1 -> 2-1
pkg-c 1-1 -> 2-1"
    mock_command "yay" 0 "aur-x 1-1 -> 2-1
aur-y 1-1 -> 2-1"

    run bash "$SCRIPTS_DIR/chek_updates.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *'"text": "󰚰 5"'* ]]
    [[ "$output" == *'Official: 3'* ]]
    [[ "$output" == *'AUR: 2'* ]]
}

@test "chek_updates: handles checkupdates failure gracefully" {
    mock_command "checkupdates" 2 ""
    mock_command "yay" 0 ""

    run bash "$SCRIPTS_DIR/chek_updates.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *'"class": "updated"'* ]]
}

@test "chek_updates: output is valid JSON-ish (has braces)" {
    mock_command "checkupdates" 0 ""
    mock_command "yay" 0 ""

    run bash "$SCRIPTS_DIR/chek_updates.sh"

    [[ "$output" == "{"* ]]
    [[ "$output" == *"}" ]]
}
