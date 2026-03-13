#!/usr/bin/env bash
# NaruMa — Uninstall script
# Removes symlinks and restores any backed-up configs.
# Does NOT remove packages.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
BIN="$HOME/.config/naruma/bin"

# ── Helpers ───────────────────────────────────────────────────────────────────

log()  { echo "  $*"; }
info() { echo ""; echo "▸ $*"; }

# ── Symlink manifest (must match install.sh) ──────────────────────────────────

REPO="$(cat "$HOME/.config/naruma/repo" 2>/dev/null || echo "$REPO")"

# All possible theme color files (any theme could be active)
_theme_srcs=()
_theme_dsts=(
    hypr/naruma-colors.conf
    waybar/naruma-colors.css
    walker/themes/naruma/naruma-colors.css
    alacritty/naruma-colors.toml
    rofi/naruma-colors.rasi
    mako/config
    hypr/hyprlock.conf
)

LINK_SRCS=(
    hyprland/hyprland.conf
    hyprland/looknfeel.conf
    hyprland/input.conf
    hyprland/autostart.conf
    hyprland/keybindings.conf
    hyprland/rules.conf
    hyprland/monitors.conf
    hypridle/hypridle.conf
    waybar/config.jsonc
    waybar/style.css
    rofi/config.rasi
    walker/config.toml
    walker/themes/naruma/layout.xml
    walker/themes/naruma/style.css
    alacritty/alacritty.toml
)

LINK_DSTS=(
    hypr/hyprland.conf
    hypr/looknfeel.conf
    hypr/input.conf
    hypr/autostart.conf
    hypr/keybindings.conf
    hypr/rules.conf
    hypr/monitors.conf
    hypr/hypridle.conf
    waybar/config.jsonc
    waybar/style.css
    rofi/config.rasi
    walker/config.toml
    walker/themes/naruma/layout.xml
    walker/themes/naruma/style.css
    alacritty/alacritty.toml
)

# ── Unlink configs ────────────────────────────────────────────────────────────

uninstall_config() {
    info "Removing config symlinks…"
    local n=${#LINK_DSTS[@]}
    for (( i = 0; i < n; i++ )); do
        local dst="$CONFIG/${LINK_DSTS[$i]}"
        local src="$REPO/${LINK_SRCS[$i]}"

        # Only remove if it's a symlink pointing into this repo
        if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
            rm "$dst"
            log "Removed $dst"

            # Restore backup if one exists
            if [[ -e "$dst.bak" ]]; then
                mv "$dst.bak" "$dst"
                log "Restored $dst.bak → $dst"
            fi
        elif [[ -L "$dst" ]]; then
            log "Skipping $dst (points elsewhere, not managed by NaruMa)"
        else
            log "Skipping $dst (not a symlink)"
        fi
    done

    # Remove theme color symlinks (point into REPO/themes/, not REPO root)
    info "Removing theme color symlinks…"
    for dst in "${_theme_dsts[@]}"; do
        local full="$CONFIG/$dst"
        if [[ -L "$full" ]]; then
            local target
            target="$(readlink "$full")"
            if [[ $target == "$REPO/themes/"* ]]; then
                rm "$full"
                log "Removed $full"
                [[ -e "$full.bak" ]] && mv "$full.bak" "$full" && log "Restored $full.bak"
            else
                log "Skipping $full (not a NaruMa theme symlink)"
            fi
        fi
    done

    # Clean up state files
    rm -f "$HOME/.config/naruma/repo" "$HOME/.config/naruma/theme"

    # Clean up empty walker theme dir
    local walker_theme="$CONFIG/walker/themes/naruma"
    if [[ -d "$walker_theme" && -z "$(ls -A "$walker_theme")" ]]; then
        rmdir "$walker_theme"
        log "Removed empty dir $walker_theme"
    fi
}

# ── Remove bin scripts ────────────────────────────────────────────────────────

uninstall_bin() {
    info "Removing NaruMa scripts from $BIN…"
    if [[ ! -d "$BIN" ]]; then
        log "Bin dir not found, skipping."
        return
    fi
    local scripts=("$BIN/naruma-"*)
    if [[ ! -e ${scripts[0]} ]]; then
        log "No NaruMa scripts found."
        return
    fi
    for script in "${scripts[@]}"; do
        rm "$script"
        log "Removed $script"
    done
    # Remove bin dir if now empty
    if [[ -z "$(ls -A "$BIN")" ]]; then
        rmdir "$BIN"
        log "Removed empty dir $BIN"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

echo ""
echo "  NaruMa — Uninstaller"
echo "  ─────────────────────"
echo ""
echo "  This will remove all NaruMa symlinks and restore backups."
echo "  Packages will NOT be removed."
echo ""
read -r -p "  Continue? [y/N] " confirm
[[ ${confirm,,} == "y" ]] || { echo "  Aborted."; exit 0; }

uninstall_config
uninstall_bin

echo ""
echo "  ✓ NaruMa uninstalled."
echo ""
echo "  Your wallpaper at $CONFIG/hypr/wallpaper was left in place."
echo "  To fully reset, run: hyprctl reload"
echo ""
