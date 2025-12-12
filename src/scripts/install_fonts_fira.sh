#!/bin/bash
#
# This script installs the FiraCode Nerd Font.
#
set -e

# Define colors
if [[ -t 1 ]]; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    MAGENTA=""
    CYAN=""
    RESET=""
fi

# Function to print informational messages
info() {
    echo "${GREEN}[INFO]${RESET} $1"
}

# Function to print warning messages
warn() {
    echo "${YELLOW}[WARN]${RESET} $1"
}

# Function to print error messages
error() {
    echo "${RED}[ERROR]${RESET} $1" >&2
    exit 1
}

# Function to print action required messages
action_required() {
    echo "${CYAN}[ACTION]${RESET} $1"
}

# --- FiraCode Nerd Font Installation ---
info "Starting FiraCode Nerd Font installation..."

FONT_NAME="FiraCode Nerd Font"
FONT_DIR="$HOME/.local/share/fonts"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
ZIP_FILE="/tmp/FiraCode.zip"

# Clean up the temporary file on exit
trap 'rm -f "$ZIP_FILE"' EXIT

if fc-list | grep -i "FiraCode Nerd Font" >/dev/null 2>&1; then
    info "$FONT_NAME is already installed. Skipping installation."
    exit 0
fi

action_required "$FONT_NAME is not installed. Downloading..."

if curl -L -o "$ZIP_FILE" "$ZIP_URL"; then
    info "Download complete. Installing font..."
    mkdir -p "$FONT_DIR" || error "Failed to create font directory."
    unzip -o "$ZIP_FILE" -d "$FONT_DIR" || error "Failed to unzip font."
    fc-cache -fv "$FONT_DIR" || error "Failed to refresh font cache."
    info "$FONT_NAME has been installed successfully."
else
    error "Failed to download $FONT_NAME. Please check the URL and your internet connection."
fi
