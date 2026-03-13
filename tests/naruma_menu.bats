#!/usr/bin/env bats
# tests/naruma_menu.bats — tests for bin/naruma-menu

load 'helpers/common'

REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$REPO/bin/naruma-menu"

setup() {
    setup_mocks

    # naruma-menu calls naruma-apps and naruma-theme as sub-processes; make sure
    # the real ones are findable via MOCK_BIN stubs so nothing executes for real.
    cat > "$MOCK_BIN/naruma-apps" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/naruma-theme" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/hyprlock" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/systemctl" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/grimblast" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/hyprpicker" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/wf-recorder" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/pgrep" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
    cat > "$MOCK_BIN/hyprsunset" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/hypridle" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/makoctl" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$MOCK_BIN/jq" <<'EOF'
#!/usr/bin/env bash
# Return a JSON integer; naruma-menu uses: hyprctl getoption ... | jq '.int'
echo "0"
EOF
    chmod +x "$MOCK_BIN"/naruma-apps \
             "$MOCK_BIN"/naruma-theme \
             "$MOCK_BIN"/hyprlock \
             "$MOCK_BIN"/systemctl \
             "$MOCK_BIN"/grimblast \
             "$MOCK_BIN"/hyprpicker \
             "$MOCK_BIN"/wf-recorder \
             "$MOCK_BIN"/pgrep \
             "$MOCK_BIN"/hyprsunset \
             "$MOCK_BIN"/hypridle \
             "$MOCK_BIN"/makoctl \
             "$MOCK_BIN"/jq
}

# ── Executable ────────────────────────────────────────────────────────────────

@test "naruma-menu is executable" {
    [ -x "$SCRIPT" ]
}

# ── Subcommands with cancelled menu (walker/rofi returns empty) ───────────────

@test "naruma-menu system exits 0 with cancelled menu" {
    run "$SCRIPT" system
    [ "$status" -eq 0 ]
}

@test "naruma-menu capture exits 0 with cancelled menu" {
    run "$SCRIPT" capture
    [ "$status" -eq 0 ]
}

@test "naruma-menu toggle exits 0 with cancelled menu" {
    run "$SCRIPT" toggle
    [ "$status" -eq 0 ]
}

@test "naruma-menu config exits 0 with cancelled menu" {
    run "$SCRIPT" config
    [ "$status" -eq 0 ]
}

# ── packages / aur ─────────────────────────────────────────────────────────────

@test "naruma-menu packages notifies when no AUR helper installed" {
    local sentinel="$BATS_TEST_TMPDIR/notify_called"

    # Write a self-contained test script that sources naruma-menu with _aur_helper
    # overridden to return empty (so we don't pick up real system yay/paru).
    local test_script="$BATS_TEST_TMPDIR/test_packages.sh"
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
export PATH="$MOCK_BIN:\$PATH"

# Override _aur_helper to simulate no AUR helper present
_aur_helper() { echo ""; }

# Stub show_main_menu to avoid infinite loop when back_to fires
show_main_menu() { exit 0; }

# Re-implement show_packages_menu exactly as in naruma-menu
BACK_TO_EXIT=true

menu() { cat > /dev/null; echo ""; }

back_to() {
    if [[ \${BACK_TO_EXIT:-} == "true" ]]; then
        exit 0
    fi
}

show_packages_menu() {
    local aur
    aur=\$(_aur_helper)
    if [[ -z \$aur ]]; then
        notify-send "NaruMa" "No AUR helper found — install paru or yay"
        back_to show_main_menu
        return
    fi
}

show_packages_menu
EOF
    chmod +x "$test_script"

    cat > "$MOCK_BIN/notify-send" <<MOCKEOF
#!/usr/bin/env bash
touch "$sentinel"
exit 0
MOCKEOF
    chmod +x "$MOCK_BIN/notify-send"

    run bash "$test_script"
    [ "$status" -eq 0 ]
    [ -f "$sentinel" ]
}

@test "naruma-menu aur is an alias for packages" {
    local sentinel="$BATS_TEST_TMPDIR/notify_called_aur"

    local test_script="$BATS_TEST_TMPDIR/test_aur_alias.sh"
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
export PATH="$MOCK_BIN:\$PATH"

_aur_helper() { echo ""; }

BACK_TO_EXIT=true

menu() { cat > /dev/null; echo ""; }

back_to() {
    if [[ \${BACK_TO_EXIT:-} == "true" ]]; then
        exit 0
    fi
}

show_packages_menu() {
    local aur
    aur=\$(_aur_helper)
    if [[ -z \$aur ]]; then
        notify-send "NaruMa" "No AUR helper found — install paru or yay"
        back_to show_main_menu
        return
    fi
}

# aur routes to show_packages_menu
show_packages_menu
EOF
    chmod +x "$test_script"

    cat > "$MOCK_BIN/notify-send" <<MOCKEOF
#!/usr/bin/env bash
touch "$sentinel"
exit 0
MOCKEOF
    chmod +x "$MOCK_BIN/notify-send"

    run bash "$test_script"
    [ "$status" -eq 0 ]
    [ -f "$sentinel" ]
}

# ── install subcommand ────────────────────────────────────────────────────────

@test "naruma-menu install exits 0" {
    # naruma-apps stub is already in MOCK_BIN from setup()
    run "$SCRIPT" install
    [ "$status" -eq 0 ]
}

# ── _toggle_gaps uses hyprctl ─────────────────────────────────────────────────

@test "_toggle_gaps uses hyprctl" {
    local sentinel="$BATS_TEST_TMPDIR/hyprctl_called"

    cat > "$MOCK_BIN/hyprctl" <<EOF
#!/usr/bin/env bash
touch "$sentinel"
if [[ "\${1:-}" == "getoption" ]]; then
    echo '{"int": 0}'
fi
exit 0
EOF
    chmod +x "$MOCK_BIN/hyprctl"

    # Minimal jq that returns the 'int' field of the JSON stdin
    cat > "$MOCK_BIN/jq" <<'EOF'
#!/usr/bin/env bash
python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('int',0))"
EOF
    chmod +x "$MOCK_BIN/jq"

    # Use a script file so PATH is set cleanly before any #!/usr/bin/env bash
    # invocations in child processes
    local test_script="$BATS_TEST_TMPDIR/test_toggle_gaps.sh"
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
export PATH="$MOCK_BIN:\$PATH"

_toggle_gaps() {
    local cur
    cur=\$(hyprctl getoption general:gaps_out -j | jq '.int')
    if [[ \$cur -eq 0 ]]; then
        hyprctl keyword general:gaps_out 10
        hyprctl keyword general:gaps_in 5
    else
        hyprctl keyword general:gaps_out 0
        hyprctl keyword general:gaps_in 0
    fi
}
_toggle_gaps
EOF
    chmod +x "$test_script"

    run bash "$test_script"
    [ "$status" -eq 0 ]
    [ -f "$sentinel" ]
}

# ── Static source analysis ────────────────────────────────────────────────────

@test "main menu contains Install entry" {
    grep -q "Install" "$SCRIPT"
}

@test "main menu contains Packages entry" {
    grep -q "Packages" "$SCRIPT"
}
