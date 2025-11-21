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



