#!/usr/bin/env bash
# NaruMa — Install script
# Installs required packages and symlinks config files into ~/.config/

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
BIN="$HOME/.config/naruma/bin"

# ── Helpers ───────────────────────────────────────────────────────────────────

log()  { echo "  $*"; }
info() { echo ""; echo "▸ $*"; }
has()  { command -v "$1" &>/dev/null; }

aur_helper() {
    if has paru; then echo paru
    elif has yay; then echo yay
    else echo ""
    fi
}

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

# ── Symlink manifest ───────────────────────────────────────────────────────────
# Parallel arrays: LINK_SRCS (relative to REPO) and LINK_DSTS (relative to CONFIG)

DEFAULT_THEME="catppuccin-mocha"

LINK_SRCS=(
    # Hyprland
    hyprland/hyprland.conf
    hyprland/looknfeel.conf
    hyprland/input.conf
    hyprland/autostart.conf
    hyprland/keybindings.conf
    hyprland/rules.conf
    hyprland/monitors.conf
    hypridle/hypridle.conf
    # Waybar
    waybar/config.jsonc
    waybar/style.css
    # Rofi
    rofi/config.rasi
    # Walker
    walker/config.toml
    walker/themes/naruma/layout.xml
    walker/themes/naruma/style.css
    # Alacritty
    alacritty/alacritty.toml
    # Theme color files (default: catppuccin-mocha)
    themes/$DEFAULT_THEME/colors.conf
    themes/$DEFAULT_THEME/colors.css
    themes/$DEFAULT_THEME/colors.css
    themes/$DEFAULT_THEME/colors.toml
    themes/$DEFAULT_THEME/colors.rasi
    themes/$DEFAULT_THEME/mako.config
    themes/$DEFAULT_THEME/hyprlock.conf
)

LINK_DSTS=(
    # Hyprland
    hypr/hyprland.conf
    hypr/looknfeel.conf
    hypr/input.conf
    hypr/autostart.conf
    hypr/keybindings.conf
    hypr/rules.conf
    hypr/monitors.conf
    hypr/hypridle.conf
    # Waybar
    waybar/config.jsonc
    waybar/style.css
    # Rofi
    rofi/config.rasi
    # Walker
    walker/config.toml
    walker/themes/naruma/layout.xml
    walker/themes/naruma/style.css
    # Alacritty
    alacritty/alacritty.toml
    # Theme color files
    hypr/naruma-colors.conf
    waybar/naruma-colors.css
    walker/themes/naruma/naruma-colors.css
    alacritty/naruma-colors.toml
    rofi/naruma-colors.rasi
    mako/config
    hypr/hyprlock.conf
)

# ── Hyprland version check ────────────────────────────────────────────────────

check_hyprland_update() {
    info "Checking Hyprland version…"

    # Refresh sync DB so we compare against the real latest
    log "Refreshing package database…"
    sudo pacman -Sy --quiet 2>/dev/null

    local installed latest
    installed=$(pacman -Qi hyprland 2>/dev/null | awk '/^Version/{print $3}')
    latest=$(pacman -Si hyprland 2>/dev/null | awk '/^Version/{print $3}')

    if [[ -z "$installed" ]]; then
        log "Hyprland not yet installed — will be installed with packages."
        return
    fi

    log "Installed : hyprland $installed"
    log "Latest    : hyprland $latest"

    if [[ "$installed" == "$latest" ]]; then
        log "Already on latest."
    else
        log "Update available — upgrading Hyprland before continuing…"
        sudo pacman -S --needed --noconfirm hyprland
        log "Hyprland upgraded to $latest."
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

    # Audio
    pamixer

    # Night light
    hyprsunset

    # Network manager GUI
    nm-connection-editor

    # Update notifications (checkupdates command)
    pacman-contrib

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
        pacman -Qi "$pkg" &>/dev/null || missing+=("$pkg")
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
        for pkg in "${AUR_PKGS[@]}"; do echo "    - $pkg"; done
        echo "  Install paru or yay, then re-run this script."
        return
    fi

    info "Installing AUR packages (${aur})…"
    local aur_missing=()
    for pkg in "${AUR_PKGS[@]}"; do
        pacman -Qi "$pkg" &>/dev/null || aur_missing+=("$pkg")
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
    local scripts=("$REPO/bin/"*)
    if [[ ! -e ${scripts[0]} ]]; then
        log "No scripts found in bin/."
        return
    fi
    for script in "${scripts[@]}"; do
        local name
        name="$(basename "$script")"
        cp "$script" "$BIN/$name"
        chmod +x "$BIN/$name"
        log "Installed $BIN/$name"
    done

    if [[ ":$PATH:" != *":$BIN:"* ]]; then
        echo ""
        echo "  ⚠ $BIN is not in your PATH."
        echo "  Add this to your ~/.bashrc or ~/.zshrc:"
        echo "    export PATH=\"$BIN:\$PATH\""
    fi
}

# ── Config symlinks ───────────────────────────────────────────────────────────

install_config() {
    local n=${#LINK_SRCS[@]}
    for (( i = 0; i < n; i++ )); do
        local section
        section="$(dirname "${LINK_DSTS[$i]}")"
        # Print section header on first entry for each top-level dir
        local top="${section%%/*}"
        if [[ $i -eq 0 || "${LINK_DSTS[$i-1]%%/*}" != "$top" ]]; then
            info "Linking ${top^} config…"
        fi
        link "$REPO/${LINK_SRCS[$i]}" "$CONFIG/${LINK_DSTS[$i]}"
    done

    # Write state files so naruma-theme can locate the repo
    mkdir -p "$CONFIG/naruma"
    echo "$REPO" > "$CONFIG/naruma/repo"
    if [[ ! -f "$CONFIG/naruma/theme" ]]; then
        echo "$DEFAULT_THEME" > "$CONFIG/naruma/theme"
    fi
    log "Active theme: $(cat "$CONFIG/naruma/theme")"
}

# ── Wallpaper ─────────────────────────────────────────────────────────────────

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

SKIP_PKGS=false
for arg in "$@"; do
    [[ $arg == "--no-packages" ]] && SKIP_PKGS=true
done

if [[ $SKIP_PKGS == false ]]; then
    check_hyprland_update
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
