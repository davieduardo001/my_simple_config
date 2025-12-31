#!/bin/bash
#
# This script installs Neovim, a hyperextensible Vim-based text editor,
# on various Linux distributions.
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

# --- Neovim Installation ---
install_neovim() {
    info "Starting Neovim installation..."

    if command -v nvim &> /dev/null; then
        info "Neovim is already installed. Skipping installation."
        return
    fi

    if [ "$1" == "--use-yay" ] && command -v yay &> /dev/null; then
        action_required "Using yay for installation."
        yay -S --noconfirm neovim || error "Failed to install Neovim with yay."
    else
        action_required "Using Pacman for installation."
        sudo pacman -S --noconfirm neovim || error "Failed to install Neovim with Pacman."
    fi
    info "Neovim installed successfully."
}

# --- Main Execution ---
install_neovim "$1"

# Make the script executable
chmod +x "$0"
