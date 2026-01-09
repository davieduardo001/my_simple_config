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
    else
        action_required "Using dnf for installation."
        sudo dnf install -y neovim || error "Failed to install Neovim with dnf."
        info "Neovim installed successfully."
    fi

    action_required "Installing additional dependencies for Neovim..."
    sudo dnf install -y tree-sitter-cli gcc curl fzf ripgrep fd-find || error "Failed to install additional dependencies."

    action_required "Do you want to install lazygit (optional)?"
    read -p "Enter [y/N] to confirm: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Installing lazygit..."
        sudo dnf copr enable atim/lazygit -y
        sudo dnf install lazygit -y || error "Failed to install lazygit."
    fi

    info "Neovim and its dependencies are all set."
}

# --- Main Execution ---
install_neovim "$1"
