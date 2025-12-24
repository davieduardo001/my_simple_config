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


# Run installation scripts
"$SCRIPTS_SUBDIR/install_zsh.sh"
"$SCRIPTS_SUBDIR/install_kitty.sh"
"$SCRIPTS_SUBDIR/install_vscodium.sh"
"$SCRIPTS_SUBDIR/install_fonts_blex.sh"
"$SCRIPTS_SUBDIR/install_fonts_caskaydia.sh"
"$SCRIPTS_SUBDIR/install_fonts_fira.sh"

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

# --- Final Steps ---
# Set Zsh as default shell if the user wants
set_default_shell


info "Environment setup complete! ✅"
warn "Please restart your terminal or source your shell profile for all changes to take effect. 🔄"
action_required "Please close and reopen your terminal window, or log out and log back in. 👇"