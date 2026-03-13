#!/usr/bin/env bash
# NaruMa — Install Hyprland theme config
# Symlinks config files into ~/.config/

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        echo "  Backing up $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sfn "$src" "$dst"
    echo "  Linked $dst"
}

echo "Installing NaruMa config…"

link "$REPO/hyprland/hyprland.conf"   "$CONFIG/hypr/hyprland.conf"
link "$REPO/hyprland/looknfeel.conf"  "$CONFIG/hypr/looknfeel.conf"
link "$REPO/hyprland/input.conf"      "$CONFIG/hypr/input.conf"
link "$REPO/hyprland/autostart.conf"  "$CONFIG/hypr/autostart.conf"
link "$REPO/hyprland/keybindings.conf" "$CONFIG/hypr/keybindings.conf"
link "$REPO/hyprland/rules.conf"      "$CONFIG/hypr/rules.conf"
link "$REPO/hyprland/monitors.conf"   "$CONFIG/hypr/monitors.conf"

link "$REPO/waybar/config.jsonc"  "$CONFIG/waybar/config.jsonc"
link "$REPO/waybar/style.css"     "$CONFIG/waybar/style.css"

link "$REPO/mako/config"          "$CONFIG/mako/config"
link "$REPO/rofi/config.rasi"     "$CONFIG/rofi/config.rasi"
link "$REPO/hyprlock/hyprlock.conf" "$CONFIG/hypr/hyprlock.conf"
link "$REPO/hypridle/hypridle.conf" "$CONFIG/hypr/hypridle.conf"

echo ""
echo "Done! Reload Hyprland with: hyprctl reload"
echo ""
echo "Remember to set your wallpaper at: ~/.config/hypr/wallpaper"
