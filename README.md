# NaruMa

A minimal Hyprland theme inspired by [Omarchy](https://github.com/basecamp/omarchy).

**Naru** comes from the Japanese word *naruhodo* (なるほど) — "I get it", "I see". Just as Omarchy takes its name from *omakase* ("I'll leave it to you", trusting the chef to handle things), NaruMa flips that around: you get it, you handle it, you're on your own. A setup that makes sense the moment you look at it, then gets out of your way.

Minimal by design. No magic scripts, no abstractions. Just Hyprland config files you can read and change.

---

## What's included

- **Hyprland** — window manager config (look & feel, keybindings, rules, input, autostart)
- **Waybar** — minimal top bar with icon-only modules
- **Walker** — fast GTK4 app launcher with search (`Super + Space`)
- **naruma-menu** — system menu with search (`Super + Alt + Space`)
- **Rofi** — fallback launcher if walker is not installed
- **Mako** — notifications
- **Hyprlock** — lock screen
- **Hypridle** — idle/suspend policy
- **Alacritty** — terminal, themed to match

All styled with the [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) palette by default, with 3 additional themes included.

---

## Install

Clone the repo and run the install script:

```sh
git clone https://github.com/D00cky/NaruMa.git ~/.config/naruma
cd ~/.config/naruma
bash install.sh
```

The script will:
1. Install all required packages via `pacman` (and AUR packages via `paru` or `yay` if available)
2. Copy `bin/naruma-*` scripts to `~/.config/naruma/bin/`
3. Symlink all config files into `~/.config/` (existing files are backed up as `.bak`)
4. Download the default wallpaper if none is set

Then reload Hyprland:

```sh
hyprctl reload
```

To skip package installation (e.g. if you manage packages separately):

```sh
bash install.sh --no-packages
```

### Required packages

Installed automatically by the script. Listed here for reference:

**pacman:** `hyprland` `hyprlock` `hypridle` `hyprpicker` `waybar` `mako` `rofi-wayland` `swaybg` `swayosd` `grim` `slurp` `wl-clipboard` `cliphist` `brightnessctl` `playerctl` `ttf-jetbrains-mono-nerd` `papirus-icon-theme` `noto-fonts-emoji` `polkit-gnome` `alacritty` `jq` `wf-recorder`

**AUR:** `walker-bin` `grimblast-git`

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

## Diagnosing issues

Run the pre-flight checker at any time to validate your setup:

```sh
naruma-check
```

It will verify symlinks, active theme, required fonts, and scan the Hyprland log for config errors after a reload. Exit code is 0 if clean, 1 if errors were found.

---

## Themes

NaruMa ships with 4 themes. Switch via command or the system menu (`Super + Alt + Space` → Theme):

```sh
naruma-theme sakura        # apply a theme
naruma-theme               # open picker (walker/rofi dmenu)
naruma-theme list          # list all themes
```

| Theme | Description |
|---|---|
| `catppuccin-mocha` | Default — dark purple background, blue/teal accent gradient |
| `sakura` | Deep plum background, cherry blossom pink + soft lavender gradient |
| `cyberpunk` | Near-black, electric cyan + neon magenta gradient |
| `pokemon` | Dark navy, Pikachu yellow + sky blue gradient |

### Adding a custom theme

Create a directory in `themes/` with 6 files:

```
themes/my-theme/
  colors.conf       # Hyprland $variables
  colors.css        # GTK CSS @define-color (Waybar + Walker)
  colors.toml       # Alacritty [colors.*] sections
  colors.rasi       # Rofi * {} color block
  mako.config       # Full mako config
  hyprlock.conf     # Full hyprlock config
```

Use any existing theme as a template. Then apply it:

```sh
naruma-theme my-theme
```

---

## Modifying the config

All files live in the repo and are symlinked — edit them in place and changes take effect immediately (Waybar reloads on CSS save; Hyprland needs `hyprctl reload`).

| File | What to change |
|---|---|
| `hyprland/monitors.conf` | Resolution, refresh rate, scale per monitor |
| `hyprland/looknfeel.conf` | Gaps, border size, animations, blur |
| `hyprland/keybindings.conf` | Add, remove, or remap any keybinding |
| `hyprland/input.conf` | Keyboard layout, touchpad behavior |
| `hyprland/autostart.conf` | Apps to launch on login |
| `hyprland/rules.conf` | Per-app window rules and opacity |
| `waybar/config.jsonc` | Bar modules and layout |
| `waybar/style.css` | Bar spacing and structure |
| `walker/config.toml` | App launcher behavior and providers |
| `bin/naruma-menu` | System menu entries and actions |
| `bin/naruma-theme` | Theme switcher logic |
| `hypridle/hypridle.conf` | Idle timeouts for dim, lock, and suspend |
| `alacritty/alacritty.toml` | Terminal font size and window settings |

### Changing the color scheme

Colors live in `themes/<name>/`. Each theme file is small and self-contained. To tweak the active theme, edit the files in its directory — changes take effect on the next `naruma-theme <name>` call (or `hyprctl reload` for Hyprland-side changes).

---

## Key bindings

| Binding | Action |
|---|---|
| `Super + Space` | App launcher (Walker — with search) |
| `Super + Alt + Space` | System menu (with search) |
| `Super + Enter` | Terminal |
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
| `Super + Escape` | System submenu (lock/suspend/shutdown) |

Full list in `hyprland/keybindings.conf`.
