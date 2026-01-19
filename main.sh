#!/bin/bash

DOTFILES_DIR=~/dotfiles
CONFIG_DIR=~/.config

############################

# install kitty
echo "* install kitty"
if command -v kitty >/dev/null 2>&1; then
  echo "** kitty exists"
else
  echo "** kitty not found, please install it"
  yay -S kitty
  exit 1
fi

# creating the sym link
echo '** creating sym link for kitty'
ln -s "$DOTFILES_DIR/src/configs/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf"

############################

# install lazyvim
echo "* install neovim"
if command -v nvim >/dev/null 2>&1; then
  echo "** neovim exists"
else
  echo "** neovim not found, please install it"
  yay -S nvim
  exit 1
fi

if [ -e "$CONFIG_DIR/nvim/its_installed.txt" ]; then
  echo "** lazyvim its installed."
else
  echo "** lazyvim its not installed."

  # required
  mv ~/.config/nvim{,.bak}
  # optional but recommended
  mv ~/.local/share/nvim{,.bak}
  mv ~/.local/state/nvim{,.bak}
  mv ~/.cache/nvim{,.bak}

  git clone https://github.com/LazyVim/starter ~/.config/nvim

  rm -rf ~/.config/nvim/.git

  touch "$CONFIG_DIR/nvim/its_installed.txt"
fi

# creating the sym links
echo '** creating sym link for nvim configs'
rm "$CONFIG_DIR/nvim/lua/config/keymaps.lua"
ln -s "$DOTFILES_DIR/src/configs/nvim_keybinds.lua" "$CONFIG_DIR/nvim/lua/config/keymaps.lua"

# correcting the copy paste on nvim
echo "* correcting the paste clip issue"
if command -v xclip >/dev/null 2>&1; then
  echo "** its ok"
else
  echo "** its not ok."
  yay -S xclip
fi

# install fonts
echo '* insatlling nerd fonts'

# Latest version can be found at: https://github.com/ryanoasis/nerd-fonts/releases/latest
NERD_FONT_VERSION="v3.4.0"
FONT_NAME="CaskaydiaCove Nerd Font"
FONT_DIR="$HOME/.local/share/fonts"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/CascadiaCode.zip"
ZIP_FILE="/tmp/CaskaydiaCove.zip"

intall_font() {
  if fc-list | grep -i "CaskaydiaCove Nerd Font" >/dev/null 2>&1; then
    echo "$FONT_NAME is already installed. Skipping installation."
    return
  fi

  # Clean up the temporary file on exit
  trap 'rm -f "$ZIP_FILE"' EXIT

  if fc-list | grep -i "CaskaydiaCove Nerd Font" >/dev/null 2>&1; then
    echo "$FONT_NAME is already installed. Skipping installation."
    return
  fi

  echo "$FONT_NAME is not installed. Downloading..."

  if curl -L -o "$ZIP_FILE" "$ZIP_URL"; then
    "Download complete. Installing font..."
    mkdir -p "$FONT_DIR" || echo "Failed to create font directory."
    unzip -o "$ZIP_FILE" -d "$FONT_DIR" || echo "Failed to unzip font."
    fc-cache -fv "$FONT_DIR" || echo "Failed to refresh font cache."
    echo "$FONT_NAME has been installed successfully."
  else
    echo "Failed to download $FONT_NAME. Please check the URL and your internet connection."
  fi
}
intall_font

# Installing zsh
echo "Starting Zsh installation..."
intall_zsh() {
  if command -v zsh &>/dev/null; then
    echo "Zsh is already installed. Skipping installation."
    echo "To make Zsh your default shell, run: chsh -s \$(which zsh)"
    return
  fi

  yay -S zsh || echo "Failed to install Zsh."

  echo "Zsh installed successfully."
  echo "To make Zsh your default shell, run: chsh -s \$(which zsh)"
}
intall_zsh

# Installing fastfetch
intall_fastfetch() {
  if command -v fastfetch &>/dev/null; then
    "fastfetch is already installed. Skipping installation."
    return
  fi

  yay -S fastfetch || echo "Failed to install fastfetch."

  echo "fastfetch installed successfully."
}
intall_fastfetch

# creating the sym links
echo '** creating sym link for fastfetch configs'

mkdir -p "$CONFIG_DIR/fastfetch"
ln -s "$DOTFILES_DIR/src/configs/fastfetch.jsonc" "$CONFIG_DIR/fastfetch/config.jsonc"

# install falmeshot
intall_flameshot() {
  if command -v flameshot &>/dev/null; then
    "flameshot is already installed. Skipping installation."
    return
  fi

  yay -S flameshot || echo "Failed to install flameshot."

  echo "flameshot installed successfully."
}
intall_flameshot
