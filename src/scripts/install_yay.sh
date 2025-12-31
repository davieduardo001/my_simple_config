#!/bin/bash
#
# This script installs yay, an AUR helper for Arch Linux.
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

# --- yay Installation ---
install_yay() {
    info "Starting yay installation..."

    if command -v yay &> /dev/null; then
        info "yay is already installed. Skipping installation."
        return
    fi

    action_required "yay is not installed. Installing..."

    # Install dependencies
    info "Installing dependencies: git and base-devel..."
    sudo pacman -S --needed --noconfirm git base-devel

    # Clone yay repository
    info "Cloning yay repository from AUR..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay

    # Build and install yay
    info "Building and installing yay..."
    (cd /tmp/yay && makepkg -si --noconfirm)

    # Clean up
    info "Cleaning up..."
    rm -rf /tmp/yay

    # Final check
    if command -v yay &> /dev/null; then
        info "yay installed successfully. ✅"
    else
        error "Failed to install yay. Please try installing it manually."
    fi
}

# --- Main Execution ---
install_yay
