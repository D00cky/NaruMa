# NaruMa

A minimal Hyprland theme inspired by [Omarchy](https://github.com/basecamp/omarchy).

**Naru** comes from the Japanese word *naruhodo* (なるほど) — "I get it", "I see". Just as Omarchy takes its name from *omakase* ("I'll leave it to you", trusting the chef to handle things), NaruMa flips that around: you get it, you handle it, you're on your own. A setup that makes sense the moment you look at it, then gets out of your way.

Minimal by design. No magic scripts, no abstractions. Just Hyprland config files you can read and change.

---

## What's included

- **Hyprland** — window manager config (look & feel, keybindings, rules, input, autostart)
- **Waybar** — minimal top bar with icon-only modules
- **Rofi** — app launcher
- **Mako** — notifications
- **Hyprlock** — lock screen
- **Hypridle** — idle/suspend policy

All styled with the [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) palette.

---

## Install

Clone the repo and run the install script:

```sh
git clone https://github.com/D00cky/NaruMa.git ~/.config/naruma
cd ~/.config/naruma
bash install.sh
```

The script symlinks all config files into `~/.config/`. Any existing files are backed up with a `.bak` extension before being replaced.

Then reload Hyprland:

```sh
hyprctl reload
```

### Wallpaper

Set your wallpaper by placing any image at:

```sh
~/.config/hypr/wallpaper
```

Then restart `swaybg` (it launches automatically on login via `autostart.conf`):

```sh
pkill swaybg
swaybg -i ~/.config/hypr/wallpaper -m fill &
```

---

## Modifying the config

All files live in the repo and are symlinked — edit them in place and they take effect immediately (Waybar reloads on CSS save; Hyprland needs `hyprctl reload`).

| File | What to change |
|---|---|
| `hyprland/monitors.conf` | Resolution, refresh rate, scale per monitor |
| `hyprland/looknfeel.conf` | Colors, gaps, border size, animations, blur |
| `hyprland/keybindings.conf` | Add, remove, or remap any keybinding |
| `hyprland/input.conf` | Keyboard layout, touchpad behavior |
| `hyprland/autostart.conf` | Apps to launch on login |
| `hyprland/rules.conf` | Per-app window rules and opacity |
| `waybar/config.jsonc` | Bar modules and layout |
| `waybar/style.css` | Bar colors and spacing |
| `mako/config` | Notification position, colors, timeout |
| `rofi/config.rasi` | Launcher colors and dimensions |
| `hyprlock/hyprlock.conf` | Lock screen layout |
| `hypridle/hypridle.conf` | Idle timeouts for dim, lock, and suspend |

### Changing the color scheme

Colors are defined at the top of `hyprland/looknfeel.conf` and `waybar/style.css`. Both use Catppuccin Mocha variables. To switch palette, replace the hex values in those two files — everything else inherits from them.

---

## Key bindings

| Binding | Action |
|---|---|
| `Super + Enter` | Terminal |
| `Super + Space` | App launcher |
| `Super + W` | Close window |
| `Super + F` | Fullscreen |
| `Super + T` | Toggle float |
| `Super + S` | Scratchpad |
| `Super + G` | Toggle group |
| `Super + Tab` | Next workspace |
| `Super + 1–0` | Switch workspace |
| `Super + Shift + 1–0` | Move window to workspace |
| `Super + arrows` | Focus direction |
| `Super + Shift + arrows` | Swap windows |
| `Super + Backspace` | Toggle window transparency |
| `Super + Ctrl + L` | Lock screen |

Full list in `hyprland/keybindings.conf`.
