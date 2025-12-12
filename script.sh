#!/bin/bash
#
# This script automates the setup of a developer environment by installing and
# configuring various tools and applications. It is designed to be idempotent,
# meaning it can be run multiple times without causing issues.
#
set -e

# Get the directory of the script
CONFIGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define colors
if [[ -t 1 ]]; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    MAGENTA=""
    CYAN=""
    RESET=""
fi

# Function to print informational messages
info() {
    echo "${GREEN}[INFO]${RESET} $1"
}

# Function to print warning messages
warn() {
    echo "${YELLOW}[WARN]${RESET} $1"
}

# Function to print error messages
error() {
    echo "${RED}[ERROR]${RESET} $1" >&2
}

# Function to print action required messages
action_required() {
    echo "${CYAN}[ACTION]${RESET} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# --- Font Installation ---
info "Installing fonts..."
for font_script in "$CONFIGDIR/src/scripts/install_fonts_blex.sh" "$CONFIGDIR/src/scripts/install_fonts_fira.sh" "$CONFIGDIR/src/scripts/install_fonts_caskaydia.sh"; do
    if [ -f "$font_script" ]; then
        action_required "Running $font_script..."
        chmod +x "$font_script"
        "$font_script"
    else
        warn "Font script $font_script not found, skipping."
    fi
done
info "Fonts installation complete."

# --- Kitty Terminal Installation and Configuration ---
info "Setting up Kitty terminal..."
if command_exists kitty; then
    info "Kitty is already installed."
else
    action_required "Installing Kitty..."
    sudo apt update || error "Failed to update apt packages."
    sudo apt install -y kitty || error "Failed to install Kitty."
fi

info "Configuring Kitty..."
KITTY_CONFIG_DIR="$HOME/.config/kitty"
KITTY_CONFIG_FILE="$KITTY_CONFIG_DIR/kitty.conf"
mkdir -p "$KITTY_CONFIG_DIR" || error "Failed to create Kitty config directory."
if [ -f "$KITTY_CONFIG_FILE" ]; then
    warn "Backing up existing Kitty configuration to $KITTY_CONFIG_FILE.backup"
    mv "$KITTY_CONFIG_FILE" "$KITTY_CONFIG_FILE.backup" || error "Failed to backup Kitty config."
fi
info "Applying new Kitty configuration."
cp "$CONFIGDIR/src/config/kitty_config" "$KITTY_CONFIG_FILE" || error "Failed to copy Kitty config."
info "Kitty setup complete."

# --- VSCodium Installation ---
info "Setting up VSCodium..."
VSCODIUM_INSTALL_SCRIPT="$CONFIGDIR/src/scripts/install_vscodium.sh"
if [ -f "$VSCODIUM_INSTALL_SCRIPT" ]; then
    action_required "Running VSCodium install script..."
    chmod +x "$VSCODIUM_INSTALL_SCRIPT" || error "Failed to make VSCodium install script executable."
    "$VSCODIUM_INSTALL_SCRIPT"
else
    warn "VSCodium install script not found, skipping."
fi
info "VSCodium setup complete."

# --- Zsh and Oh My Zsh Installation and Configuration ---
info "Setting up Zsh and Oh My Zsh..."
if command_exists zsh; then
    info "Zsh is already installed."
else
    action_required "Installing Zsh..."
    sudo apt update || error "Failed to update apt packages."
    sudo apt install -y zsh || error "Failed to install Zsh."
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    info "Oh My Zsh is already installed."
else
    action_required "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || error "Failed to install Oh My Zsh."
fi

info "Configuring Zsh..."
ZSHRC_FILE="$HOME/.zshrc"
if [ -f "$ZSHRC_FILE" ]; then
    warn "Backing up existing .zshrc to $ZSHRC_FILE.backup"
    mv "$ZSHRC_FILE" "$ZSHRC_FILE.backup" || error "Failed to backup .zshrc."
fi
info "Applying new Zsh configuration."
cp "$CONFIGDIR/src/config/zshrc" "$ZSHRC_FILE" || error "Failed to copy zshrc."
info "Zsh setup complete."

# --- NVM, Node.js, and Gemini CLI Installation ---
info "Setting up NVM, Node.js, and Gemini CLI..."
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    info "NVM is already installed."
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
else
    action_required "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash || error "Failed to install NVM."
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
fi

if command_exists node && command_exists npm; then
    info "Node.js and npm are already installed."
else
    action_required "Installing Node.js (v24.12.0)..."
    nvm install v24.12.0 || error "Failed to install Node.js."
fi

if command_exists gemini; then
    info "Gemini CLI is already installed."
else
    action_required "Installing Gemini CLI..."
    npm install -g @google/gemini-cli || error "Failed to install Gemini CLI."
fi
info "NVM, Node.js, and Gemini CLI setup complete."

info "All installations and configurations are complete!"