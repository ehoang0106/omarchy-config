# Omarchy Config Script

## Purpose

I have 2 PC running Omarchy OS, one is configured to my liking settings, the other is fresh installed.
I'm too lazy to config the fresh one manually, so I wrote this script to automate the process of copying my config over.

## What it does

1. **Backs up Waybar config** - Creates `.bak` files of existing `config.jsonc` and `style.css`
2. **Replaces Waybar config** - Clones this repo and copies new Waybar config files
3. **Configures Kitty** - Copies `kitty.conf` to `~/.config/kitty/`
4. **Sets Kitty as default terminal** - Updates `~/.config/uwsm/default`

## Usage

### One shot install!!!

```bash
curl -fsSL https://raw.githubusercontent.com/ehoang0106/omarchy-config/master/script.sh | bash
```



```bash
curl -fsSL https://raw.githubusercontent.com/ehoang0106/omarchy-config/master/claude-script.sh | bash
```


### Manual Install
Clone this repo.

```bash
chmod +x script.sh
./script.sh
```

## Notes

- A reboot is required after running to apply all changes
- Backups are stored in `~/.config/waybar/` with `.bak` extension
