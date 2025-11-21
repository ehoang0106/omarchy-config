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
#end-color
#==========



#===========
#section
#===========


section() {
  echo -e "${BOLD}======================================="
  echo -e "${BOLD}--- $1 ---"
  echo -e "${BOLD}======================================="

}


#===========
#end-section
#===========



#==========
#variables
#=========


WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
GITHUB_REPO_URL="git@github.com:ehoang0106/omarchy-config.git"


#==========
#end-variables
#=========


#print banner
print_banner(){
  echo -e "${BOLD}"
  ASCII_ART=$(cat ascii.txt)
  echo -e "$ASCII_ART"
}

print_banner



#backup the exsiting config.jsonc and style.css in ~/.config/waybar/
backup_waybar_config() {
  section "Backing up Waybar Config Files"
  
  echo -e "${YELLOW}Backing up existing Waybar config files...${RESET}"
  sleep 1
  if [[ -f "$WAYBAR_CONFIG_DIR/config.jsonc" ]]; then
    cp $WAYBAR_CONFIG_DIR/config.jsonc $WAYBAR_CONFIG_DIR/config.jsonc.bak
    cp $WAYBAR_CONFIG_DIR/style.css $WAYBAR_CONFIG_DIR/style.css.bak
    echo -e "${GREEN}Backup completed.$WAYBAR_CONFIG_DIR${RESET}"
    echo -e "${GREEN}Done.${RESET}"
    sleep 1
  else
    echo -e "${RED}Unable to find existing Waybar config files. Exiting...${RESET}"
    exit 1
  fi
}

backup_waybar_config

replacing_waybar_config() {
  section "Replacing Waybar Config Files"
  #clone the git repo contains waybar config files and kitty config files
  cd $HOME
  mkdir omarchy-config-script && cd omarchy-config-script
  git clone $GITHUB_REPO_URL
  cd omarchy-config
  cd waybar
  cp config.jsonc $WAYBAR_CONFIG_DIR/config.jsonc
  cp style.css $WAYBAR_CONFIG_DIR/style.css
  echo -e "${GREEN}Waybar config files have been replaced successfully."
  echo -e "${GREEN}Done.${RESET}"
  sleep 1
  cd $HOME
  echo -e "Reload Waybar to apply the new configuration..."
  hyprctl reload
}


replacing_waybar_config









