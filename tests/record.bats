#!/usr/bin/env bats

load test_helper

setup() {
    setup_sandbox
    rm -f /tmp/recording_status
    mock_command "notify-send" 0
    mock_command "slurp" 0 "0,0 1920x1080"
    mock_command "wf-recorder" 0
    mock_command_log "pkill" 0
    mock_command "waybar" 0
}

teardown() {
    rm -f /tmp/recording_status
    teardown_sandbox
}

# ---------------------------------------------------------------------------
# status subcommand
# ---------------------------------------------------------------------------

@test "record status: no recorder running emits empty JSON and cleans stale state file" {
    mock_pgrep_none
    echo "recording" > /tmp/recording_status

    run bash "$SCRIPTS_DIR/record.sh" status

    [ "$status" -eq 0 ]
    [[ "$output" == *'"text": ""'* ]]
    [[ "$output" == *'"class": "none"'* ]]
    [ ! -f /tmp/recording_status ]
}

@test "record status: active recording returns recording JSON" {
    mock_pgrep_for "wf-recorder"
    echo "recording" > /tmp/recording_status

    run bash "$SCRIPTS_DIR/record.sh" status

    [ "$status" -eq 0 ]
    [[ "$output" == *'"class": "recording"'* ]]
}

@test "record status: paused recording returns paused JSON" {
    mock_pgrep_for "wf-recorder"
    echo "paused" > /tmp/recording_status

    run bash "$SCRIPTS_DIR/record.sh" status

    [ "$status" -eq 0 ]
    [[ "$output" == *'"class": "paused"'* ]]
    [[ "$output" == *'Recording paused'* ]]
}

# ---------------------------------------------------------------------------
# toggle subcommand – start recording
# ---------------------------------------------------------------------------

@test "record toggle: starts recording when no recorder is running" {
    mock_pgrep_none

    run bash "$SCRIPTS_DIR/record.sh" toggle

    [ "$status" -eq 0 ]
    [ -f /tmp/recording_status ]
    [ "$(cat /tmp/recording_status)" = "recording" ]
}

@test "record toggle: creates Videos/Recordings directory" {
    mock_pgrep_none
    rm -rf "$TEST_HOME/Videos/Recordings"

    run bash "$SCRIPTS_DIR/record.sh" toggle

    [ -d "$TEST_HOME/Videos/Recordings" ]
}

# ---------------------------------------------------------------------------
# toggle subcommand – stop recording
# ---------------------------------------------------------------------------

@test "record toggle: stops recorder when one is already running" {
    mock_pgrep_for "wf-recorder"
    echo "recording" > /tmp/recording_status

    run bash "$SCRIPTS_DIR/record.sh" toggle

    [ "$status" -eq 0 ]
    [ ! -f /tmp/recording_status ]
    # pkill should have been called with -INT
    [[ "$(mock_log pkill)" == *"-INT wf-recorder"* ]]
}

@test "record toggle: resumes paused recorder before stopping" {
    mock_pgrep_for "wf-recorder"
    echo "paused" > /tmp/recording_status

    run bash "$SCRIPTS_DIR/record.sh" toggle

    [ "$status" -eq 0 ]
    [ ! -f /tmp/recording_status ]
    # Should have sent CONT before INT
    local log
    log="$(mock_log pkill)"
    [[ "$log" == *"-CONT wf-recorder"* ]]
    [[ "$log" == *"-INT wf-recorder"* ]]
}

# ---------------------------------------------------------------------------
# pause subcommand
# ---------------------------------------------------------------------------

@test "record pause: pauses active recording" {
    mock_pgrep_for "wf-recorder"
    echo "recording" > /tmp/recording_status

    run bash "$SCRIPTS_DIR/record.sh" pause

    [ "$status" -eq 0 ]
    [ "$(cat /tmp/recording_status)" = "paused" ]
    [[ "$(mock_log pkill)" == *"-STOP wf-recorder"* ]]
}

@test "record pause: resumes paused recording" {
    mock_pgrep_for "wf-recorder"
    echo "paused" > /tmp/recording_status

    run bash "$SCRIPTS_DIR/record.sh" pause

    [ "$status" -eq 0 ]
    [ "$(cat /tmp/recording_status)" = "recording" ]
    [[ "$(mock_log pkill)" == *"-CONT wf-recorder"* ]]
}

@test "record pause: no-op when recorder is not running" {
    mock_pgrep_none

    run bash "$SCRIPTS_DIR/record.sh" pause

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# ---------------------------------------------------------------------------
# edge cases
# ---------------------------------------------------------------------------

@test "record toggle: aborts if slurp returns empty geometry" {
    mock_pgrep_none
    mock_command "slurp" 0 ""

    run bash "$SCRIPTS_DIR/record.sh" toggle

    [ "$status" -eq 0 ]
    [ ! -f /tmp/recording_status ]
}

@test "record: no argument produces no output and exits cleanly" {
    mock_pgrep_none

    run bash "$SCRIPTS_DIR/record.sh"

    [ "$status" -eq 0 ]
}
