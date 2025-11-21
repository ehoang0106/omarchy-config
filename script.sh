#!/bin/bash

set -eu # -e: exit on error, -u: treat unset variables as an error


#===========
#color
#==========

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

#===========
#section
#===========


section() {
  echo -e "${BOLD}${YELLOW}======================================="
  echo -e "${BOLD}${BLUE}--- $1 ---${RESET}"
  echo -e "${BOLD}${YELLOW}======================================="

}

print_banner(){
  echo -e "${BOLD}"
  ASCII_ART=$(cat ascii.txt)
  echo -e "$ASCII_ART"
}

print_banner

section "Backing up Waybar Config Files"

#backup the exsiting config.jsonc and style.css in ~/.config/waybar/
backup_waybar_config() {
  echo -e "${YELLOW}Backing up existing Waybar config files..."
  pause 1
  WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
  if [[ -f "$WAYBAR_CONFIG_DIR/config.jsonc" ]]; then
    cp $WAYBAR_CONFIG_DIR/config.jsonc $WAYBAR_CONFIG_DIR/config.jsonc.bak
    cp $WAYBAR_CONFIG_DIR/style.css $WAYBAR_CONFIG_DIR/style.css.bak
    echo -e "${GREEN}Backup completed.$WAYBAR_CONFIG_DIR"
    pause 1
  else
    echo -e "${RED}Unable to find existing Waybar config files. Exiting..."
    exit 1
  fi
}

backup_waybar_config














