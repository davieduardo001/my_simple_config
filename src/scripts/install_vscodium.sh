#!/bin/bash
#
# This script installs VSCodium, a community-driven, freely-licensed binary
# distribution of VS Code.
#
set -e

# Function to print informational messages
info() {
    echo "[INFO] $1"
}

# --- VSCodium Installation ---
info "Starting VSCodium installation..."

if command -v codium &> /dev/null; then
    info "VSCodium is already installed. Skipping installation."
    exit 0
fi

PACKAGE="VSCodium"
URL="https://github.com/VSCodium/vscodium/releases/download/1.106.37943/codium_1.106.37943_amd64.deb"
FILE="/tmp/VSCodium.deb"

# Clean up the temporary file on exit
trap 'rm -f "$FILE"' EXIT

info "$PACKAGE is not installed. Downloading..."

# Download deb file
if curl -L -o "$FILE" "$URL"; then
    info "Download complete. Installing VSCodium..."
    sudo apt install -y "$FILE"
    info "$PACKAGE has been installed successfully."
else
    echo "[ERROR] Failed to download VSCodium. Please check the URL and your internet connection."
    exit 1
fi
