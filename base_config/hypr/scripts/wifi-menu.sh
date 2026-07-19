#!/usr/bin/env bash
# Menu de wifi no rofi: lista as redes, conecta, pede senha se precisar.
set -uo pipefail

rofi_menu() { rofi -dmenu -i -p "$1" -theme spotlight-gray; }

notify() { command -v notify-send &>/dev/null && notify-send "Wi-Fi" "$1"; }

if [ "$(nmcli -g WIFI radio)" = "disabled" ]; then
    [ "$(printf 'Ligar Wi-Fi\nCancelar' | rofi_menu 'Wi-Fi desligado')" = "Ligar Wi-Fi" ] || exit 0
    nmcli radio wifi on
    sleep 2
fi

nmcli device wifi rescan &>/dev/null

# SSID | sinal | segurança — o SSID é recuperado por corte, então nome com
# espaço não quebra
list=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list \
    | awk -F: '$2 != "" { printf "%s%s  (%s%%)%s\n", ($1=="*" ? "󰸞 " : "   "), $2, $3, ($4=="" ? "  ·  aberta" : "  ·  "$4) }' \
    | awk '!seen[$0]++')

[ -n "$list" ] || { notify "Nenhuma rede encontrada"; exit 0; }

choice=$(printf '%s\n󰖪  Desligar Wi-Fi' "$list" | rofi_menu "Redes")
[ -n "$choice" ] || exit 0

if [[ "$choice" == *"Desligar Wi-Fi"* ]]; then
    nmcli radio wifi off
    exit 0
fi

# tira o ícone/prefixo e o sufixo "  (xx%) · ..."
ssid=$(sed -E 's/^(󰸞 |   )//; s/  \([0-9]+%\).*$//' <<<"$choice")

# já tem perfil salvo? conecta direto
if nmcli -g NAME connection show | grep -qxF "$ssid"; then
    nmcli connection up id "$ssid" &>/dev/null \
        && notify "Conectado a $ssid" || notify "Falha ao conectar a $ssid"
    exit 0
fi

if [[ "$choice" == *"aberta"* ]]; then
    nmcli device wifi connect "$ssid" &>/dev/null \
        && notify "Conectado a $ssid" || notify "Falha ao conectar a $ssid"
    exit 0
fi

pass=$(rofi -dmenu -password -p "Senha de $ssid" -theme spotlight-gray)
[ -n "$pass" ] || exit 0

if nmcli device wifi connect "$ssid" password "$pass" &>/dev/null; then
    notify "Conectado a $ssid"
else
    notify "Falha ao conectar a $ssid (senha errada?)"
fi
