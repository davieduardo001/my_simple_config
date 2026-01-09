#!/bin/bash
#
# This script installs the Kitty terminal emulator.
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

# --- Kitty Installation ---
install_kitty() {
    info "Starting Kitty installation..."

    if command -v kitty &> /dev/null; then
        info "Kitty is already installed. Skipping installation."
        return
    fi

    action_required "Using dnf for installation."
    sudo dnf install -y kitty || error "Failed to install Kitty with dnf."
    
    info "Kitty installed successfully."
}

# --- Main Execution ---
install_kitty
