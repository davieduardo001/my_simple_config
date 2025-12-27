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


# --- Main Setup ---
info "Starting environment setup..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_SUBDIR="$SCRIPT_DIR/src/scripts"

# Make all installation scripts executable before running them
info "Setting execute permissions for installation scripts..."
for script in "$SCRIPTS_SUBDIR"/*.sh; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        info "Made $script executable."
    fi
done

# --- Oh My Zsh Installation ---
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        info "Oh My Zsh is already installed. Skipping."
    else
        action_required "Oh My Zsh is not installed. Installing..."
        # Using the --unattended flag to prevent the installer from trying to change the shell
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# --- Set Default Shell ---
set_default_shell() {
    if ! command -v zsh &> /dev/null; then
        warn "Zsh is not installed. Cannot set it as default."
        return
    fi

    local zsh_path
    zsh_path=$(which zsh)
    local current_shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)

    if [ "$current_shell" == "$zsh_path" ]; then
        info "Zsh is already the default shell. Nothing to do. ✅"
        return
    fi

    action_required "Do you want to make Zsh your default shell?"
    # Ask the user for confirmation
    read -p "Enter [y/N] to confirm: " -n 1 -r
    echo # Move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Changing default shell to Zsh..."
        if chsh -s "$zsh_path"; then
            info "Default shell changed to Zsh successfully."
            warn "You will need to log out and log back in for the change to take full effect."
        else
            error "Failed to change the default shell. Please try running 'chsh -s $zsh_path' manually."
        fi
    else
        warn "Skipping default shell change."
    fi
}

# --- NVM & Node Installation ---
install_nvm_node() {
    export NVM_DIR="$HOME/.nvm"
    
    # 1. Install NVM if not present
    if [ -d "$NVM_DIR" ]; then
        info "NVM is already installed. Skipping download."
    else
        action_required "NVM is not installed. Installing..."
        # Install latest stable nvm
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi

    # 2. Load NVM into the current script session
    # This is required because nvm is a function, not a binary, and isn't available
    # immediately after install without sourcing.
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh" 
    else
        error "NVM script not found at $NVM_DIR/nvm.sh"
    fi

    # 3. Install Node LTS
    info "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*' # Ensure this version sticks as default for new shells

    info "Node.js $(node -v) and npm $(npm -v) installed successfully. ✅"
}

install_nvm_node

# --- Gemini CLI Installation ---
install_gemini_cli() {
    info "Checking for Google Gemini CLI..."

    # Ensure npm is accessible (redundant check, but safe)
    if ! command -v npm &> /dev/null; then
        # Attempt to load nvm one more time if npm is missing
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    if ! command -v npm &> /dev/null; then
        error "npm is not accessible. Cannot install Gemini CLI."
    fi

    # Check if the package is already installed globally
    if npm list -g @google/gemini-cli --depth=0 > /dev/null 2>&1; then
        info "Gemini CLI is already installed. Skipping."
    else
        action_required "Installing Google Gemini CLI..."
        if npm install -g @google/gemini-cli; then
            info "Gemini CLI installed successfully. ✅"
        else
            error "Failed to install Gemini CLI."
        fi
    fi
}

install_gemini_cli

# Run installation scripts
"$SCRIPTS_SUBDIR/install_zsh.sh"
"$SCRIPTS_SUBDIR/install_kitty.sh"
"$SCRIPTS_SUBDIR/install_alacritty.sh"
"$SCRIPTS_SUBDIR/install_vscodium.sh"
"$SCRIPTS_SUBDIR/install_fonts_blex.sh"
"$SCRIPTS_SUBDIR/install_fonts_caskaydia.sh"
"$SCRIPTS_SUBDIR/install_fonts_fira.sh"
"$SCRIPTS_SUBDIR/install_fastfetch.sh"

# Install Oh My Zsh after Zsh binary is installed
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
else
    warn "Kitty not found. Skipping Kitty config deployment."
fi

# Deploy alacritty_config
if command -v alacritty &> /dev/null; then
    ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
    ALACRITTY_CONFIG_SOURCE="$SCRIPT_DIR/src/config/alacritty.toml"
    ALACRITTY_CONFIG_DEST="$ALACRITTY_CONFIG_DIR/alacritty.toml"

    mkdir -p "$ALACRITTY_CONFIG_DIR"
    ln -sf "$ALACRITTY_CONFIG_SOURCE" "$ALACRITTY_CONFIG_DEST"
    info "Alacritty config deployed."
else
    warn "Alacritty not found. Skipping Alacritty config deployment."
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
else
    warn "Zsh not found. Skipping .zshrc deployment."
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
else
    warn "VSCodium not found. Skipping VSCodium profile deployment."
fi

# Deploy fastfetch config
if command -v fastfetch &> /dev/null; then
    FASTFETCH_CONFIG_DIR="$HOME/.config/fastfetch"

    FASTFETCH_CONFIG_SOURCE="$SCRIPT_DIR/src/config/fastfetch.jsonc"
    ASCII_SOURCE="$SCRIPT_DIR/src/config/ascii"
    PNG_SOURCE="$SCRIPT_DIR/src/config/png"

    ASCII_DEST="$FASTFETCH_CONFIG_DIR/ascii"
    PNG_DEST="$FASTFETCH_CONFIG_DIR/png"
    
    ln -sf "$FASTFETCH_CONFIG_SOURCE" "$FASTFETCH_CONFIG_DEST"
    info "Fastfetch config.jsonc deployed."

    cp -f "$ASCII_SOURCE" "$ASCII_DEST"
    cp -f "$PNG_SOURCE" "$PNG_DEST"
    info "Fastfetch ascii art deployed."
else
    warn "Fastfetch not found. Skipping Fastfetch config deployment."
fi

# --- Final Steps ---
# Set Zsh as default shell if the user wants
set_default_shell


info "Environment setup complete! ✅"
warn "Please restart your terminal or source your shell profile for all changes to take effect. 🔄"
action_required "Please close and reopen your terminal window, or log out and log back in. 👇"