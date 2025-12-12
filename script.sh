#!/bin/bash

CONFIGDIR="$HOME/config/simple_configs"

# Install the fonts
chmod +x $CONFIGDIR/src/scripts/install_fonts_blex.sh
$CONFIGDIR/src/scripts/install_fonts_blex.sh
chmod +x $CONFIGDIR/src/scripts/install_fonts_fira.sh
$CONFIGDIR/src/scripts/install_fonts_fira.sh
chmod +x $CONFIGDIR/src/scripts/install_fonts_caskaydia.sh
$CONFIGDIR/src/scripts/install_fonts_caskaydia.sh

################################################
# install kitty
echo '-> Verify if Kitty existis'
if [ "$(command -v kitty)" ]; then
    echo "Package \"Kitty\" exists on system"
else
    sudo apt install kitty
fi

# install kitty theme
echo '-> Installing kitty configuration'
rm -rf $HOME/.config/kitty/kitty_backup.conf
mv $HOME/.config/kitty/kitty.conf $HOME/.config/kitty/kitty_backup.conf
cp $CONFIGDIR/src/config/kitty_config $HOME/.config/kitty/kitty.conf
################################################

################################################
# install vscodium
echo '-> Verify if Vscodium existis'
chmod +x $CONFIGDIR/src/scripts/install_vscodium.sh
$CONFIGDIR/src/scripts/install_vscodium.sh
################################################

################################################
# install zsh
echo '-> Verify if zsh existis'
if [ "$(command -v zsh)" ]; then
    echo "Package \"Zsh\" exists on system"
else
    sudo apt install zsh
fi
if [ -d "$HOME/.oh-my-zsh/" ]; then
    echo "directory \"$HOME/.oh-my-zsh\" exists"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
# install the zsh configuration
echo '-> Installing zsh configuration'
mv $HOME/.zshrc $HOME/.zshrc-backup
cp $CONFIGDIR/src/config/zshrc $HOME/.zshrc
################################################

################################################
# install nvm 
echo '-> Verify if NVM is installed'

# Define o diretório do NVM
export NVM_DIR="$HOME/.nvm"

# Tenta carregar o NVM primeiro (caso já esteja instalado mas não carregado)
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
fi

# Verifica se o comando nvm funciona agora
if command -v nvm &> /dev/null; then
    echo "command \"NVM\" exists on system"
else
    echo "NVM its not installed on the system"
    # Instala o NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    
    # --- O PULO DO GATO ESTÁ AQUI ---
    # Recarrega o NVM imediatamente após a instalação para que o script possa usá-lo
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

echo '-> Verify if Node is installed'
# Agora o comando nvm funcionará nas linhas abaixo (ex: nvm install node)
# install node
echo '-> Verify if Node is installed'
if [ "$(command -v npm)" ]; then
    echo "command \"NPM\" exists on system"
else
    echo "NPM its not installed on the system"
    nvm install latest
fi