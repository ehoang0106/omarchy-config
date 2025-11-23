#!/bin/bash

set -eu # -e: exit on error, -u: treat unset variables as an error


#===========
# Colors & Styles
#===========

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Spinner characters
SPINNER_CHARS='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

#===========
# Variables
#===========

WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
GITHUB_REPO_URL="git@github.com:ehoang0106/omarchy-config.git"
TERMINAL_CONFIG_FILE="$HOME/.config/uwsm/default"
NEW_TERMINAL="kitty"
OLD_TERMINAL="alacritty"


#===========
# Helper Functions
#===========

# Print a styled section header
section() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}║${WHITE}${BOLD}  $1${RESET}"
  echo -e "${CYAN}╚══════════════════════════════════════════════╝${RESET}"
  echo ""
}

# Spinner animation for background tasks
spinner() {
  local pid=$1
  local message=$2
  local i=0
  local spin_len=${#SPINNER_CHARS}

  tput civis # Hide cursor
  while kill -0 "$pid" 2>/dev/null; do
    local char="${SPINNER_CHARS:$i:1}"
    printf "\r  ${MAGENTA}%s${RESET} ${DIM}%s${RESET}" "$char" "$message"
    i=$(( (i + 1) % spin_len ))
    sleep 0.1
  done
  tput cnorm # Show cursor
  printf "\r"
}

# Progress dots animation
progress_dots() {
  local message=$1
  local duration=${2:-3}
  local dots=""

  for i in $(seq 1 $duration); do
    dots+="."
    printf "\r  ${YELLOW}%s%s${RESET}" "$message" "$dots"
    sleep 0.5
  done
  printf "\r\033[K"
}

# Print success message
success() {
  echo -e "  ${GREEN}✓${RESET} ${WHITE}$1${RESET}"
}

# Print error message
error() {
  echo -e "  ${RED}✗${RESET} ${RED}$1${RESET}"
}

# Print info message
info() {
  echo -e "  ${BLUE}ℹ${RESET} ${DIM}$1${RESET}"
}

# Print warning message
warn() {
  echo -e "  ${YELLOW}⚠${RESET} ${YELLOW}$1${RESET}"
}

# Animated text typing effect
type_text() {
  local text=$1
  local delay=${2:-0.03}

  for (( i=0; i<${#text}; i++ )); do
    printf "%s" "${text:$i:1}"
    sleep $delay
  done
  echo ""
}

# Print banner with animation
print_banner() {
  clear
  echo ""
  echo -e "${MAGENTA}${BOLD}"
  cat << 'EOF'
   ____  __  __    _    ____   ____ _   ___   __
  / __ \|  \/  |  / \  |  _ \ / ___| | | \ \ / /
 | |  | | |\/| | / _ \ | |_) | |   | |_| |\ V /
 | |__| | |  | |/ ___ \|  _ <| |___|  _  | | |
  \____/|_|  |_/_/   \_\_| \_\\____|_| |_| |_|

   _____ ___  _   _ _____ ___ ____
  / ____/ _ \| \ | |  ___|_ _/ ___|
 | |   | | | |  \| | |_   | | |  _
 | |___| |_| | |\  |  _|  | | |_| |
  \____|\___/|_| \_|_|   |___\____|

EOF
  echo -e "${RESET}"
  echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "  ${CYAN}Waybar & Kitty Configuration Script${RESET}"
  echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
  sleep 1
}


#===========
# Main Functions
#===========

# Check prerequisites
check_prerequisites() {
  section "Checking Prerequisites"

  # Check if git is installed
  if ! command -v git &> /dev/null; then
    error "Git is not installed. Please install Git and try again."
    exit 1
  else
    success "Git is installed"
  fi

  # Check if Waybar config directory exists
  if [[ ! -d "$WAYBAR_CONFIG_DIR" ]]; then
    error "Waybar config directory not found at $WAYBAR_CONFIG_DIR"
    info "Please ensure Waybar is installed and configured"
    exit 1
  else
    success "Waybar config directory found"
  fi

  # Check if kitty is installed
  if ! command -v kitty &> /dev/null; then
    error "Kitty terminal is not installed. Please install Kitty and try again."
    exit 1
  else
    success "Kitty terminal is installed"
  fi

  echo ""
  echo -e "  ${GREEN}${BOLD}All prerequisites met!${RESET}"
  sleep 1
}


# Backup Waybar config
backup_waybar_config() {
  section "Backing Up Waybar Config"

  info "Creating backup of existing config files..."
  sleep 0.5

  if [[ -f "$WAYBAR_CONFIG_DIR/config.jsonc" ]]; then
    (
      cp "$WAYBAR_CONFIG_DIR/config.jsonc" "$WAYBAR_CONFIG_DIR/config.jsonc.bak"
      cp "$WAYBAR_CONFIG_DIR/style.css" "$WAYBAR_CONFIG_DIR/style.css.bak"
      sleep 1
    ) &
    spinner $! "Backing up config.jsonc and style.css"

    success "Backup completed"
    info "Location: $WAYBAR_CONFIG_DIR"
  else
    error "Unable to find existing Waybar config files"
    exit 1
  fi
  sleep 0.5
}


# Replace Waybar config
replacing_waybar_config() {
  section "Replacing Waybar Config"

  info "Cloning configuration repository..."

  cd "$HOME"

  # Remove existing directory if it exists
  if [[ -d "omarchy-config-script" ]]; then
    rm -rf omarchy-config-script
  fi

  mkdir omarchy-config-script && cd omarchy-config-script

  (
    git clone "$GITHUB_REPO_URL" 2>/dev/null
    sleep 1
  ) &
  spinner $! "Downloading configuration files"

  success "Repository cloned"

  cd omarchy-config/waybar

  info "Copying new config files..."
  sleep 0.5

  cp config.jsonc "$WAYBAR_CONFIG_DIR/config.jsonc"
  cp style.css "$WAYBAR_CONFIG_DIR/style.css"

  success "Waybar config files replaced"

  cd "$HOME"

  info "Reloading Waybar..."
  (
    hyprctl reload 2>/dev/null
    sleep 1
  ) &
  spinner $! "Applying new configuration"

  success "Waybar reloaded"
}


# Configure Kitty terminal
kitty_config() {
  section "Setting Up Kitty Terminal"

  info "Configuring Kitty terminal..."

  cd "$HOME/omarchy-config-script/omarchy-config/kitty"

  (
    cp kitty.conf "$HOME/.config/kitty/kitty.conf"
    sleep 1
  ) &
  spinner $! "Copying Kitty configuration"

  success "Kitty configuration completed"
}


# Set Kitty as default terminal
kitty_default_terminal() {
  section "Setting Default Terminal"

  info "Updating default terminal to Kitty..."

  (
    sed -i "s/export TERMINAL=$OLD_TERMINAL/export TERMINAL=$NEW_TERMINAL/g" "$TERMINAL_CONFIG_FILE"
    sleep 1
  ) &
  spinner $! "Updating terminal configuration"

  success "Kitty is now the default terminal"
}


# Modify key binding configuration
modify_binding_config() {
  section "Modifying Key Binding Configuration"

  info "Updating Hyprland key bindings..."

  (
    cp "$HOME/omarchy-config-script/omarchy-config/hyprland/bindings.conf" "$HOME/.config/hyprland/bindings.conf"
    sleep 1
  ) &
  spinner $! "Copying bindings configuration"

  success "Key binding configuration updated"
}


# Clean up temporary files
clean_up() {
  section "Cleaning Up"

  info "Removing temporary files..."

  (
    rm -rf "$HOME/omarchy-config-script"
    sleep 1
  ) &
  spinner $! "Cleaning up temporary files"

  success "Temporary files removed"
  echo ""

  # Final message with animation
  echo -e "  ${YELLOW}${BOLD}┌─────────────────────────────────────────┐${RESET}"
  echo -e "  ${YELLOW}${BOLD}│                                         │${RESET}"
  echo -e "  ${YELLOW}${BOLD}│   ⚠  REBOOT REQUIRED TO APPLY CHANGES   │${RESET}"
  echo -e "  ${YELLOW}${BOLD}│                                         │${RESET}"
  echo -e "  ${YELLOW}${BOLD}└─────────────────────────────────────────┘${RESET}"
  echo ""
}


# Completion message
print_completion() {
  echo ""
  echo -e "  ${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "  ${GREEN}${BOLD}  Configuration Complete!${RESET}"
  echo -e "  ${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
  echo -e "  ${DIM}Thank you for using Omarchy Config${RESET}"
  echo ""
}


#===========
# Main Execution
#===========

main() {
  print_banner
  check_prerequisites
  backup_waybar_config
  replacing_waybar_config
  kitty_config
  kitty_default_terminal
  modify_binding_config
  clean_up
  print_completion
}

main
