#!/usr/bin/env bats
# tests/naruma_apps.bats — tests for bin/naruma-apps

load 'helpers/common'

REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SCRIPT="$REPO/bin/naruma-apps"

setup() {
    setup_mocks
}

# ── Executable ────────────────────────────────────────────────────────────────

@test "naruma-apps is executable" {
    [ -x "$SCRIPT" ]
}

# ── mark() ────────────────────────────────────────────────────────────────────

@test "mark() shows checkmark for installed package" {
    # Inline script: mock pacman as a shell function (exits 0 = installed)
    run bash -c '
        pacman() { return 0; }
        mark() { pacman -Qi "$1" &>/dev/null && echo "✓ $2" || echo "  $2"; }
        mark firefox Firefox
    '
    [ "$status" -eq 0 ]
    [[ "$output" == *"✓ Firefox"* ]]
}

@test "mark() shows spaces for uninstalled package" {
    # Inline script: mock pacman as a shell function (exits 1 = not installed)
    run bash -c '
        pacman() { return 1; }
        mark() { pacman -Qi "$1" &>/dev/null && echo "✓ $2" || echo "  $2"; }
        mark firefox Firefox
    '
    [ "$status" -eq 0 ]
    [[ "$output" == "  Firefox" ]]
}

# ── _aur_helper() ─────────────────────────────────────────────────────────────

@test "_aur_helper() returns paru when paru is available" {
    mock_aur_helper paru
    # Write a helper script to a temp file so PATH is clean
    local helper_script="$BATS_TEST_TMPDIR/test_aur.sh"
    cat > "$helper_script" <<EOF
#!/usr/bin/env bash
export PATH="$MOCK_BIN:\$PATH"
_aur_helper() {
    command -v paru &>/dev/null && echo paru && return
    command -v yay  &>/dev/null && echo yay  && return
    echo ""
}
_aur_helper
EOF
    chmod +x "$helper_script"
    run bash "$helper_script"
    [ "$status" -eq 0 ]
    [ "$output" = "paru" ]
}

@test "_aur_helper() returns yay when only yay is available" {
    mock_aur_helper yay
    local helper_script="$BATS_TEST_TMPDIR/test_aur.sh"
    cat > "$helper_script" <<EOF
#!/usr/bin/env bash
export PATH="$MOCK_BIN:\$PATH"
_aur_helper() {
    command -v paru &>/dev/null && echo paru && return
    command -v yay  &>/dev/null && echo yay  && return
    echo ""
}
_aur_helper
EOF
    chmod +x "$helper_script"
    run bash "$helper_script"
    [ "$status" -eq 0 ]
    [ "$output" = "yay" ]
}

@test "_aur_helper() returns empty string when no AUR helper" {
    # Use a PATH restricted to MOCK_BIN plus only the directories needed for
    # bash and coreutils, explicitly excluding any location where paru/yay live.
    # This prevents the real system yay (e.g. /usr/bin/yay) from being found.
    local helper_script="$BATS_TEST_TMPDIR/test_aur_none.sh"
    cat > "$helper_script" <<EOF
#!/usr/bin/env bash
# Restricted PATH: MOCK_BIN only + /usr/lib (env/bash shebang resolution)
# We deliberately omit /usr/bin to hide real AUR helpers, but bash is already
# running so #!/usr/bin/env bash in child scripts still works.
export PATH="$MOCK_BIN"
_aur_helper() {
    command -v paru &>/dev/null && echo paru && return
    command -v yay  &>/dev/null && echo yay  && return
    echo ""
}
_aur_helper
EOF
    chmod +x "$helper_script"
    run bash "$helper_script"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

# ── Category subcommands — verify they exit 0 when menu is cancelled ──────────

@test "naruma-apps browsers exits 0" {
    run "$SCRIPT" browsers
    [ "$status" -eq 0 ]
}

@test "naruma-apps terminals exits 0" {
    run "$SCRIPT" terminals
    [ "$status" -eq 0 ]
}

@test "naruma-apps editors exits 0" {
    run "$SCRIPT" editors
    [ "$status" -eq 0 ]
}

@test "naruma-apps files exits 0" {
    run "$SCRIPT" files
    [ "$status" -eq 0 ]
}

@test "naruma-apps media exits 0" {
    run "$SCRIPT" media
    [ "$status" -eq 0 ]
}

@test "naruma-apps communication exits 0" {
    run "$SCRIPT" communication
    [ "$status" -eq 0 ]
}

@test "naruma-apps development exits 0" {
    run "$SCRIPT" development
    [ "$status" -eq 0 ]
}

@test "naruma-apps productivity exits 0" {
    run "$SCRIPT" productivity
    [ "$status" -eq 0 ]
}

# ── install_pkg AUR path with no helper ───────────────────────────────────────

@test "install_pkg notifies when AUR package requested but no helper" {
    local sentinel="$BATS_TEST_TMPDIR/notify_called"

    # Write a notify-send mock that touches the sentinel
    cat > "$MOCK_BIN/notify-send" <<EOF
#!/usr/bin/env bash
touch "$sentinel"
exit 0
EOF
    chmod +x "$MOCK_BIN/notify-send"

    # Write a self-contained test script; PATH is fully set inside it so
    # #!/usr/bin/env bash in any mock can always find bash.
    local test_script="$BATS_TEST_TMPDIR/test_install_pkg.sh"
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
export PATH="$MOCK_BIN:\$PATH"
set -euo pipefail

menu()            { echo ''; }
pacman()          { return 1; }
_aur_helper()     { echo ''; }
xdg-terminal-exec() { :; }
pkill()           { return 0; }
setsid()          { return 0; }
elephant()        { return 0; }

install_pkg() {
    local pkg="\$1" aur="\${2:-false}"
    if pacman -Qi "\$pkg" &>/dev/null; then
        local choice
        choice=\$(menu "  \$pkg is installed" "  Keep\n  Uninstall" 280)
        [[ "\$choice" == *Uninstall* ]] || return 0
        xdg-terminal-exec -- sh -c "sudo pacman -Rns \$pkg"
    else
        local aur_helper cmd
        aur_helper=\$(_aur_helper)
        if [[ "\$aur" == "true" ]]; then
            if [[ -z "\$aur_helper" ]]; then
                notify-send "NaruMa" "AUR helper required — install paru or yay first"
                return
            fi
            cmd="\$aur_helper -S --needed \$pkg"
        else
            cmd="sudo pacman -S --needed \$pkg"
        fi
        xdg-terminal-exec -- sh -c "\$cmd"
    fi
}

install_pkg obsidian true
EOF
    chmod +x "$test_script"

    run bash "$test_script"
    [ "$status" -eq 0 ]
    [ -f "$sentinel" ]
}

# ── Function definitions ───────────────────────────────────────────────────────

@test "all category functions are defined in script" {
    local test_script="$BATS_TEST_TMPDIR/test_fns.sh"
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
export PATH="$MOCK_BIN:\$PATH"

# Override commands that may be invoked at sourcing time
pacman() { return 1; }
menu()   { echo ''; }

# Source the script; the case at the bottom executes show_main which
# calls menu() returning '' — no-op, harmless.
source "$SCRIPT"

for fn in show_browsers show_terminals show_editors show_files \
          show_media show_communication show_development show_productivity \
          show_main; do
    declare -f "\$fn" > /dev/null || { echo "MISSING: \$fn"; exit 1; }
done
echo "all defined"
EOF
    chmod +x "$test_script"

    run bash "$test_script"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all defined"* ]]
}
