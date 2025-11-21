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
  echo -e ""
  echo -e "${BOLD}======================================="
  echo -e "${BOLD}--- $1 ---"
  echo -e "${BOLD}======================================="
  echo -e ""
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

#checking prerequisites

check_prerequisites() {
  section "Checking Prerequisites"

  #check if git is installed
  if ! command -v git &> /dev/null; then
    echo -e "${RED}Git is not installed. Please install Git and try again.${RESET}"
    exit 1
  else
    echo -e "${GREEN}✓ Git is installed.${RESET}"
  fi

  #check if Waybar config directory exists
  if [[ ! -d "$WAYBAR_CONFIG_DIR" ]]; then
    echo -e "${RED}Waybar config directory not found at $WAYBAR_CONFIG_DIR. Please ensure Waybar is installed and configured.${RESET}"
    exit 1
  else
    echo -e "${GREEN}✓ Waybar config directory is found.${RESET}"
  fi

  #check if kitty is installed
  if ! command -v kitty &> /dev/null; then
    echo -e "${RED}Kitty terminal is not installed. Please install Kitty and try again.${RESET}"
    exit 1
  else
    echo -e "${GREEN}✓ Kitty terminal is installed.${RESET}"
  fi

  echo -e "${GREEN}✓ All prerequisites are met.${RESET}"
  sleep 1
}

check_prerequisites

#------------WAYBAR CONFIGURATION-------------

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


#------------END WAYBAR CONFIGURATION-------------



#------------KITTY CONFIGURATION-------------

kitty_config() {
  section "Setting Up Kitty Terminal Configuration"
  
  echo -e "${YELLOW}Configuring Kitty terminal...${RESET}"
  cd $HOME/omarchy-config-script/omarchy-config/kitty
  cp kitty.conf $HOME/.config/kitty/kitty.conf
  sleep 1

  echo -e "${GREEN}Kitty terminal configuration completed.${RESET}"
  echo -e "${GREEN}Done.${RESET}"
  sleep 1
  echo -e ""
  echo -e "${YELLOW}Reboot is required to apply all changes.${RESET}"

}

kitty_config

#------------END KITTY CONFIGURATION-------------



#------------MAKE KITTY THE DEFAULT TERMINAL-------------

kitty_default_terminal() {
  section "Setting Kitty as the Default Terminal"






}



