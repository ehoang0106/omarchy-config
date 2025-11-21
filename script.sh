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
  echo -e "${BOLD}${YELLOW}===================="
  echo -e "${BOLD}${BLUE}--- $1 ---${RESET}"
  echo -e "${BOLD}${YELLOW}===================="

}

print_banner(){
  echo -e "${BOLD}"
  ASCII_ART=$(cat ascii.txt)
  echo -e "$ASCII_ART"
}

print_banner

echo -e "${GREEN}Backing up existing Waybar config files..."

#backup the exsiting config.jsonc and style.css in ~/.config/waybar/
WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
mv $WAYBAR_CONFIG_DIR/config.jsonc $WAYBAR_CONFIG_DIR/config.jsonc.bak
mv $WAYBAR_CONFIG_DIR/style.css $WAYBAR_CONFIG_DIR/style.css.bak



#clone the git repo contains waybar config files and kitty config files
GITHUB_REPO_URL="git@github.com:ehoang0105/omarchy-config.git"
cd $HOME
mkdir omarchy-config-script && cd omarchy-config-script
git clone $GITHUB_REPO_URL
cd omarchy-config














