#!/usr/bin/env bash
# Funções compartilhadas pelos scripts de wallpaper (hyprpaper).
# Scripts chamados por keybind não têm terminal, então todo erro vira
# notificação — e sempre com a saída real do hyprctl junto, senão não dá
# pra saber o motivo.

die() {
    echo "$1" >&2
    command -v notify-send &>/dev/null && notify-send "Wallpaper" "$1"
    exit 1
}

ensure_daemon() {
    command -v hyprpaper &>/dev/null \
        || die "hyprpaper não está instalado — rode: paru -S hyprpaper"

    # responder ao IPC é o que importa; só o processo existir não basta
    hyprctl hyprpaper listloaded &>/dev/null && return 0

    pgrep -x hyprpaper &>/dev/null || hyprpaper &>/dev/null &

    for _ in $(seq 1 40); do
        hyprctl hyprpaper listloaded &>/dev/null && return 0
        sleep 0.1
    done

    die "hyprpaper não respondeu ao IPC (rodando fora de uma sessão Hyprland?)"
}

apply_wallpaper() {
    local wall out
    # hyprpaper não lida bem com caminho que passa por symlink
    # (~/.config/wallpapers aponta pro repo), então resolve pro caminho real
    wall=$(realpath "$1")

    [ -r "$wall" ] || die "não consigo ler o arquivo: $wall"

    ensure_daemon

    # unload all evita encher a RAM ao trocar várias vezes
    hyprctl hyprpaper unload all &>/dev/null

    if ! out=$(hyprctl hyprpaper preload "$wall" 2>&1) || [ "$out" != "ok" ]; then
        die "preload falhou: ${out:-sem saída} [$wall]"
    fi

    if ! out=$(hyprctl hyprpaper wallpaper ",$wall" 2>&1) || [ "$out" != "ok" ]; then
        die "wallpaper falhou: ${out:-sem saída} [$wall]"
    fi

    echo "$wall" > "$HOME/.cache/current-wallpaper"
}
