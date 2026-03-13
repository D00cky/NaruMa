#!/usr/bin/env bats
# tests/themes.bats — validates all theme files are complete and well-formed

REPO="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
THEMES_DIR="$REPO/themes"

# ── File presence for each theme ──────────────────────────────────────────────

# catppuccin-mocha
@test "theme catppuccin-mocha has colors.conf" {
    [ -f "$THEMES_DIR/catppuccin-mocha/colors.conf" ]
}
@test "theme catppuccin-mocha has colors.css" {
    [ -f "$THEMES_DIR/catppuccin-mocha/colors.css" ]
}
@test "theme catppuccin-mocha has colors.toml" {
    [ -f "$THEMES_DIR/catppuccin-mocha/colors.toml" ]
}
@test "theme catppuccin-mocha has colors.rasi" {
    [ -f "$THEMES_DIR/catppuccin-mocha/colors.rasi" ]
}
@test "theme catppuccin-mocha has mako.config" {
    [ -f "$THEMES_DIR/catppuccin-mocha/mako.config" ]
}
@test "theme catppuccin-mocha has hyprlock.conf" {
    [ -f "$THEMES_DIR/catppuccin-mocha/hyprlock.conf" ]
}

# sakura
@test "theme sakura has colors.conf" {
    [ -f "$THEMES_DIR/sakura/colors.conf" ]
}
@test "theme sakura has colors.css" {
    [ -f "$THEMES_DIR/sakura/colors.css" ]
}
@test "theme sakura has colors.toml" {
    [ -f "$THEMES_DIR/sakura/colors.toml" ]
}
@test "theme sakura has colors.rasi" {
    [ -f "$THEMES_DIR/sakura/colors.rasi" ]
}
@test "theme sakura has mako.config" {
    [ -f "$THEMES_DIR/sakura/mako.config" ]
}
@test "theme sakura has hyprlock.conf" {
    [ -f "$THEMES_DIR/sakura/hyprlock.conf" ]
}

# cyberpunk
@test "theme cyberpunk has colors.conf" {
    [ -f "$THEMES_DIR/cyberpunk/colors.conf" ]
}
@test "theme cyberpunk has colors.css" {
    [ -f "$THEMES_DIR/cyberpunk/colors.css" ]
}
@test "theme cyberpunk has colors.toml" {
    [ -f "$THEMES_DIR/cyberpunk/colors.toml" ]
}
@test "theme cyberpunk has colors.rasi" {
    [ -f "$THEMES_DIR/cyberpunk/colors.rasi" ]
}
@test "theme cyberpunk has mako.config" {
    [ -f "$THEMES_DIR/cyberpunk/mako.config" ]
}
@test "theme cyberpunk has hyprlock.conf" {
    [ -f "$THEMES_DIR/cyberpunk/hyprlock.conf" ]
}

# pokemon
@test "theme pokemon has colors.conf" {
    [ -f "$THEMES_DIR/pokemon/colors.conf" ]
}
@test "theme pokemon has colors.css" {
    [ -f "$THEMES_DIR/pokemon/colors.css" ]
}
@test "theme pokemon has colors.toml" {
    [ -f "$THEMES_DIR/pokemon/colors.toml" ]
}
@test "theme pokemon has colors.rasi" {
    [ -f "$THEMES_DIR/pokemon/colors.rasi" ]
}
@test "theme pokemon has mako.config" {
    [ -f "$THEMES_DIR/pokemon/mako.config" ]
}
@test "theme pokemon has hyprlock.conf" {
    [ -f "$THEMES_DIR/pokemon/hyprlock.conf" ]
}

# ── colors.conf content ───────────────────────────────────────────────────────

@test "colors.conf for catppuccin-mocha defines at least one dollar-sign variable" {
    grep -qE '^\$[a-zA-Z]' "$THEMES_DIR/catppuccin-mocha/colors.conf"
}

@test "colors.conf for sakura defines at least one dollar-sign variable" {
    grep -qE '^\$[a-zA-Z]' "$THEMES_DIR/sakura/colors.conf"
}

@test "colors.conf for cyberpunk defines at least one dollar-sign variable" {
    grep -qE '^\$[a-zA-Z]' "$THEMES_DIR/cyberpunk/colors.conf"
}

@test "colors.conf for pokemon defines at least one dollar-sign variable" {
    grep -qE '^\$[a-zA-Z]' "$THEMES_DIR/pokemon/colors.conf"
}

# ── Active theme symlinks (only tested when install has been run) ──────────────

@test "active theme symlink naruma-colors.conf points to existing file" {
    local link="$HOME/.config/hypr/naruma-colors.conf"
    if [ ! -L "$link" ]; then
        skip "naruma-colors.conf symlink not present — run install.sh first"
    fi
    [ -e "$link" ]
}

@test "active theme symlink naruma-colors.css points to existing file" {
    local link="$HOME/.config/waybar/naruma-colors.css"
    if [ ! -L "$link" ]; then
        skip "naruma-colors.css symlink not present — run install.sh first"
    fi
    [ -e "$link" ]
}

@test "active theme symlink hyprlock.conf points to existing file" {
    local link="$HOME/.config/hypr/hyprlock.conf"
    if [ ! -L "$link" ]; then
        skip "hyprlock.conf symlink not present — run install.sh first"
    fi
    [ -e "$link" ]
}
