#!/usr/bin/env bash
# Aplica um wallpaper aleatório de ~/.config/wallpapers via hyprpaper,
# Rode de novo para trocar.
set -uo pipefail

WALL_DIR="$HOME/.config/wallpapers"

# shellcheck source=/dev/null
source "$(dirname "$0")/wallpaper-lib.sh"

wall=$(find -L "$WALL_DIR" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | shuf -n1)

[ -n "$wall" ] || die "Nenhuma imagem encontrada em $WALL_DIR"

apply_wallpaper "$wall"
