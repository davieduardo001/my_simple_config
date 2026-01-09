#!/bin/bash
# Fedora installation script

# Update system
sudo dnf update -y

# Install packages from dnf
sudo dnf install -y zsh fastfetch git

# Install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install fonts (assuming the scripts are compatible)
./install_fonts_caskaydia.sh
./install_fonts_fira.sh

# Install ghostty (assuming the script is compatible)
./install_ghostty.sh

# Install Neovim from source
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=Release
sudo make install
cd ..
rm -rf neovim

echo "Fedora installation complete!"
