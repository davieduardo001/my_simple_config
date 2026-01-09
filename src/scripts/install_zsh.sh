#!/bin/bash
#
# This script installs the Zsh shell on various Linux distributions.
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

# --- Zsh Installation ---
install_zsh() {
    info "Starting Zsh installation..."

    if command -v zsh &> /dev/null; then
        info "Zsh is already installed. Skipping installation."
        return
    fi

    if [ "$1" == "--use-yay" ] && command -v yay &> /dev/null; then
        action_required "Using yay for installation."
        yay -S --noconfirm zsh || error "Failed to install Zsh with yay."
    else
        action_required "Using Pacman for installation."
        sudo pacman -S --noconfirm zsh || error "Failed to install Zsh with pacman."
    fi
    info "Zsh installed successfully."
    warn "To make Zsh your default shell, run: chsh -s \$(which zsh)"
}

# --- Main Execution ---
install_zsh "$1"

# Make the script executable
chmod +x "$0"