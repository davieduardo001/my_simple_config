#!/bin/bash

## Installing oh my bash
OH_MY_BASH_DIR="$HOME/.oh-my-bash/"
echo -e "\n* INTALLING OH-MY-BASH"
if [ -d "$OH_MY_BASH_DIR" ]; then
  echo "** oh my bash exists"
else
  echo "oh my bash its not installed! Intalling it!"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
  echo "** oh my bash installed!!"
fi

## Intalling sdkman
SDKMAN_DIR="$HOME/.sdkman/"
echo -e "\n* INTALLING SDKMAN"
if [ -d "$OH_MY_BASH_DIR" ]; then
  echo "** sdkman exists"
else
  echo "sdkman its not installed! Intalling it!"
  curl -s "https://get.sdkman.io" | bash
  echo "** sdkman installed!!"
fi

## Download my fonts
FONT_INSTALLED="$HOME/.local/share/fonts/installed.txt"
echo -e "\n* INTALLING FONT"
if [ -f "$FONT_INSTALLED" ]; then
  echo "** your font its already installed!"
else
  echo "** your font its not installed.. intalling it!"
  wget -O /tmp/CascadiaCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip
  unzip /tmp/CascadiaCode.zip -d /tmp/CascadiaCode/
  mv /tmp/CascadiaCode/*.ttf $HOME/.local/share/fonts/
  touch FONT_INSTALLED
  rm -rf /tmp/CascadiaCode.zip
  rm -rf /tmp/CascadiaCode/
fi
