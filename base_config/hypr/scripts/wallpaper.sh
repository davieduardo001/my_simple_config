#!/usr/bin/env bash
# Aplica um wallpaper de ~/.config/wallpapers via swaybg.
# Sem argumentos: sorteia (rode de novo para trocar).
# --restore: reaplica o último usado (~/.cache/current-wallpaper); usado
#   no exec-once pra sessão nova não sortear um diferente toda hora.
set -uo pipefail

WALL_DIR="$HOME/.config/wallpapers"
CACHE_FILE="$HOME/.cache/current-wallpaper"

# shellcheck source=/dev/null
source "$(dirname "$0")/wallpaper-lib.sh"

wall=""
if [ "${1:-}" = "--restore" ] && [ -r "$CACHE_FILE" ]; then
    wall=$(cat "$CACHE_FILE")
    [ -r "$wall" ] || wall=""
fi

if [ -z "$wall" ]; then
    wall=$(find -L "$WALL_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | shuf -n1)
fi

[ -n "$wall" ] || die "Nenhuma imagem encontrada em $WALL_DIR"

apply_wallpaper "$wall"
