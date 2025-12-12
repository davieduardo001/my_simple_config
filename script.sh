#!/bin/bash
#
# This script automates the setup of a developer environment by installing and
# configuring various tools and applications. It is designed to be idempotent,
# meaning it can be run multiple times without causing issues.
#
set -e

# Get the directory of the script
CONFIGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print informational messages
info() {
    echo "[INFO] $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# --- Font Installation ---
info "Installing fonts..."
for font_script in "$CONFIGDIR/src/scripts/install_fonts_blex.sh" "$CONFIGDIR/src/scripts/install_fonts_fira.sh" "$CONFIGDIR/src/scripts/install_fonts_caskaydia.sh"; do
    if [ -f "$font_script" ]; then
        info "Running $font_script..."
        chmod +x "$font_script"
        "$font_script"
    else
        info "Font script $font_script not found, skipping."
    fi
done
info "Fonts installation complete."

# --- Kitty Terminal Installation and Configuration ---
info "Setting up Kitty terminal..."
if command_exists kitty; then
    info "Kitty is already installed."
else
    info "Installing Kitty..."
    sudo apt update
    sudo apt install -y kitty
fi

info "Configuring Kitty..."
KITTY_CONFIG_DIR="$HOME/.config/kitty"
KITTY_CONFIG_FILE="$KITTY_CONFIG_DIR/kitty.conf"
mkdir -p "$KITTY_CONFIG_DIR"
if [ -f "$KITTY_CONFIG_FILE" ]; then
    info "Backing up existing Kitty configuration to $KITTY_CONFIG_FILE.backup"
    mv "$KITTY_CONFIG_FILE" "$KITTY_CONFIG_FILE.backup"
fi
info "Applying new Kitty configuration."
cp "$CONFIGDIR/src/config/kitty_config" "$KITTY_CONFIG_FILE"
info "Kitty setup complete."

# --- VSCodium Installation ---
info "Setting up VSCodium..."
VSCODIUM_INSTALL_SCRIPT="$CONFIGDIR/src/scripts/install_vscodium.sh"
if [ -f "$VSCODIUM_INSTALL_SCRIPT" ]; then
    chmod +x "$VSCODIUM_INSTALL_SCRIPT"
    "$VSCODIUM_INSTALL_SCRIPT"
else
    info "VSCodium install script not found, skipping."
fi
info "VSCodium setup complete."

# --- Zsh and Oh My Zsh Installation and Configuration ---
info "Setting up Zsh and Oh My Zsh..."
if command_exists zsh; then
    info "Zsh is already installed."
else
    info "Installing Zsh..."
    sudo apt update
    sudo apt install -y zsh
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    info "Oh My Zsh is already installed."
else
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

info "Configuring Zsh..."
ZSHRC_FILE="$HOME/.zshrc"
if [ -f "$ZSHRC_FILE" ]; then
    info "Backing up existing .zshrc to $ZSHRC_FILE.backup"
    mv "$ZSHRC_FILE" "$ZSHRC_FILE.backup"
fi
info "Applying new Zsh configuration."
cp "$CONFIGDIR/src/config/zshrc" "$ZSHRC_FILE"
info "Zsh setup complete."

# --- NVM, Node.js, and Gemini CLI Installation ---
info "Setting up NVM, Node.js, and Gemini CLI..."
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    info "NVM is already installed."
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
else
    info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
fi

if command_exists node && command_exists npm; then
    info "Node.js and npm are already installed."
else
    info "Installing Node.js (v24.12.0)..."
    nvm install v24.12.0
fi

if command_exists gemini; then
    info "Gemini CLI is already installed."
else
    info "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
fi
info "NVM, Node.js, and Gemini CLI setup complete."

info "All installations and configurations are complete!"