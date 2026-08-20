# Atalhos — referência para configurar você mesmo

Este setup não define atalhos automaticamente (depende do DE). Use a tabela
abaixo como referência: ela converte os atalhos do rice Hyprland em comandos
agnósticos. Configure no seu DE.

## Onde configurar

| DE | Onde |
|---|---|
| **GNOME** | *Settings → Keyboard → View and Customize Shortcuts* (ou `gsettings` / ferramentas como "Custom Shortcuts") |
| **XFCE** | *Settings → Window Manager → Keyboard* (janelas) + *Settings Manager → Keyboard → App Shortcuts* (apps) |

## Atalhos principais

| Atalho | Ação | Comando |
|---|---|---|
| `Super+Enter` | Terminal | `alacritty` (ou o do seu DE) |
| `Super+E` | Arquivos | gerenciador nativo (GNOME Files `nautilus` / XFCE `thunar`) |
| `Super+Space` | Launcher | GNOME: atividades · XFCE: `rofi -show drun` / whisker |
| `Super+Q` | Fechar janela | (depende do WM: `killactive`/Fechar) |
| `Super+F` / `Super+T` | Fullscreen / flutuar janela | (WM-specific) |
| `Super+P` | Monitores | GNOME: Settings→Displays · XFCE: `xfce4-display-settings` |
| `Super+Shift+S` | Screenshot com anotação | X11: `flameshot gui` · Wayland: `grim -g "$(slurp)" - \| satty` |
| `Print` / `Shift+Print` | Screenshot região / tela | GNOME tem nativo · XFCE: `xfce4-screenshooter` |
| `Super+V` | Clipboard history | GNOME: extensão · XFCE: `cliphist list \| rofi -dmenu \| cliphist decode \| wl-copy` |
| `Super+1..9` | Workspaces / desktops virtuais | (WM-specific) |
| `Super+Shift+E` | Sair da sessão | (WM-specific) |

## Mídia e brilho (teclas de função)

| Tecla | Ação | Comando |
|---|---|---|
| `XF86AudioRaiseVolume` / `Lower` | Volume | `pactl set-sink-volume @DEFAULT_SINK@ +5%/-5%` |
| `XF86AudioMute` | Mudo | `pactl set-sink-mute @DEFAULT_SINK@ toggle` |
| `XF86AudioPlay` / `Next` / `Prev` | Mídia | `playerctl play-pause / next / previous` |
| `XF86MonBrightnessUp` / `Down` | Brilho | `brightnessctl set 5%+ / 5%-` |

> Os DEs geralmente já mapeiam as teclas de mídia por padrão — só conferir se
> não está duplicado.