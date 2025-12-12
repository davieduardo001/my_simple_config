#!/bin/bash
#
# This script installs VSCodium, a community-driven, freely-licensed binary
# distribution of VS Code.
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

action_required "$PACKAGE is not installed. Downloading..."

# Download deb file
if curl -L -o "$FILE" "$URL"; then
    info "Download complete. Installing VSCodium..."
    sudo apt install -y "$FILE" || error "Failed to install VSCodium."
    info "$PACKAGE has been installed successfully."
else
    error "Failed to download VSCodium. Please check the URL and your internet connection."
fi
