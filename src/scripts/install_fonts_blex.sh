#!/bin/bash
#
# This script installs the BlexMono Nerd Font.
#
set -e

# Define colors
if [[ -t 1 ]]; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
else
    RED=""
    GREEN=""
    YELLOW=""
    CYAN=""
    RESET=""
fi

# Function to print informational messages
info() {
    echo "✨ ${GREEN}[INFO]${RESET} $1"
}

# Function to print warning messages
warn() {
    echo "⚠️  ${YELLOW}[WARN]${RESET} $1"
}

# Function to print error messages
error() {
    echo "❌ ${RED}[ERROR]${RESET} $1" >&2
    exit 1
}

# Function to print action required messages
action_required() {
    echo "🚀 ${CYAN}[ACTION]${RESET} $1"
}

# --- BlexMono Nerd Font Installation ---
install_blex_font() {
    info "Starting BlexMono Nerd Font installation..."

    FONT_NAME="BlexMono Nerd Font"
    FONT_DIR="$HOME/.local/share/fonts"
    ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/IBMPlexMono.zip"
    ZIP_FILE="/tmp/BlexMono.zip"

    # Clean up the temporary file on exit
    trap 'rm -f "$ZIP_FILE"' EXIT

    if fc-list | grep -i "BlexMono Nerd Font" >/dev/null 2>&1; then
        info "$FONT_NAME is already installed. Skipping installation."
        return
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
}

# --- Main Execution ---
install_blex_font

# Make the script executable
chmod +x "$0"