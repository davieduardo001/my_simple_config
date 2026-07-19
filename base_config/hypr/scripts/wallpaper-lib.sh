#!/usr/bin/env bash
# Funções compartilhadas pelos scripts de wallpaper (hyprpaper).
# Scripts chamados por keybind não têm terminal, então todo erro vira
# notificação — senão a falha acontece em silêncio.

die() {
    echo "$1" >&2
    command -v notify-send &>/dev/null && notify-send "Wallpaper" "$1"
    exit 1
}

ensure_daemon() {
    command -v hyprpaper &>/dev/null \
        || die "hyprpaper não está instalado — rode: paru -S hyprpaper"

    if ! pgrep -x hyprpaper &>/dev/null; then
        hyprpaper &>/dev/null &
        for _ in $(seq 1 30); do
            pgrep -x hyprpaper &>/dev/null && sleep 0.3 && return 0
            sleep 0.1
        done
        die "hyprpaper não subiu"
    fi
}

apply_wallpaper() {
    local wall="$1"
    ensure_daemon

    # unload all evita encher a RAM ao trocar várias vezes
    hyprctl hyprpaper unload all &>/dev/null

    hyprctl hyprpaper preload "$wall" &>/dev/null \
        || die "preload falhou em $(basename "$wall")"

    # monitor vazio antes da vírgula = todos os monitores
    hyprctl hyprpaper wallpaper ",$wall" &>/dev/null \
        || die "não consegui aplicar $(basename "$wall")"

    echo "$wall" > "$HOME/.cache/current-wallpaper"
}
