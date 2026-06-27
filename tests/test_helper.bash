# Common test helpers for dotfiles shell script tests.
# Sources this file at the top of each .bats file.

SCRIPTS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../hypr/.config/hypr/scripts" && pwd)"
MOCK_BIN=""   # set per-test in setup()
TEST_HOME=""  # set per-test in setup()

# Create a temporary sandbox with a mock PATH bin directory.
setup_sandbox() {
    TEST_HOME="$(mktemp -d)"
    MOCK_BIN="$(mktemp -d)"
    export HOME="$TEST_HOME"
    export PATH="$MOCK_BIN:$PATH"
    mkdir -p "$TEST_HOME/.config/rofi"
    mkdir -p "$TEST_HOME/Pictures/Screenshots"
    mkdir -p "$TEST_HOME/Pictures/Wallpapers"
    mkdir -p "$TEST_HOME/Videos/Recordings"
    mkdir -p "$TEST_HOME/.cache"
}

teardown_sandbox() {
    rm -rf "$TEST_HOME" "$MOCK_BIN"
}

# Create a stub executable in MOCK_BIN that prints supplied output and exits
# with the given code.
#   mock_command <name> [exit_code] [stdout_output]
mock_command() {
    local name="$1"
    local exit_code="${2:-0}"
    local output="${3:-}"
    cat > "$MOCK_BIN/$name" <<SCRIPT
#!/usr/bin/env bash
echo -n "$output"
exit $exit_code
SCRIPT
    chmod +x "$MOCK_BIN/$name"
}

# Create a stub that records its arguments to a log file and optionally prints
# output.
#   mock_command_log <name> [exit_code] [stdout_output]
mock_command_log() {
    local name="$1"
    local exit_code="${2:-0}"
    local output="${3:-}"
    local log_file="$TEST_HOME/.mock_${name}_log"
    cat > "$MOCK_BIN/$name" <<SCRIPT
#!/usr/bin/env bash
echo "\$@" >> "$log_file"
echo -n "$output"
exit $exit_code
SCRIPT
    chmod +x "$MOCK_BIN/$name"
}

# Read the argument log for a mocked command.
mock_log() {
    local name="$1"
    cat "$TEST_HOME/.mock_${name}_log" 2>/dev/null
}

# Create a pgrep mock that succeeds only for given process names.
#   mock_pgrep_for <proc1> [proc2] ...
mock_pgrep_for() {
    local procs=("$@")
    local conditions=""
    for p in "${procs[@]}"; do
        conditions+="[[ \"\$pattern\" == \"$p\" ]] && { echo 12345; exit 0; }; "
    done
    cat > "$MOCK_BIN/pgrep" <<SCRIPT
#!/usr/bin/env bash
pattern=""
while [[ \$# -gt 0 ]]; do
    case "\$1" in
        -x|-f) ;;
        *)  pattern="\$1" ;;
    esac
    shift
done
$conditions
exit 1
SCRIPT
    chmod +x "$MOCK_BIN/pgrep"
}

# Create a pgrep mock that always fails (no matching process).
mock_pgrep_none() {
    cat > "$MOCK_BIN/pgrep" <<'SCRIPT'
#!/usr/bin/env bash
exit 1
SCRIPT
    chmod +x "$MOCK_BIN/pgrep"
}
