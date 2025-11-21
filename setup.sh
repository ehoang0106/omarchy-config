#!/bin/bash

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="Omarchy Config Setup"
readonly SCRIPT_VERSION="1.0.0"
readonly REPO_URL="git@github.com:ehoang0106/omarchy-config.git"
readonly REPO_DIR="$HOME/omarchy-config"

# ============================================================================
# COLORS & STYLES
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'

# Symbols
readonly CHECKMARK="${GREEN}✓${RESET}"
readonly CROSSMARK="${RED}✗${RESET}"
readonly ARROW="${CYAN}➜${RESET}"
readonly INFO="${BLUE}ℹ${RESET}"
readonly WARN="${YELLOW}⚠${RESET}"

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

STEP_COUNT=0
TOTAL_STEPS=5
ERRORS=()
WARNINGS=()

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

print_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
   ____                        _
  / __ \____ ___  ____ _______| |__  _   _
 / / / / __ `__ \/ __ `/ ___/ __ \| | | |
/ /_/ / / / / / / /_/ / /  / /_/ /| |_| |
\____/_/ /_/ /_/\__,_/_/  /_.___/  \__, |
                                   |___/
EOF
    echo -e "${RESET}"
    echo -e "${DIM}${SCRIPT_NAME} v${SCRIPT_VERSION}${RESET}"
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
}

section() {
    ((STEP_COUNT++))
    echo
    echo -e "${BOLD}${WHITE}[$STEP_COUNT/$TOTAL_STEPS]${RESET} ${BOLD}${CYAN}$1${RESET}"
    echo -e "${DIM}────────────────────────────────────────${RESET}"
}

log_info() {
    echo -e "  ${INFO} $1"
}

log_success() {
    echo -e "  ${CHECKMARK} $1"
}

log_warning() {
    echo -e "  ${WARN} ${YELLOW}$1${RESET}"
    WARNINGS+=("$1")
}

log_error() {
    echo -e "  ${CROSSMARK} ${RED}$1${RESET}"
    ERRORS+=("$1")
}

log_step() {
    echo -e "  ${ARROW} $1"
}

spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}%s${RESET} %s" "${spin:i++%${#spin}:1}" "$message"
        sleep 0.1
    done
    printf "\r"
}

backup_file() {
    local file=$1
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -f "$file" ]]; then
        cp "$file" "$backup"
        log_info "Backed up: ${DIM}$(basename "$file")${RESET} → ${DIM}$(basename "$backup")${RESET}"
        return 0
    fi
    return 1
}

ensure_directory() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_info "Created directory: ${DIM}$dir${RESET}"
    fi
}

command_exists() {
    command -v "$1" &> /dev/null
}

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

check_dependencies() {
    section "Checking Dependencies"

    local deps=(git hyprctl pacman)
    local missing=()

    for dep in "${deps[@]}"; do
        if command_exists "$dep"; then
            log_success "$dep is available"
        else
            log_error "$dep is not installed"
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing[*]}"
        exit 1
    fi
}

clone_repository() {
    section "Cloning Repository"

    if [[ -d "$REPO_DIR" ]]; then
        log_info "Repository already exists at ${DIM}$REPO_DIR${RESET}"
        log_step "Pulling latest changes..."

        if git -C "$REPO_DIR" pull --quiet; then
            log_success "Repository updated successfully"
        else
            log_warning "Could not pull latest changes"
        fi
    else
        log_step "Cloning from ${DIM}$REPO_URL${RESET}"

        if git clone --quiet "$REPO_URL" "$REPO_DIR"; then
            log_success "Repository cloned to ${DIM}$REPO_DIR${RESET}"
        else
            log_error "Failed to clone repository"
            exit 1
        fi
    fi
}

