#!/bin/bash

# Caminho da pasta de PNGs dentro do seu repo de config
PNG_DIR="$HOME/config/base_config/fastfetch/png"
TARGET="$PNG_DIR/pfp.png"

# Pega um arquivo aleatório que NÃO seja o pfp.png atual
SELECTED=$(find "$PNG_DIR" -type f ! -name "pfp.png" | shuf -n 1)

if [ -n "$SELECTED" ]; then
    ln -sf "$SELECTED" "$TARGET"
    echo "PFP atualizado para: $(basename "$SELECTED")"
else
    echo "Nenhum outro PNG encontrado em $PNG_DIR"
fi
