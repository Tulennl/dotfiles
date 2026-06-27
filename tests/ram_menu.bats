#!/usr/bin/env bats

load test_helper

setup() {
    setup_sandbox
    mock_command "notify-send" 0
    mock_command "kitty" 0
    mock_command_log "pkill" 0
}

teardown() {
    teardown_sandbox
}

# ---------------------------------------------------------------------------
# get_top_ram helper (sourced from the script)
# ---------------------------------------------------------------------------

@test "ram_menu: exits 0 when rofi selection is empty" {
    mock_command "rofi" 0 ""
    # ps mock that returns realistic output
    cat > "$MOCK_BIN/ps" <<'SCRIPT'
#!/usr/bin/env bash
echo "  RSS COMMAND"
echo "524288 firefox"
echo "262144 code"
echo "131072 slack"
SCRIPT
    chmod +x "$MOCK_BIN/ps"

    run bash "$SCRIPTS_DIR/ram_menu.sh"

    [ "$status" -eq 0 ]
}

@test "ram_menu: opens btop when full monitor option is selected" {
    cat > "$MOCK_BIN/ps" <<'SCRIPT'
#!/usr/bin/env bash
echo "  RSS COMMAND"
echo "524288 firefox"
SCRIPT
    chmod +x "$MOCK_BIN/ps"
    mock_command "rofi" 0 "󰆼 [ OPEN FULL MONITOR (All Processes) ]"

    run bash "$SCRIPTS_DIR/ram_menu.sh"

    [ "$status" -eq 0 ]
}

@test "ram_menu: kills selected process when user confirms" {
    cat > "$MOCK_BIN/ps" <<'SCRIPT'
#!/usr/bin/env bash
echo "  RSS COMMAND"
echo "524288 firefox"
SCRIPT
    chmod +x "$MOCK_BIN/ps"

    # First rofi call selects a process, second call confirms "Yes"
    local call_count_file="$TEST_HOME/.rofi_calls"
    echo "0" > "$call_count_file"
    cat > "$MOCK_BIN/rofi" <<SCRIPT
#!/usr/bin/env bash
count=\$(cat "$call_count_file")
count=\$((count + 1))
echo "\$count" > "$call_count_file"
if [ "\$count" -eq 1 ]; then
    echo "   512 MB  |  firefox"
else
    echo "Yes"
fi
SCRIPT
    chmod +x "$MOCK_BIN/rofi"

    run bash "$SCRIPTS_DIR/ram_menu.sh"

    [ "$status" -eq 0 ]
    [[ "$(mock_log pkill)" == *"firefox"* ]]
}

@test "ram_menu: does not kill process when user declines" {
    cat > "$MOCK_BIN/ps" <<'SCRIPT'
#!/usr/bin/env bash
echo "  RSS COMMAND"
echo "524288 firefox"
SCRIPT
    chmod +x "$MOCK_BIN/ps"

    local call_count_file="$TEST_HOME/.rofi_calls"
    echo "0" > "$call_count_file"
    cat > "$MOCK_BIN/rofi" <<SCRIPT
#!/usr/bin/env bash
count=\$(cat "$call_count_file")
count=\$((count + 1))
echo "\$count" > "$call_count_file"
if [ "\$count" -eq 1 ]; then
    echo "   512 MB  |  firefox"
else
    echo "No"
fi
SCRIPT
    chmod +x "$MOCK_BIN/rofi"

    run bash "$SCRIPTS_DIR/ram_menu.sh"

    [ "$status" -eq 0 ]
    # pkill should not have been called (or log should be empty / not contain firefox)
    local log
    log="$(mock_log pkill 2>/dev/null || true)"
    [[ -z "$log" || "$log" != *"firefox"* ]]
}
