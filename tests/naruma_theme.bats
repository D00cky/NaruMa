#!/usr/bin/env bats
# tests/naruma_theme.bats — tests for bin/naruma-theme

load 'helpers/common'

REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$REPO/bin/naruma-theme"

setup() {
    setup_mocks

    # Stub reload helpers that naruma-theme calls after applying a theme
    cat > "$MOCK_BIN/makoctl" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    chmod +x "$MOCK_BIN/makoctl"

    # Provide a writable fake HOME so naruma-theme can read/write state files
    # without touching the real ~/.config/naruma/repo.
    FAKE_HOME="$BATS_TEST_TMPDIR/home"
    mkdir -p "$FAKE_HOME/.config/naruma"
    mkdir -p "$FAKE_HOME/.config/hypr"
    mkdir -p "$FAKE_HOME/.config/waybar"
    mkdir -p "$FAKE_HOME/.config/walker/themes/naruma"
    mkdir -p "$FAKE_HOME/.config/alacritty"
    mkdir -p "$FAKE_HOME/.config/rofi"
    mkdir -p "$FAKE_HOME/.config/mako"

    # Point naruma-theme to the real repo's themes directory
    echo "$REPO" > "$FAKE_HOME/.config/naruma/repo"

    # Set the active theme to catppuccin-mocha (the default)
    echo "catppuccin-mocha" > "$FAKE_HOME/.config/naruma/theme"

    export HOME="$FAKE_HOME"
}

# ── Executable ────────────────────────────────────────────────────────────────

@test "naruma-theme is executable" {
    [ -x "$SCRIPT" ]
}

# ── list subcommand ───────────────────────────────────────────────────────────

@test "naruma-theme list shows all 4 shipped themes" {
    run bash "$SCRIPT" list
    [ "$status" -eq 0 ]
    [[ "$output" == *"catppuccin-mocha"* ]]
    [[ "$output" == *"sakura"* ]]
    [[ "$output" == *"cyberpunk"* ]]
    [[ "$output" == *"pokemon"* ]]
}

@test "naruma-theme list marks active theme with * and (active)" {
    run bash "$SCRIPT" list
    [ "$status" -eq 0 ]
    [[ "$output" == *"* catppuccin-mocha (active)"* ]]
}

@test "naruma-theme list output contains catppuccin-mocha" {
    run bash "$SCRIPT" list
    [ "$status" -eq 0 ]
    [[ "$output" == *"catppuccin-mocha"* ]]
}

@test "naruma-theme list output contains sakura" {
    run bash "$SCRIPT" list
    [ "$status" -eq 0 ]
    [[ "$output" == *"sakura"* ]]
}

@test "naruma-theme list output contains cyberpunk" {
    run bash "$SCRIPT" list
    [ "$status" -eq 0 ]
    [[ "$output" == *"cyberpunk"* ]]
}

@test "naruma-theme list output contains pokemon" {
    run bash "$SCRIPT" list
    [ "$status" -eq 0 ]
    [[ "$output" == *"pokemon"* ]]
}

# ── Unknown theme ─────────────────────────────────────────────────────────────

@test "naruma-theme with unknown name exits 1" {
    run bash "$SCRIPT" totally-nonexistent-theme
    [ "$status" -eq 1 ]
}

@test "naruma-theme with unknown name prints error to stdout" {
    run bash "$SCRIPT" totally-nonexistent-theme
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"not found"* ]]
}
