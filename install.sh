#!/usr/bin/env bash
# NaruMa — Install script
# Installs required packages and symlinks config files into ~/.config/

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
BIN="$HOME/.local/bin"

# ── Helpers ───────────────────────────────────────────────────────────────────

log()  { echo "  $*"; }
info() { echo ""; echo "▸ $*"; }

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        log "Backing up $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sfn "$src" "$dst"
    log "Linked $dst"
}

has() { command -v "$1" &>/dev/null; }

aur_helper() {
    if has paru; then echo paru
    elif has yay; then echo yay
    else echo ""
    fi
}

# ── Packages ──────────────────────────────────────────────────────────────────

PACMAN_PKGS=(
    # Wayland / Hyprland core
    hyprland
    hyprlock
    hypridle
    hyprpicker
    xdg-desktop-portal-hyprland

    # Bar & notifications
    waybar
    mako

    # Launcher (rofi as fallback)
    rofi-wayland

    # Wallpaper & OSD
    swaybg
    swayosd

    # Screenshots
    grim
    slurp

    # Clipboard
    wl-clipboard
    cliphist

    # Brightness / media
    brightnessctl
    playerctl

    # Fonts & icons
    ttf-jetbrains-mono-nerd
    papirus-icon-theme
    noto-fonts-emoji

    # Auth agent
    polkit-gnome

    # Terminal (default)
    alacritty

    # Utils used in menus
    jq
    wf-recorder
)

# AUR packages (require paru or yay)
AUR_PKGS=(
    walker-bin      # fast GTK4 app launcher (elephant data provider included)
    grimblast-git   # screenshot helper (wraps grim+slurp)
)

install_packages() {
    info "Installing pacman packages…"
    local missing=()
    for pkg in "${PACMAN_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log "Installing: ${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    else
        log "All pacman packages already installed."
    fi

    local aur
    aur=$(aur_helper)
    if [[ -z $aur ]]; then
        echo ""
        echo "  ⚠ No AUR helper found (paru/yay). Skipping AUR packages:"
        for pkg in "${AUR_PKGS[@]}"; do
            echo "    - $pkg"
        done
        echo "  Install paru or yay, then re-run this script."
        return
    fi

    info "Installing AUR packages (${aur})…"
    local aur_missing=()
    for pkg in "${AUR_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            aur_missing+=("$pkg")
        fi
    done

    if [[ ${#aur_missing[@]} -gt 0 ]]; then
        log "Installing: ${aur_missing[*]}"
        "$aur" -S --needed --noconfirm "${aur_missing[@]}"
    else
        log "All AUR packages already installed."
    fi
}

# ── Bin scripts ───────────────────────────────────────────────────────────────

install_bin() {
    info "Installing NaruMa scripts to $BIN…"
    mkdir -p "$BIN"
    for script in "$REPO/bin/"*; do
        local name
        name="$(basename "$script")"
        cp "$script" "$BIN/$name"
        chmod +x "$BIN/$name"
        log "Installed $BIN/$name"
    done

    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$BIN:"* ]]; then
        echo ""
        echo "  ⚠ $BIN is not in your PATH."
        echo "  Add this to your ~/.bashrc or ~/.zshrc:"
        echo '    export PATH="$HOME/.local/bin:$PATH"'
    fi
}

# ── Config symlinks ───────────────────────────────────────────────────────────

install_config() {
    info "Linking Hyprland config…"
    link "$REPO/hyprland/hyprland.conf"    "$CONFIG/hypr/hyprland.conf"
    link "$REPO/hyprland/looknfeel.conf"   "$CONFIG/hypr/looknfeel.conf"
    link "$REPO/hyprland/input.conf"       "$CONFIG/hypr/input.conf"
    link "$REPO/hyprland/autostart.conf"   "$CONFIG/hypr/autostart.conf"
    link "$REPO/hyprland/keybindings.conf" "$CONFIG/hypr/keybindings.conf"
    link "$REPO/hyprland/rules.conf"       "$CONFIG/hypr/rules.conf"
    link "$REPO/hyprland/monitors.conf"    "$CONFIG/hypr/monitors.conf"
    link "$REPO/hyprlock/hyprlock.conf"    "$CONFIG/hypr/hyprlock.conf"
    link "$REPO/hypridle/hypridle.conf"    "$CONFIG/hypr/hypridle.conf"

    info "Linking Waybar config…"
    link "$REPO/waybar/config.jsonc" "$CONFIG/waybar/config.jsonc"
    link "$REPO/waybar/style.css"    "$CONFIG/waybar/style.css"

    info "Linking Mako config…"
    link "$REPO/mako/config" "$CONFIG/mako/config"

    info "Linking Rofi config…"
    link "$REPO/rofi/config.rasi" "$CONFIG/rofi/config.rasi"

    info "Linking Walker config…"
    link "$REPO/walker/config.toml"                           "$CONFIG/walker/config.toml"
    link "$REPO/walker/themes/naruma/layout.xml"              "$CONFIG/walker/themes/naruma/layout.xml"
    link "$REPO/walker/themes/naruma/style.css"               "$CONFIG/walker/themes/naruma/style.css"
}

# ── Wallpaper placeholder ─────────────────────────────────────────────────────

setup_wallpaper() {
    local wallpaper="$CONFIG/hypr/wallpaper"
    if [[ ! -f "$wallpaper" ]]; then
        info "Downloading default wallpaper (Catppuccin waves)…"
        mkdir -p "$CONFIG/hypr"
        if curl -sL \
            "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/waves/cat-waves.png" \
            -o "$wallpaper"; then
            log "Wallpaper saved to $wallpaper"
        else
            log "Download failed. Place any image at $wallpaper"
        fi
    else
        log "Wallpaper already set at $wallpaper"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

echo ""
echo "  NaruMa — Hyprland theme installer"
echo "  ──────────────────────────────────"

# Parse flags
SKIP_PKGS=false
for arg in "$@"; do
    [[ $arg == "--no-packages" ]] && SKIP_PKGS=true
done

if [[ $SKIP_PKGS == false ]]; then
    install_packages
fi

install_bin
install_config
setup_wallpaper

echo ""
echo "  ✓ Done!"
echo ""
echo "  Reload Hyprland:  hyprctl reload"
echo "  App launcher:     Super + Space"
echo "  System menu:      Super + Alt + Space"
echo ""
