#!/bin/bash
#
# This script is the main entry point for setting up the environment.
#
set -e

# Define colors
if [[ -t 1 ]]; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RESET=$(tput sgr0)
else
    RED=""
    GREEN=""
    YELLOW=""
    RESET=""
fi

# --- Helper Functions ---
info() { echo "${GREEN}[INFO]${RESET} $1"; }
warn() { echo "${YELLOW}[WARN]RESET} $1"; }

# --- Oh My Zsh Installation ---
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        info "Oh My Zsh is already installed. Skipping."
    else
        info "Installing Oh My Zsh..."
        /bin/bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}


# --- Main Setup ---
info "Starting environment setup..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Run installation scripts
"$SCRIPT_DIR/src/scripts/install_zsh.sh"
"$SCRIPT_DIR/src/scripts/install_kitty.sh"
"$SCRIPT_DIR/src/scripts/install_vscodium.sh"
"$SCRIPT_DIR/src/scripts/install_fonts_blex.sh"
"$SCRIPT_DIR/src/scripts/install_fonts_caskaydia.sh"
"$SCRIPT_DIR/src/scripts/install_fonts_fira.sh"

# Install Oh My Zsh
install_oh_my_zsh

# --- Configuration File Deployment ---
info "Deploying configuration files..."

# Deploy kitty_config
if command -v kitty &> /dev/null; then
    KITTY_CONFIG_DIR="$HOME/.config/kitty"
    KITTY_CONFIG_SOURCE="$SCRIPT_DIR/src/config/kitty_config"
    KITTY_CONFIG_DEST="$KITTY_CONFIG_DIR/kitty.conf"

    mkdir -p "$KITTY_CONFIG_DIR"
    ln -sf "$KITTY_CONFIG_SOURCE" "$KITTY_CONFIG_DEST"
    info "Kitty config deployed."
fi

# Deploy zshrc
if command -v zsh &> /dev/null; then
    ZSHRC_SOURCE="$SCRIPT_DIR/src/config/zshrc"
    ZSHRC_DEST="$HOME/.zshrc"
    
    # Backup original zshrc if it exists and is not a symlink
    if [ -f "$ZSHRC_DEST" ] && [ ! -L "$ZSHRC_DEST" ]; then
        mv "$ZSHRC_DEST" "$ZSHRC_DEST.bak"
        info "Backed up existing .zshrc to .zshrc.bak"
    fi
    
    ln -sf "$ZSHRC_SOURCE" "$ZSHRC_DEST"
    info ".zshrc deployed."
fi

# Deploy VS Codium Profile
if command -v codium &> /dev/null; then
    VSCODIUM_PROFILE_SOURCE="$SCRIPT_DIR/src/config/my_vscod_profile.code-profile"
    VSCODIUM_PROFILE_DIR="$HOME/.config/VSCodium/User/profiles"
    VSCODIUM_PROFILE_DEST="$VSCODIUM_PROFILE_DIR/my_vscod_profile.code-profile"

    if [[ -f "$VSCODIUM_PROFILE_SOURCE" ]]; then
        mkdir -p "$VSCODIUM_PROFILE_DIR"
        cp "$VSCODIUM_PROFILE_SOURCE" "$VSCODIUM_PROFILE_DEST"
        info "VSCodium profile deployed."
    fi
fi

info "Environment setup complete."
warn "Please restart your terminal or source your shell profile for all changes to take effect."
warn "To make Zsh your default shell, you may need to run: chsh -s \$(which zsh)"