install_waybar_config() {
    section "Installing Waybar Config"

    local waybar_dir="$HOME/.config/waybar"
    local config_src="$REPO_DIR/waybar/config.jsonc"
    local style_src="$REPO_DIR/waybar/style.css"
    local config_dest="$waybar_dir/config.jsonc"
    local style_dest="$waybar_dir/style.css"

    ensure_directory "$waybar_dir"

    # Backup existing files
    if [[ -f "$config_dest" ]]; then
        backup_file "$config_dest"
    fi

    if [[ -f "$style_dest" ]]; then
        backup_file "$style_dest"
    fi

    # Copy new config files
    if [[ -f "$config_src" ]]; then
        cp "$config_src" "$config_dest"
        log_success "Installed config.jsonc"
    else
        log_error "Source file not found: $config_src"
    fi

    if [[ -f "$style_src" ]]; then
        cp "$style_src" "$style_dest"
        log_success "Installed style.css"
    else
        log_error "Source file not found: $style_src"
    fi

    # Reload Hyprland
    log_step "Reloading Hyprland..."
    if hyprctl reload &> /dev/null; then
        log_success "Hyprland reloaded"
    else
        log_warning "Could not reload Hyprland"
    fi
}

install_kitty() {
    section "Installing Kitty Terminal"

    if command_exists kitty; then
        local version
        version=$(kitty --version 2>&1 | head -n1)
        log_success "Kitty is already installed (${DIM}$version${RESET})"
    else
        log_step "Installing kitty via pacman..."

        if sudo pacman -S kitty --noconfirm --quiet; then
            log_success "Kitty installed successfully"
        else
            log_error "Failed to install kitty"
            return 1
        fi
    fi

    # Install kitty config
    local kitty_dir="$HOME/.config/kitty"
    local config_src="$REPO_DIR/kitty/kitty.conf"
    local config_dest="$kitty_dir/kitty.conf"

    ensure_directory "$kitty_dir"

    if [[ -f "$config_dest" ]]; then
        backup_file "$config_dest"
    fi

    if [[ -f "$config_src" ]]; then
        cp "$config_src" "$config_dest"
        log_success "Installed kitty.conf"
    else
        log_error "Source file not found: $config_src"
    fi
}

set_default_terminal() {
    section "Setting Default Terminal"

    local terminal_file="$HOME/.config/uwsm/default"
    local find_line="export TERMINAL=alacritty"
    local replace_line="export TERMINAL=kitty"

    if [[ ! -f "$terminal_file" ]]; then
        log_error "File not found: $terminal_file"
        log_info "Cannot change default terminal"
        return 1
    fi

    # Check if already set to kitty
    if grep -q "$replace_line" "$terminal_file"; then
        log_success "Default terminal is already set to kitty"
        return 0
    fi

    # Check if the line to replace exists
    if ! grep -q "$find_line" "$terminal_file"; then
        log_warning "Could not find '$find_line' in $terminal_file"
        return 1
    fi

    backup_file "$terminal_file"

    log_step "Changing default terminal to kitty..."
    if sed -i "s|$find_line|$replace_line|" "$terminal_file"; then
        if grep -q "$replace_line" "$terminal_file"; then
            log_success "Default terminal changed to kitty"
        else
            log_error "Failed to change default terminal"
        fi
    else
        log_error "sed command failed"
    fi
}

print_summary() {
    echo
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}${WHITE}Summary${RESET}"
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    if [[ ${#ERRORS[@]} -eq 0 && ${#WARNINGS[@]} -eq 0 ]]; then
        echo -e "  ${CHECKMARK} ${GREEN}All tasks completed successfully!${RESET}"
    else
        if [[ ${#WARNINGS[@]} -gt 0 ]]; then
            echo -e "  ${WARN} ${YELLOW}Warnings: ${#WARNINGS[@]}${RESET}"
            for warning in "${WARNINGS[@]}"; do
                echo -e "    ${DIM}• $warning${RESET}"
            done
        fi

        if [[ ${#ERRORS[@]} -gt 0 ]]; then
            echo -e "  ${CROSSMARK} ${RED}Errors: ${#ERRORS[@]}${RESET}"
            for error in "${ERRORS[@]}"; do
                echo -e "    ${DIM}• $error${RESET}"
            done
        fi
    fi

    echo
    echo -e "${DIM}Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo
}

show_help() {
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo
    echo -e "${BOLD}Description:${RESET}"
    echo "  This script sets up the Omarchy configuration including:"
    echo "  • Cloning the config repository"
    echo "  • Installing Waybar configuration"
    echo "  • Installing Kitty terminal and its config"
    echo "  • Setting Kitty as the default terminal"
    echo
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "$SCRIPT_NAME v$SCRIPT_VERSION"
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${RESET}"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    clear
    print_banner

    check_dependencies
    clone_repository
    install_waybar_config
    install_kitty
    set_default_terminal

    print_summary
}

main "$@"
