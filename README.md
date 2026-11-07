# Umbriel Dotfiles

Complete, modular configuration for **[Umbriel](https://github.com/noctalia-dev/umbriel)** compositor paired with the **[Noctalia](https://github.com/noctalia-dev/noctalia)** shell.

---

## Architecture

Modular TOML configuration loaded via `config.toml`:

```text
~/.config/umbriel/
├── config.toml           # Main entry point (includes modules)
├── modules/              # Settings split by concern
│   ├── appearance.toml   # Borders, shadows, focus colors
│   ├── animations.toml   # Bezier curves, spring physics & GLSL shaders
│   ├── autostart.toml    # Daemons & session startup commands
│   ├── env.toml          # Environment variables & flags
│   ├── input.toml        # Keyboard, touchpads & pointer speeds
│   ├── keybinds.toml     # Window management, app shortcuts & scripts
│   ├── layer_rules.toml  # Blur & rules for Noctalia & overlays
│   ├── layout.toml       # Window tiling & gaps
│   ├── monitors.toml     # Output settings & workspace mappings
│   ├── rules.toml        # Floating rules & window behaviors
│   ├── scratchpad.toml   # Dropdown scratchpad workspace
│   └── workspaces.toml   # Workspace definitions & animations
├── scripts/              # Helper utilities
│   ├── apply-layout.sh       # Restores monitor layout via wlr-randr
│   ├── cycle-layout.sh       # Window layout cycle
│   ├── output-workspaces.sh  # Dynamic multi-monitor workspace daemon
│   ├── quickpaper.sh         # Wallpaper selector launcher
│   ├── screenshot.sh         # Area / screen screenshot utility
│   ├── toggle-monitor.sh     # Extended / single display switch
│   └── umbriel_monitor_gui.py# Visual monitor manager GUI
└── shader/               # GLSL animation shaders (glass-warp, perlin, etc.)
```

---

## Dependencies (Fedora)

Install all runtime dependencies and system tools via DNF:

```bash
sudo dnf install -y \
    wlr-randr \
    jq \
    wl-clipboard \
    wtype \
    grim \
    slurp \
    foot \
    nautilus \
    wlogout \
    playerctl \
    xhost \
    gnome-keyring \
    python3 \
    python3-gobject \
    python3-cairo
```

> **Compositor & Desktop Shell:**  
> - **[umbriel](https://github.com/noctalia-dev/umbriel)**
> - **[noctalia](https://github.com/noctalia-dev/noctalia)**
> - **[quickshell](https://github.com/outfoxxed/quickshell)**
> - **[snappy-switcher](https://github.com/CheikhNaro)** (or your preferred Wayland window switcher)
> - Polkit agent: `hyprpolkitagent` or `polkit-gnome`

---

## Installation

Clone this repository directly into `~/.config/umbriel`:

```bash
git clone https://github.com/CheikhNaro/umbrielDotfiles.git ~/.config/umbriel
chmod +x ~/.config/umbriel/scripts/*.sh ~/.config/umbriel/scripts/*.py
```

---

## Ecosystem & Companion Repositories

Enrich your desktop setup with other modules:

- **[umbrielMonitor](https://github.com/CheikhNaro/umbrielMonitor)** — Drag-and-drop monitor manager GUI for Umbriel.
- **[quickSoundWave](https://github.com/CheikhNaro/quickSoundWave)** — Sound-reactive audio visualizer and media widget built with Quickshell.
- **[quickPaper](https://github.com/CheikhNaro/quickPaper)** — Interactive wallpaper switcher built with Quickshell.
- **[rofiMojiPicker](https://github.com/CheikhNaro/rofiMojiPicker)** — Categorized emoji picker for Rofi on Wayland.
- **[ffthemes](https://github.com/CheikhNaro/ffthemes)** — Curated collection of Fastfetch themes.
- **[Wallpapers](https://github.com/CheikhNaro/Wallpapers)** — Curated wallpaper collection.
