#!/bin/bash

# install the fonts
chmod +x ./scripts/install_fonts.sh
./scripts/install_fonts.sh

# install kitty
if [ "$(command -v kitty)" ]; then
    echo "command \"kitty\" exists on system"
else
    sudo apt install kitty
fi

# install kitty theme
echo 'adding the kitty config!!'
rm -rf ~/.config/kitty/kitty_backup.conf
mv ~/.config/kitty/kitty.conf ~/.config/kitty/kitty_backup.conf
cp ./config/kitty_config ~/.config/kitty/kitty.conf