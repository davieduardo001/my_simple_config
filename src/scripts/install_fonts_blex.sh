#!/bin/bash
set -e

# BLEXMONO 
FONT_NAME="BlexMono Nerd Font"
FONT_DIR="$HOME/.local/share/fonts"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/IBMPlexMono.zip"
ZIP_FILE="/tmp/BlexMono.zip"

# Clean up the temporary file on exit
trap 'rm -f "$ZIP_FILE"' EXIT

# Check if font already exists
if fc-list | grep -i "BlexMono Nerd Font" >/dev/null 2>&1; then
  echo "$FONT_NAME is already installed."
  exit 0
fi

echo "$FONT_NAME is not installed. Downloading..."

# Download font zip
curl -L -o "$ZIP_FILE" "$ZIP_URL"

# Create font directory if it doesn't exist
mkdir -p "$FONT_DIR"

# Unzip to the fonts directory
unzip -o "$ZIP_FILE" -d "$FONT_DIR"

# Refresh font cache
fc-cache -fv "$FONT_DIR"

echo "$FONT_NAME has been installed successfully."
