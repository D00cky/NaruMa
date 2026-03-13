#!/usr/bin/env bats
# tests/config.bats — config file and symlink validity checks

REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# ── Hyprland live config errors ───────────────────────────────────────────────

@test "hyprctl reports no config errors" {
    if ! command -v hyprctl &>/dev/null; then
        skip "hyprctl not available"
    fi
    if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        skip "Hyprland is not running"
    fi
    run hyprctl -j configerrors
    [ "$status" -eq 0 ]
    # Output should be an empty JSON array or array containing only empty strings
    [[ "$output" == "[]" ]] || [[ "$output" == '[""]' ]] || \
        python3 -c "
import sys, json
errs = json.loads('''$output''')
real = [e for e in errs if e.strip()]
sys.exit(0 if not real else 1)
"
}

# ── Required Hyprland symlinks exist ─────────────────────────────────────────

@test "all required hypr symlinks exist" {
    local config="$HOME/.config/hypr"
    if [ ! -d "$config" ]; then
        skip "~/.config/hypr not present — run install.sh first"
    fi
    for name in hyprland looknfeel input autostart keybindings rules monitors; do
        [ -e "$config/$name.conf" ] || {
            echo "Missing: $config/$name.conf"
            return 1
        }
    done
}

@test "all hypr symlinks are valid (not broken)" {
    local config="$HOME/.config/hypr"
    if [ ! -d "$config" ]; then
        skip "~/.config/hypr not present — run install.sh first"
    fi
    for name in hyprland looknfeel input autostart keybindings rules monitors; do
        local f="$config/$name.conf"
        if [ -L "$f" ]; then
            [ -e "$f" ] || {
                echo "Broken symlink: $f -> $(readlink "$f")"
                return 1
            }
        fi
    done
}

# ── Waybar JSONC validation ───────────────────────────────────────────────────

@test "waybar config.jsonc is valid JSON" {
    local cfg="$HOME/.config/waybar/config.jsonc"
    if [ ! -e "$cfg" ]; then
        # Fall back to the repo copy
        cfg="$REPO/waybar/config.jsonc"
    fi
    if [ ! -f "$cfg" ]; then
        skip "waybar config.jsonc not found"
    fi
    run python3 -c "
import json, re, sys
with open('$cfg') as fh:
    raw = fh.read()
# Strip single-line // comments (not inside strings — good enough for config files)
stripped = re.sub(r'(?m)//[^\n]*', '', raw)
try:
    json.loads(stripped)
    print('valid')
except json.JSONDecodeError as e:
    print(f'invalid: {e}', file=sys.stderr)
    sys.exit(1)
"
    [ "$status" -eq 0 ]
    [[ "$output" == "valid" ]]
}

# ── autostart.conf content ────────────────────────────────────────────────────

@test "autostart.conf starts elephant" {
    grep -q "elephant" "$REPO/hyprland/autostart.conf"
}

@test "autostart.conf starts walker service" {
    grep -q "walker --gapplication-service" "$REPO/hyprland/autostart.conf"
}

# ── hyprland.conf content ─────────────────────────────────────────────────────

@test "hyprland.conf sets PATH env" {
    grep -q "env = PATH" "$REPO/hyprland/hyprland.conf"
}

# ── rules.conf syntax ─────────────────────────────────────────────────────────

@test "rules.conf has no old-style windowrule = lines" {
    # Old-style: "windowrule = rule, class"   (with an equals sign after windowrule)
    # New block syntax: "windowrule {"  — no equals sign on that line
    local count
    count=$(grep -cE '^windowrule\s*=' "$REPO/hyprland/rules.conf" || true)
    [ "$count" -eq 0 ]
}

@test "all windowrule blocks in rules.conf have a name field" {
    # For every "windowrule {" open-brace, there must be a "name =" line before
    # the matching closing "}" on its own line.
    run python3 -c "
import sys

with open('$REPO/hyprland/rules.conf') as fh:
    lines = fh.readlines()

in_block = False
block_start = 0
has_name = False
errors = []

for i, line in enumerate(lines, 1):
    stripped = line.strip()
    if stripped.startswith('windowrule') and stripped.endswith('{'):
        in_block = True
        block_start = i
        has_name = False
    elif in_block:
        if stripped.startswith('name'):
            has_name = True
        elif stripped == '}':
            if not has_name:
                errors.append(f'windowrule block starting at line {block_start} has no name = field')
            in_block = False

if errors:
    for e in errors:
        print(e)
    sys.exit(1)
print('ok')
"
    [ "$status" -eq 0 ]
    [[ "$output" == "ok" ]]
}
