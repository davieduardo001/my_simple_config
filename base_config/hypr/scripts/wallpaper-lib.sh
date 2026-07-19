#!/usr/bin/env bash
# Funções compartilhadas pelos scripts de wallpaper.
#
# Usa swaybg: sem daemon, sem IPC, sem protocolo — é só um processo
# desenhando a imagem. Trocar = subir o novo e matar o antigo.
# Scripts chamados por keybind não têm terminal, então erro vira notificação.

die() {
    echo "$1" >&2
    command -v notify-send &>/dev/null && notify-send "Wallpaper" "$1"
    exit 1
}

apply_wallpaper() {
    local wall
    # ~/.config/wallpapers é symlink pro repo; resolve pro caminho real
    wall=$(realpath "$1")

    command -v swaybg &>/dev/null || die "swaybg não instalado — rode: paru -S swaybg"
    [ -r "$wall" ] || die "não consigo ler o arquivo: $wall"

    local old
    old=$(pgrep -x swaybg | tr '\n' ' ')

    swaybg -i "$wall" -m fill &>/dev/null &
    local new=$!

    # dá um instante pro novo desenhar antes de matar o antigo (evita piscar);
    # se ele morreu nesse meio tempo, algo deu errado com a imagem
    sleep 0.4
    if ! kill -0 "$new" 2>/dev/null; then
        die "swaybg não conseguiu carregar $(basename "$wall")"
    fi

    [ -n "$old" ] && kill $old 2>/dev/null

    echo "$wall" > "$HOME/.cache/current-wallpaper"
}
