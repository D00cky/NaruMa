# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

NaruMa — a Hyprland theme/config set inspired by [Omarchy](https://github.com/basecamp/omarchy). Pure config project — no compiled code, no build step. Arch Linux / pacman only.

## Config structure

```
hyprland/       # Hyprland WM config (symlinked to ~/.config/hypr/)
  hyprland.conf   # entry point — sources all other files
  looknfeel.conf  # gaps, animations, blur, dwindle layout (no colors here)
  keybindings.conf
  input.conf
  autostart.conf
  monitors.conf   # edit this per-machine
  rules.conf      # window rules + opacity
waybar/           # status bar (config.jsonc + style.css)
walker/           # GTK4 app launcher (config.toml + themes/naruma/)
mako/             # notifications (config — symlinked from active theme)
rofi/             # fallback launcher
hyprlock/         # lock screen (symlinked from active theme)
hypridle/         # idle/suspend policy
alacritty/        # terminal (alacritty.toml + naruma-colors.toml symlink)
themes/           # color palettes — see Theme system below
bin/              # scripts (copied to ~/.config/naruma/bin/ on install)
  naruma-menu         # system menu (Super + Alt + Space)
  naruma-launch-apps  # app launcher wrapper (Super + Space)
  naruma-theme        # theme switcher
  naruma-check        # pre-flight config checker
install.sh        # installs packages + symlinks configs
uninstall.sh      # removes symlinks and state files
```

## Deploy

```sh
bash install.sh              # install packages, copy bin/, symlink configs
bash install.sh --no-packages  # skip pacman/AUR installs
hyprctl reload               # apply after install
```

Config files are symlinked from the repo — edit them in place and changes take effect immediately.

| Component | Reload command |
|---|---|
| Hyprland | `hyprctl reload` |
| Waybar | `pkill -SIGUSR2 waybar` |
| Mako | `makoctl reload` |

## Theme system

Themes live in `themes/<name>/` — each contains 6 files:

```
colors.conf     # Hyprland $color variables (sourced via naruma-colors.conf)
colors.css      # GTK CSS @define-color (Waybar + Walker)
colors.toml     # Alacritty [colors.*] sections
colors.rasi     # Rofi * {} color block
mako.config     # Full mako config
hyprlock.conf   # Full hyprlock config
```

`naruma-theme` works by replacing a set of symlinks that point into the active theme directory. The active theme name is stored in `~/.config/naruma/theme`; the repo path is stored in `~/.config/naruma/repo` (written by `install.sh`).

Theme color symlinks (replaced on every `naruma-theme <name>` call):

| Symlink | Points to |
|---|---|
| `~/.config/hypr/naruma-colors.conf` | `themes/<name>/colors.conf` |
| `~/.config/waybar/naruma-colors.css` | `themes/<name>/colors.css` |
| `~/.config/walker/themes/naruma/naruma-colors.css` | `themes/<name>/colors.css` |
| `~/.config/alacritty/naruma-colors.toml` | `themes/<name>/colors.toml` |
| `~/.config/rofi/naruma-colors.rasi` | `themes/<name>/colors.rasi` |
| `~/.config/mako/config` | `themes/<name>/mako.config` |
| `~/.config/hypr/hyprlock.conf` | `themes/<name>/hyprlock.conf` |

Shipped themes: `catppuccin-mocha` (default), `sakura`, `cyberpunk`, `pokemon`.

```sh
naruma-theme sakura   # apply theme (reloads hyprland, waybar, mako)
naruma-theme          # open picker (walker/rofi dmenu)
naruma-theme list     # list themes with active marker
```

To add a custom theme, create `themes/my-theme/` with all 6 files (use an existing theme as template), then run `naruma-theme my-theme`.

## Bin scripts

`bin/naruma-menu` — hierarchical system menu using walker `--dmenu` (falls back to rofi):

```sh
naruma-menu system    # lock/suspend/reboot/shutdown/logout
naruma-menu capture   # screenshot / screen record
naruma-menu toggle    # bar, nightlight, gaps, idle lock
naruma-menu config    # open config files in $EDITOR
```

`bin/naruma-check` — pre-flight checker; validates symlinks, active theme, fonts, Hyprland version, and config errors after a live reload. Exit 0 = clean, 1 = errors:

```sh
naruma-check
```

`bin/naruma-launch-apps` — starts the walker service (and elephant data provider) if not running, then opens the launcher.

## Key bindings summary

| Binding | Action |
|---|---|
| `Super + Space` | App launcher (Walker) |
| `Super + Alt + Space` | System menu (naruma-menu) |
| `Super + Escape` | System submenu directly |
| `Super + Enter` | Terminal |
| `Super + W` | Close window |
| `Super + F` | Fullscreen |
| `Super + T` | Toggle float |
| `Super + S` | Scratchpad |
| `Super + G` | Toggle group |
| `Super + Tab` | Next workspace |
| `Super + 1-0` | Switch workspace |
| `Super + Shift + 1-0` | Move window to workspace |
| `Super + arrows` | Focus direction |
| `Super + Shift + arrows` | Swap windows |
| `Super + Backspace` | Toggle transparency |
| `Super + Ctrl + L` | Lock screen |

## Sandbox

This project uses [ai-jail](https://github.com/akitaonrails/ai-jail) to sandbox Claude Code. The configuration is in `.ai-jail`. Filesystem access can be restricted via `rw_maps` and `ro_maps` entries in that file.
