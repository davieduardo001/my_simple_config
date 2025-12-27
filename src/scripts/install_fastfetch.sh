#!/bin/bash
#
# This script handles the installation and configuration of fastfetch.
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

# --- Helper Functions ---
info() { echo "✨ ${GREEN}[INFO]${RESET} $1"; }
warn() { echo "⚠️  ${YELLOW}[WARN]${RESET} $1"; }
error() { echo "❌ ${RED}[ERROR]${RESET} $1" >&2; exit 1; }
action_required() { echo "🚀 ${CYAN}[ACTION]${RESET} $1"; }

# --- Installation ---
info "Checking for fastfetch..."

if command -v fastfetch &> /dev/null; then
    info "fastfetch is already installed."
else
    action_required "fastfetch not found. Attempting to install..."

    # --- Installation logic ---
    if command -v apt-get &> /dev/null; then
        info "Detected Debian/Ubuntu-based system. Installing via apt."
        sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
        sudo apt-get update
        sudo apt-get install -y fastfetch
    elif command -v pacman &> /dev/null; then
        info "Detected Arch-based system. Installing via pacman."
        sudo pacman -S --noconfirm fastfetch
    elif command -v dnf &> /dev/null; then
        info "Detected Fedora/CentOS-based system. Installing via dnf."
        sudo dnf install -y fastfetch
    elif command -v brew &> /dev/null; then
        info "Detected Homebrew. Installing via brew."
        brew install fastfetch
    else
        error "No common package manager (apt, pacman, dnf, brew) found. Please install fastfetch manually."
    fi

    # Final check
    if command -v fastfetch &> /dev/null; then
        info "fastfetch installed successfully. ✅"
    else
        error "Failed to install fastfetch. Please try installing it manually."
    fi
fi

# --- Configuration ---
info "Setting up fastfetch configuration..."

# --- Config paths ---
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
DOTFILES_ROOT=$(dirname "$(dirname "$SCRIPT_DIR")")
CONFIG_SRC_DIR="$DOTFILES_ROOT/src/config"
CONFIG_DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"

info "Source directory: $CONFIG_SRC_DIR"
info "Destination directory: $CONFIG_DEST_DIR"

# Create destination directories
action_required "Creating fastfetch configuration directories..."
mkdir -p "$CONFIG_DEST_DIR/png"
mkdir -p "$CONFIG_DEST_DIR/ascii"
info "Directories created."

# Symlink configuration files
action_required "Symlinking configuration files..."

# config.jsonc
if [ -f "$CONFIG_SRC_DIR/fastfetch.jsonc" ]; then
    ln -sf "$CONFIG_SRC_DIR/fastfetch.jsonc" "$CONFIG_DEST_DIR/config.jsonc"
    info "Symlinked fastfetch.jsonc to $CONFIG_DEST_DIR/config.jsonc"
else
    warn "fastfetch.jsonc not found in $CONFIG_SRC_DIR. Skipping."
fi

# ascii art
if [ -d "$CONFIG_SRC_DIR/ascii" ]; then
    for file in "$CONFIG_SRC_DIR/ascii"/*; do
        if [ -f "$file" ]; then
            ln -sf "$file" "$CONFIG_DEST_DIR/ascii/$(basename "$file")"
            info "Symlinked $(basename "$file") to $CONFIG_DEST_DIR/ascii/"
        fi
    done
else
    warn "ascii directory not found in $CONFIG_SRC_DIR. Skipping."
fi

# png images
if [ -d "$CONFIG_SRC_DIR/png" ]; then
    for file in "$CONFIG_SRC_DIR/png"/*; do
        if [ -f "$file" ]; then
            ln -sf "$file" "$CONFIG_DEST_DIR/png/$(basename "$file")"
            info "Symlinked $(basename "$file") to $CONFIG_DEST_DIR/png/"
        fi
    done
else
    warn "png directory not found in $CONFIG_SRC_DIR. Skipping."
fi

info "Fastfetch configuration setup complete. ✅"
action_required "Run 'fastfetch' to see your new config in action."
