#!/bin/bash

PACKAGE="VSCodium"
# FONT_DIR="$HOME/.local/share/fonts"
URL="https://github.com/VSCodium/vscodium/releases/download/1.106.37943/codium_1.106.37943_amd64.deb"
FILE="/tmp/VSCodium.deb"

# Check if font already exists
if [ "$(command -v codium)" ]; then
    echo "command \"VSCodium\" exists on system"
    exit 0
fi

echo "$PACKAGE is not installed. Downloading..."

# Download font zip
curl -L -o "$FILE" "$URL"
sudo apt install FILE

echo "$PACKAGE has been installed successfully."
