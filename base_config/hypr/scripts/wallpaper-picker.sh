#!/usr/bin/env bash
# Escolhe um wallpaper específico de ~/.config/wallpapers pelo rofi.
set -uo pipefail

WALL_DIR="$HOME/.config/wallpapers"

# shellcheck source=/dev/null
source "$(dirname "$0")/wallpaper-lib.sh"

mapfile -t walls < <(find -L "$WALL_DIR" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)

[ ${#walls[@]} -gt 0 ] || die "Nenhuma imagem encontrada em $WALL_DIR"

choice=$(printf '%s\n' "${walls[@]##*/}" | rofi -dmenu -i -p "Wallpaper" -theme spotlight-gray)
[ -n "$choice" ] || exit 0

for w in "${walls[@]}"; do
    if [ "${w##*/}" = "$choice" ]; then
        apply_wallpaper "$w"
        exit 0
    fi
done

die "Não encontrei o arquivo: $choice"
