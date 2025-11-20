#!/bin/bash

set -e #exit on error

#color

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

#section

section() {
  echo -e "${BOLD}${YELLOW}===================="
  echo -e "${BOLD}${BLUE}--- $1 ---${RESET}"
  echo -e "${BOLD}${YELLOW}===================="

}

section "Clone git repo"

#clone the git repo first to home directory
cd ~
git clone git@github.com:ehoang0106/omarchy-config.git

echo "Cloned omarchy-config repo to home directory..."

section "Install Waybar config"

#check if the file exists, file: ~/.config/waybar/config.jsonc and ~/.config/waybar/style.css

# if the files is exists, rename the file to old_config.jsonc and old_style.css
if [[ -f ~/.config/waybar/config.jsonc ]]; then
  mv ~/.config/waybar/config.jsonc ~/.config/waybar/old_config.jsonc
  mv ~/.config/waybar/style.css ~/.config/waybar/old_style.css
fi

#copy the config.jsonc and style.css in the repo just cloned to ~/.config/waybar/
cp ~/omarchy-config/waybar/config.jsonc ~/.config/waybar/config.jsonc
cp ~/omarchy-config/waybar/style.css ~/.config/waybar/style.css

#reload hyprland
hyprctl reload

section "Install kitty"

#check if kitty is installed

if [[ kitty --version &> /dev/null ]]; then
  echo -e "${GREEN}Kitty is already installed.${RESET}"
else
  echo -e "${YELLOW}Kitty is not installed. Installing kitty...${RESET}"
  sudo pacman -S kitty --noconfirm
  echo -e "${GREEN}Kitty installed successfully.${RESET}"
 fi

#install kitty config

section "Install Kitty config"

cp ~/omarchy-config/kitty/kitty.conf ~/.config/kitty/kitty.conf
echo -e "${GREEN}Kitty config installed successfully.${RESET}"

#change default terminal to kitty in omarchy

#edit the file ~/.config/uwsm/default, change the export TERMINAL=alacritty to export TERMINAL=kitty

TERMINAL_FILE=~/.config/uwsm/default

FIND_LINE="export TERMINAL=alacritty"
REPLACE_LINE="export TERMINAL=kitty"

if [[ -f "$TERMINAL_FILE" ]]; then
  sed -i "s|$FIND_LINE|$REPLACE_LINE|" "$TERMINAL_FILE"

  #check if the line is changed
  if grep -q "$REPLACE_LINE" "$TERMINAL_FILE"; then
    echo -e "${GREEN}Default terminal changed to kitty in omarchy.${RESET}"
  else
    echo -e "${RED}Failed to change default terminal to kitty in omarchy.${RESET}"
  fi
else
  echo -e "${RED}$TERMINAL_FILE does not exist. Cannot change default terminal.${RESET}"
fi














