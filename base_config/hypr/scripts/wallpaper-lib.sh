#!/usr/bin/env bash
# Funções compartilhadas pelos scripts de wallpaper.
# Scripts chamados por keybind não têm terminal, então todo erro vira
# notificação — senão a falha acontece em silêncio.

die() {
    echo "$1" >&2
    command -v notify-send &>/dev/null && notify-send "Wallpaper" "$1"
    exit 1
}

ensure_daemon() {
    command -v swww &>/dev/null || die "swww não está instalado (rode o playbook com --tags hyprland)"

    if ! swww query &>/dev/null; then
        swww-daemon &>/dev/null &
        for _ in $(seq 1 50); do
            swww query &>/dev/null && return 0
            sleep 0.1
        done
        die "swww-daemon não subiu"
    fi
}

apply_wallpaper() {
    local wall="$1"
    ensure_daemon
    swww img "$wall" \
        --transition-type grow \
        --transition-pos center \
        --transition-fps 60 \
        --transition-duration 1.2 \
        || die "swww img falhou em $(basename "$wall")"
}
