# Omarchy Config Script

A bash script to configure Waybar and Kitty terminal for Omarchy (Hyprland).

## Prerequisites

- Git
- Waybar (with config at `~/.config/waybar/`)
- Kitty terminal

## What it does

1. **Backs up Waybar config** - Creates `.bak` files of existing `config.jsonc` and `style.css`
2. **Replaces Waybar config** - Clones this repo and copies new Waybar config files
3. **Configures Kitty** - Copies `kitty.conf` to `~/.config/kitty/`
4. **Sets Kitty as default terminal** - Updates `~/.config/uwsm/default`

## Usage

### Quick Install (curl)

```bash
curl -fsSL https://raw.githubusercontent.com/ehoang0106/omarchy-config/master/script.sh | bash
```

### Manual Install

```bash
chmod +x script.sh
./script.sh
```

## Notes

- A reboot is required after running to apply all changes
- Backups are stored in `~/.config/waybar/` with `.bak` extension
- Script files are cloned to `~/omarchy-config-script/`
