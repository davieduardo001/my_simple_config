#!/usr/bin/env bash
# Escolhe um wallpaper específico de ~/.config/wallpapers pelo rofi.
set -uo pipefail

WALL_DIR="$HOME/.config/wallpapers"

mapfile -t walls < <(find -L "$WALL_DIR" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)

[ ${#walls[@]} -gt 0 ] || exit 0

choice=$(printf '%s\n' "${walls[@]##*/}" | rofi -dmenu -i -p "Wallpaper" -theme spotlight-gray)
[ -n "$choice" ] || exit 0

for w in "${walls[@]}"; do
    if [ "${w##*/}" = "$choice" ]; then
        exec swww img "$w" \
            --transition-type grow \
            --transition-pos center \
            --transition-fps 60 \
            --transition-duration 1.2
    fi
done
