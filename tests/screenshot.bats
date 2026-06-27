#!/usr/bin/env bats

load test_helper

setup() {
    setup_sandbox
    mock_command_log "grim" 0
    mock_command_log "wl-copy" 0
    mock_command "notify-send" 0
    mock_command "slurp" 0 "100,100 500x300"
}

teardown() {
    teardown_sandbox
}

# ---------------------------------------------------------------------------
# Directory creation
# ---------------------------------------------------------------------------

@test "screenshot: creates Screenshots directory if missing" {
    rm -rf "$TEST_HOME/Pictures/Screenshots"

    run bash "$SCRIPTS_DIR/screenshot.sh" full

    [ -d "$TEST_HOME/Pictures/Screenshots" ]
}

# ---------------------------------------------------------------------------
# full mode
# ---------------------------------------------------------------------------

@test "screenshot full: invokes grim with timestamped filename" {
    run bash "$SCRIPTS_DIR/screenshot.sh" full

    [ "$status" -eq 0 ]
    local grim_args
    grim_args="$(mock_log grim)"
    [[ "$grim_args" == *"$TEST_HOME/Pictures/Screenshots/screen_"* ]]
    [[ "$grim_args" == *".png"* ]]
}

@test "screenshot full: copies file to clipboard via wl-copy" {
    run bash "$SCRIPTS_DIR/screenshot.sh" full

    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# area mode
# ---------------------------------------------------------------------------

@test "screenshot area: invokes grim with -g flag and slurp geometry" {
    # Make grim create a non-empty file so the -s test passes
    cat > "$MOCK_BIN/grim" <<'SCRIPT'
#!/usr/bin/env bash
echo "$@" >> "$HOME/.mock_grim_log"
# Create a non-empty file at the last argument
echo "png-data" > "${@: -1}"
SCRIPT
    chmod +x "$MOCK_BIN/grim"

    run bash "$SCRIPTS_DIR/screenshot.sh" area

    [ "$status" -eq 0 ]
    local grim_args
    grim_args="$(mock_log grim)"
    [[ "$grim_args" == *"-g"* ]]
}

@test "screenshot area: removes empty file on failed capture" {
    # grim creates an empty file (simulates cancelled slurp)
    cat > "$MOCK_BIN/grim" <<'SCRIPT'
#!/usr/bin/env bash
touch "${@: -1}"
SCRIPT
    chmod +x "$MOCK_BIN/grim"

    run bash "$SCRIPTS_DIR/screenshot.sh" area

    [ "$status" -eq 0 ]
    # The screenshot directory should not contain the file (rm "$NAME")
    local count
    count=$(find "$TEST_HOME/Pictures/Screenshots" -name 'screen_*.png' -size +0c | wc -l)
    [ "$count" -eq 0 ]
}

# ---------------------------------------------------------------------------
# no/invalid argument
# ---------------------------------------------------------------------------

@test "screenshot: no argument exits cleanly" {
    run bash "$SCRIPTS_DIR/screenshot.sh"

    [ "$status" -eq 0 ]
}

@test "screenshot: unknown mode exits cleanly" {
    run bash "$SCRIPTS_DIR/screenshot.sh" unknown

    [ "$status" -eq 0 ]
}
