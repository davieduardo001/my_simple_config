#!/usr/bin/env bash
# Aplica um wallpaper aleatório de ~/.config/wallpapers via swww,
# com transição animada. Rode de novo para trocar.
WALL_DIR="$HOME/.config/wallpapers"

wall=$(find -L "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | shuf -n1)
[ -n "$wall" ] || exit 0

# espera o swww-daemon subir (autostart roda os dois em paralelo)
for _ in $(seq 1 50); do
    swww query &>/dev/null && break
    sleep 0.1
done

exec swww img "$wall" \
    --transition-type grow \
    --transition-pos center \
    --transition-fps 60 \
    --transition-duration 1.2
