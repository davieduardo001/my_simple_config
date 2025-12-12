#!/bin/bash
#
# This script installs the CaskaydiaCove Nerd Font.
#
set -e

# Function to print informational messages
info() {
    echo "[INFO] $1"
}

# --- CaskaydiaCove Nerd Font Installation ---
info "Starting CaskaydiaCove Nerd Font installation..."

FONT_NAME="CaskaydiaCove Nerd Font"
FONT_DIR="$HOME/.local/share/fonts"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip"
ZIP_FILE="/tmp/CaskaydiaCove.zip"

# Clean up the temporary file on exit
trap 'rm -f "$ZIP_FILE"' EXIT

if fc-list | grep -i "CaskaydiaCove Nerd Font" >/dev/null 2>&1; then
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
