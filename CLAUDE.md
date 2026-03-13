# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

NaruMa — a Hyprland theme/config set inspired by [Omarchy](https://github.com/basecamp/omarchy), using the Catppuccin Mocha color palette. This is a pure config project — no compiled code, no build step.

## Config structure

```
hyprland/       # Hyprland WM config (symlinked to ~/.config/hypr/)
  hyprland.conf   # entry point — sources all other files
  looknfeel.conf  # colors, gaps, animations, blur, dwindle layout
  keybindings.conf
  input.conf
  autostart.conf
  monitors.conf   # edit this per-machine
  rules.conf      # window rules + opacity
waybar/         # status bar
  config.jsonc
  style.css
walker/         # GTK4 app launcher (primary)
  config.toml
  themes/naruma/layout.xml
  themes/naruma/style.css
mako/           # notifications
  config
rofi/           # fallback launcher (used if walker is not installed)
  config.rasi
hyprlock/       # lock screen
  hyprlock.conf
hypridle/       # idle/suspend policy
  hypridle.conf
bin/            # scripts (copied to ~/.config/naruma/bin/)
  naruma-menu         # system menu (Super + Alt + Space)
  naruma-launch-apps  # app launcher wrapper (Super + Space)
install.sh      # installs packages + symlinks configs
```

## Deploy

```sh
bash install.sh              # install packages, copy bin/, symlink configs
bash install.sh --no-packages  # skip pacman/AUR installs
hyprctl reload               # apply after install
```

Config files are symlinked from the repo — edit them in place and changes take effect immediately. Hyprland requires `hyprctl reload`; Waybar reloads on CSS save; Mako needs `makoctl reload`.

## Bin scripts

`bin/naruma-menu` is a hierarchical system menu using walker `--dmenu` (falls back to rofi). It can be invoked directly with a submenu name to open that submenu and exit on dismiss:

```sh
naruma-menu system    # lock/suspend/reboot/shutdown/logout
naruma-menu capture   # screenshot / screen record
naruma-menu toggle    # bar, nightlight, gaps, idle lock
naruma-menu config    # open config files in $EDITOR
```

`bin/naruma-launch-apps` starts the walker service (and elephant data provider) if not running, then opens the launcher.

## Color palette — Catppuccin Mocha

Colors are defined at the top of `hyprland/looknfeel.conf` and `waybar/style.css`. To change the palette, replace hex values in those two files — everything else inherits from them.

Key values:
- Background: `#1e1e2e`, Mantle: `#181825`, Surface: `#313244`
- Text: `#cdd6f4`, Subtext: `#bac2de`
- Blue (accent): `#89b4fa`, Teal: `#94e2d5`, Green: `#a6e3a1`
- Active border: blue→teal 45deg gradient
- Inactive border: `rgba(45475aaa)`

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
