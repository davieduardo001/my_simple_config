#!/bin/bash
set -e

# Get the directory of the script
CONFIGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install the fonts
for font_script in "$CONFIGDIR/src/scripts/install_fonts_blex.sh" "$CONFIGDIR/src/scripts/install_fonts_fira.sh" "$CONFIGDIR/src/scripts/install_fonts_caskaydia.sh"; do
    chmod +x "$font_script"
    "$font_script"
done

################################################
# install kitty
echo '-> Verify if Kitty exists'
if [ "$(command -v kitty)" ]; then
    echo "Package \"Kitty\" exists on system"
else
    # It's a good practice to update the package list before installing a new package
    # sudo apt update
    sudo apt install kitty
fi

# install kitty theme
echo '-> Installing kitty configuration'
if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
    mv "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty_backup.conf"
fi
cp "$CONFIGDIR/src/config/kitty_config" "$HOME/.config/kitty/kitty.conf"
################################################

################################################
# install vscodium
echo '-> Verify if Vscodium exists'
chmod +x "$CONFIGDIR/src/scripts/install_vscodium.sh"
"$CONFIGDIR/src/scripts/install_vscodium.sh"
################################################

################################################
# install zsh
echo '-> Verify if zsh exists'
if [ "$(command -v zsh)" ]; then
    echo "Package \"Zsh\" exists on system"
else
    # It's a good practice to update the package list before installing a new package
    # sudo apt update
    sudo apt install zsh
fi
if [ -d "$HOME/.oh-my-zsh/" ]; then
    echo "directory \"$HOME/.oh-my-zsh\" exists"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
# install the zsh configuration
echo '-> Installing zsh configuration'
if [ -f "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc-backup"
fi
cp "$CONFIGDIR/src/config/zshrc" "$HOME/.zshrc"
################################################

################################################
# install nvm 
echo '-> Verify if NVM is installed'

# Define the NVM directory
export NVM_DIR="$HOME/.nvm"

# Try to source NVM if it's already installed but not loaded
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
fi

# Check if the nvm command is available now
if command -v nvm &> /dev/null; then
    echo "command \"NVM\" exists on system"
else
    echo "NVM is not installed on the system"
    # Install NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    
    # --- THIS IS THE TRICK ---
    # Source NVM immediately after installation so the script can use it
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# install node
echo '-> Verify if Node is installed'
if [ "$(command -v npm)" ]; then
    echo "command \"NPM\" exists on system"
else
    echo "NPM is not installed on the system"
    # Source nvm before using it
    . "$NVM_DIR/nvm.sh"
    nvm install v24.12.0 
fi
################################################

################################################
# Install Gemini

if [ "$(command -v gemini)" ]; then
    echo "command \"gemini\" exists on system"
else
    echo "Gemini is not installed on the system" 
    npm install -g @google/gemini-cli
fi
################################################