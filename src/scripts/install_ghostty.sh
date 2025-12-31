#!/bin/bash
#
# This script installs Ghostty, a modern terminal emulator.
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

# --- Ghostty Installation ---
install_ghostty() {
    info "Starting Ghostty installation..."

    if command -v ghostty &> /dev/null; then
        info "Ghostty is already installed. Skipping installation."
        return
    fi

    action_required "Ghostty is not installed. Installing..."

    if [ "$1" == "--use-yay" ] && command -v yay &> /dev/null; then
        action_required "Using yay for installation on Arch Linux."
        yay -S --noconfirm ghostty
    else
        action_required "Using pacman for installation on Arch Linux."
        sudo pacman -S --noconfirm ghostty
    fi

    # Final check
    if command -v ghostty &> /dev/null; then
        info "Ghostty installed successfully. ✅"
    else
        error "Failed to install Ghostty. Please try installing it manually."
    fi
}

# --- Main Execution ---
install_ghostty "$1"
