#!/bin/bash
#
# This script installs the FiraCode Nerd Font.
#
set -e

# Function to print informational messages
info() {
    echo "[INFO] $1"
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

info "$FONT_NAME is not installed. Downloading..."

if curl -L -o "$ZIP_FILE" "$ZIP_URL"; then
    info "Download complete. Installing font..."
    mkdir -p "$FONT_DIR"
    unzip -o "$ZIP_FILE" -d "$FONT_DIR"
    fc-cache -fv "$FONT_DIR"
    info "$FONT_NAME has been installed successfully."
else
    echo "[ERROR] Failed to download $FONT_NAME. Please check the URL and your internet connection."
    exit 1
fi
