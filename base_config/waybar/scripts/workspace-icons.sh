#!/usr/bin/env bash
# Mostra o ícone do app mais recentemente focado em cada workspace (1-9).
# Vazio = bolinha pequena. Ativo = destacado (cor clara via pango).
set -uo pipefail

icon_for_class() {
    local class
    class=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$class" in
        *chromium*|*chrome*) echo "" ;;
        *firefox*)           echo "" ;;
        *alacritty*)         echo "" ;;
        *nemo*)               echo "" ;;
        *code*|*nvim*)       echo "" ;;
        *discord*)           echo "" ;;
        *)                    echo "" ;;
    esac
}

emit() {
    active_ws=$(hyprctl activeworkspace -j | jq '.id')
    clients=$(hyprctl clients -j)

    out=""
    for ws in $(seq 1 9); do
        # janela com o menor focusHistoryID (mais recente) nesse workspace
        class=$(echo "$clients" | jq -r --argjson ws "$ws" '
            [.[] | select(.workspace.id == $ws)]
            | sort_by(.focusHistoryID)
            | .[0].class // empty
        ')

        if [ -z "$class" ]; then
            glyph="○"
        else
            glyph=$(icon_for_class "$class")
        fi

        if [ "$ws" -eq "$active_ws" ]; then
            out+="<span foreground='#edecee'>${glyph}</span> "
        else
            out+="<span foreground='#9b94ad'>${glyph}</span> "
        fi
    done

    echo "$out"
}

emit

socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - 2>/dev/null |
while read -r line; do
    case "$line" in
        workspace*|activewindow*|openwindow*|closewindow*|movewindow*) emit ;;
    esac
done
