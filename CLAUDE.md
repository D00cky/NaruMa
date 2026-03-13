# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

NaruMa — a Hyprland theme/config set inspired by [Omarchy](https://github.com/basecamp/omarchy), using the Catppuccin Mocha color palette. Currently in early development.

## Config structure

```
hyprland/       # Hyprland WM config (source into ~/.config/hypr/)
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
mako/           # notifications
  config
rofi/           # app launcher
  config.rasi
hyprlock/       # lock screen
  hyprlock.conf
hypridle/       # idle/suspend policy
  hypridle.conf
install.sh      # symlinks everything into ~/.config/
```

## Deploy

```sh
bash install.sh          # symlink configs, backs up existing files
hyprctl reload           # apply after install
```

Set your wallpaper at `~/.config/hypr/wallpaper` (any image file).

## Color palette — Catppuccin Mocha

Key colors used throughout all configs:
- Background: `#1e1e2e`, Mantle: `#181825`, Surface: `#313244`
- Text: `#cdd6f4`, Subtext: `#bac2de`
- Blue (accent): `#89b4fa`, Teal: `#94e2d5`, Green: `#a6e3a1`
- Active border: blue→teal 45deg gradient
- Inactive border: `rgba(45475aaa)`

## Key bindings summary

| Binding | Action |
|---|---|
| `Super + Enter` | Terminal |
| `Super + Space` | App launcher (rofi) |
| `Super + W` | Close window |
| `Super + F` | Fullscreen |
| `Super + T` | Toggle float |
| `Super + S` | Scratchpad |
| `Super + 1-0` | Switch workspace |
| `Super + Shift + 1-0` | Move window to workspace |
| `Super + arrows` | Focus direction |
| `Super + Shift + arrows` | Swap windows |
| `Super + Tab` | Next workspace |
| `Super + G` | Toggle group |
| `Super + Ctrl + L` | Lock screen |
| `Super + Backspace` | Toggle transparency |

## Common Commands

```sh
cargo build          # compile
cargo run            # build and run
cargo test           # run all tests
cargo test <name>    # run a single test by name
cargo clippy         # lint
cargo fmt            # format code
```

## Sandbox

This project uses [ai-jail](https://github.com/akitaonrails/ai-jail) to sandbox Claude Code. The configuration is in `.ai-jail`. Filesystem access can be restricted via `rw_maps` and `ro_maps` entries in that file.
