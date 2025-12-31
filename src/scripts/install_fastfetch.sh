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
install_fastfetch() {
    info "Checking for fastfetch..."

    if command -v fastfetch &> /dev/null; then
        info "fastfetch is already installed."
        return
    fi

    action_required "fastfetch not found. Attempting to install..."

    if [ "$1" == "--use-yay" ] && command -v yay &> /dev/null; then
        info "Using yay for installation."
        yay -S --noconfirm fastfetch
    else
        info "Using pacman for installation."
        sudo pacman -S --noconfirm fastfetch
    fi

    # Final check
    if command -v fastfetch &> /dev/null; then
        info "fastfetch installed successfully. ✅"
    else
        error "Failed to install fastfetch. Please try installing it manually."
    fi
}

# --- Configuration ---
configure_fastfetch() {
    info "Setting up fastfetch configuration..."

    # --- Config paths ---
    SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
    DOTFILES_ROOT=$(dirname "$(dirname "$SCRIPT_DIR")")
    CONFIG_SRC_DIR="$DOTFILES_ROOT/src/config/fastfetch"
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
}

# --- Main Execution ---
install_fastfetch "$1"
configure_fastfetch
