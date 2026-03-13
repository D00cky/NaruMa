# tests/helpers/common.bash — shared mock setup for NaruMa bats test suite

# Set up a mock bin directory prepended to PATH.
# Creates lightweight stubs for external commands that the scripts invoke so
# tests never touch real system tooling.
setup_mocks() {
    MOCK_BIN="$BATS_TEST_TMPDIR/bin"
    mkdir -p "$MOCK_BIN"
    export PATH="$MOCK_BIN:$PATH"

    # walker: accept any args, discard stdin, exit 0 (simulates cancelled menu)
    cat > "$MOCK_BIN/walker" <<'EOF'
#!/usr/bin/env bash
cat > /dev/null
exit 0
EOF

    # rofi: same — discard stdin, exit 0
    cat > "$MOCK_BIN/rofi" <<'EOF'
#!/usr/bin/env bash
cat > /dev/null
exit 0
EOF

    # pacman: -Qi always exits 1 (nothing installed); everything else exits 0
    cat > "$MOCK_BIN/pacman" <<'EOF'
#!/usr/bin/env bash
case "${1:-}" in
    -Qi) exit 1 ;;
    *)   exit 0 ;;
esac
EOF

    # notify-send: silently succeed
    cat > "$MOCK_BIN/notify-send" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

    # xdg-terminal-exec: silently succeed (don't actually open a terminal)
    cat > "$MOCK_BIN/xdg-terminal-exec" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

    # hyprctl: succeed and echo "ok" for any args
    cat > "$MOCK_BIN/hyprctl" <<'EOF'
#!/usr/bin/env bash
echo "ok"
exit 0
EOF

    # pkill: succeed unconditionally
    cat > "$MOCK_BIN/pkill" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

    # setsid: run its arguments silently (mirrors real setsid behaviour in
    # install_pkg / _launch_walker where it is used as "setsid cmd &>/dev/null &")
    cat > "$MOCK_BIN/setsid" <<'EOF'
#!/usr/bin/env bash
exec "$@" &>/dev/null
EOF

    # elephant: app-index daemon — just exit 0
    cat > "$MOCK_BIN/elephant" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

    chmod +x "$MOCK_BIN"/walker \
             "$MOCK_BIN"/rofi \
             "$MOCK_BIN"/pacman \
             "$MOCK_BIN"/notify-send \
             "$MOCK_BIN"/xdg-terminal-exec \
             "$MOCK_BIN"/hyprctl \
             "$MOCK_BIN"/pkill \
             "$MOCK_BIN"/setsid \
             "$MOCK_BIN"/elephant
}

# mock_pkg_installed PKG
# Rewrites the mock pacman so that "-Qi PKG" exits 0 (package is installed).
mock_pkg_installed() {
    local pkg="$1"
    cat > "$MOCK_BIN/pacman" <<EOF
#!/usr/bin/env bash
if [[ "\${1:-}" == "-Qi" && "\${2:-}" == "$pkg" ]]; then
    exit 0
fi
case "\${1:-}" in
    -Qi) exit 1 ;;
    *)   exit 0 ;;
esac
EOF
    chmod +x "$MOCK_BIN/pacman"
}

# mock_aur_helper NAME
# Creates a minimal mock for paru or yay in MOCK_BIN.
mock_aur_helper() {
    local name="$1"
    cat > "$MOCK_BIN/$name" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    chmod +x "$MOCK_BIN/$name"
}
