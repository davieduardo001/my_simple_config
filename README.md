# dotfiles — Arch Linux + Hyprland

Setup automatizado de um desktop Arch Linux com **Hyprland riced grayscale**, usando **Ansible**.
Um playbook instala tudo e conecta os dotfiles via symlinks.

## Stack

| Categoria | Ferramenta |
|---|---|
| Compositor | Hyprland (blur, cantos arredondados, animações custom) |
| Login | greetd + tuigreet |
| Barra | Waybar |
| Control center | swaync — painel lateral estilo celular (`Super+N`) |
| Launcher | Rofi (wayland nativo), tema Spotlight grayscale, `Super+Space` |
| Wallpaper | swaybg (aleatório de `wallpapers/`, `Super+W`) |
| Lock/idle | hyprlock + hypridle |
| Screenshot | grim + slurp + satty (`Super+Shift+S`, estilo Windows) |
| Clipboard | cliphist (`Super+V`) |
| Shell | Bash + Oh-My-Bash + Starship |
| Terminal | Alacritty (Min Dark, JetBrainsMono) + tmux para abas/splits |
| Editor | Neovim + [LazyVim config](https://github.com/davieduardo001/lazyvim-config) |
| Arquivos | Dolphin (+ kio-extras, ffmpegthumbs, ark) — `Super+E` |
| Browser | Firefox + Chromium |
| Office | OnlyOffice (AUR) — visualização/edição leve de docx/xlsx/pptx |
| Apps | GNOME Calculator, Syncthing (serviço habilitado), LocalSend |
| CLI tools | eza, bat, zoxide, fzf, btop, fastfetch |
| Fontes | CaskaydiaCove & JetBrainsMono Nerd Fonts (pacotes oficiais) |
| Ícones/cursor | Papirus-Dark (repo oficial) + macOS cursor (apple_cursor) |
| Tema escuro | GTK via `settings.ini` + gsettings · Qt via qt5ct/qt6ct (Fusion escuro) |
| Runtimes | Node (fnm), Python (pyenv), Rust (rustup) |
| Rede | NetworkManager + BlueZ (instalados e habilitados pelo playbook) |
| Data/hora | NTP via systemd-timesyncd — timezone em `system_timezone` |
| Monitores | nwg-displays (`Super+P`) — espelhar/estender/posicionar |
| AUR helper | paru — **toda** instalação de pacote passa por ele |

## Requisitos

- Arch Linux limpo (o pre-task valida) com usuário `sudo`
- Só `git` + `ansible` + `python-jmespath` pra dar o boot — o resto (paru, pacotes, runtimes, fontes, tema) o playbook instala

## Instalação

```bash
# 1. Bootstrap
sudo pacman -Sy --needed git ansible python-jmespath

# 2. Clonar
git clone <este-repo> ~/dotfiles
cd ~/dotfiles/ansible

# 3. Rodar tudo (pede a senha de sudo uma vez)
ansible-playbook site.yml --ask-become-pass
```

Depois é só **reboot** → o boot cai no tuigreet → login → Hyprland.

> O greetd é apenas *habilitado* pelo playbook — a troca de display manager acontece no próximo boot, de propósito, pra não derrubar a sessão de onde você está rodando.

## Atalhos principais

| Atalho | Ação |
|---|---|
| `Super+Space` | Launcher (Rofi) |
| `Super+N` | Control center lateral (swaync) |
| `Super+P` | Configurar monitores (nwg-displays) |
| `Super+Enter` | Terminal (Alacritty) |
| `Super+E` | Gerenciador de arquivos (Dolphin) |
| `Super+Shift+S` | Screenshot com anotação (satty) |
| `Print` / `Shift+Print` | Região → clipboard / tela → arquivo |
| `Super+V` | Histórico do clipboard |
| `Super+Escape` | Bloquear tela (hyprlock) |
| `Super+Q` | Fechar janela |
| `Super+F` / `Super+T` | Fullscreen / flutuar janela |
| `Super+1..9` | Workspaces |
| `Super+A` / `Super+D` | Workspace anterior / próximo |
| `Super+Shift+R` | Recarregar config do Hyprland |
| `Super+Shift+E` | Sair da sessão |

### Terminal — abas e splits (tmux)

O Alacritty não tem abas nem splits nativos; quem faz esse papel é o tmux
(`base_config/tmux/tmux.conf` → `~/.tmux.conf`). Prefixo padrão `Ctrl+b`:

| Atalho | Ação |
|---|---|
| `Ctrl+b` `t` | Nova aba (window) |
| `Ctrl+b` `w` | Fechar split/pane atual |
| `Ctrl+b` `\|` | Split vertical |
| `Ctrl+b` `-` | Split horizontal |

Abas e splits novos abrem no diretório atual.

## Uso

Re-rode o playbook quando quiser — todas as roles são idempotentes:

```bash
# Só dotfiles (symlinks)
ansible-playbook site.yml --ask-become-pass --tags dotfiles

# Só paleta/tema (re-renderiza as cores + gsettings)
ansible-playbook site.yml --ask-become-pass --tags theming

# Pular passos interativos (gh auth)
ansible-playbook site.yml --ask-become-pass --skip-tags interactive
```

### Trocar a paleta

As cores do rice inteiro (Hyprland, Waybar, swaync, Rofi) vêm de um único
dicionário: `theme_palette` em `ansible/group_vars/all.yml`. Edite lá e rode
`--tags theming` — os arquivos de cor são re-renderizados dentro de
`base_config/` (e versionados, então a mudança aparece no `git diff`).

### Monitores (espelhar / estender / posicionar)

`Super+P` abre o **nwg-displays**: arraste os monitores pra definir a posição,
marque um como espelho de outro, ajuste resolução/escala/rotação e clique em
*Apply*. Ele escreve `base_config/hypr/monitors.conf` inteiro — como o
`~/.config/hypr` é symlink pro repo, a mudança cai direto no `git diff`.

O `hyprland.conf` mantém `monitor = , preferred, auto, 1` como fallback pra
monitor desconhecido e dá `source` no `monitors.conf` **depois**, porque no
Hyprland a última diretiva de um output é a que vale.

Na mão, se preferir, a sintaxe é
`monitor = NOME, RESOLUÇÃO, POSIÇÃO, ESCALA[, mirror, ORIGEM]`:

```bash
monitor = HDMI-A-1, preferred, auto-right, 1           # estende à direita
monitor = HDMI-A-1, preferred, auto, 1, mirror, eDP-1  # espelha o eDP-1
```

> Espelhando, o monitor de destino herda a resolução da origem — telas com
> proporções diferentes ganham tarja preta. Nesse caso, force uma resolução
> comum nos dois em vez de `preferred`.

### Trocar o wallpaper

`~/.config/hypr/scripts/wallpaper.sh` aplica um aleatório de `wallpapers/`
via swaybg. Roda no autostart; `Super+W` sorteia outro, `Super+Shift+W` escolhe.

## Estrutura

```
ansible/
├── ansible.cfg
├── inventory/hosts.yml
├── group_vars/all.yml    # pacotes, versões e paleta (fonte única de verdade)
├── site.yml              # playbook principal
└── roles/
    ├── mirrors/          # mirrorlist via reflector
    ├── pacman/           # Color, ILoveCandy, ParallelDownloads
    ├── makepkg/          # sem debug packages (builds AUR mais rápidos)
    ├── paru/             # AUR helper — todo pacote é instalado por ele
    ├── paru_install/     # role auxiliar: instala pacote a pacote, com retry
    ├── sudoers/          # janela NOPASSWD temporária p/ o paru (aberta/fechada no site.yml)
    ├── packages/         # pacotes base + remoção de legados (vscode, rofi X11)
    ├── aur_packages/     # (vazio hoje — os AUR restantes vivem em desktop_apps)
    ├── network/          # NetworkManager + BlueZ + NTP (timesyncd) habilitados
    ├── hyprland/         # compositor + waybar + swaync + rofi-wayland + tools
    ├── greetd/           # tuigreet → Hyprland, desabilita DM antigo
    ├── theming/          # ícones/cursor + renderiza a paleta grayscale
    ├── neovim/           # Neovim + clone da config LazyVim
    ├── apps/             # Dolphin, OnlyOffice, calculadora, Syncthing, LocalSend, Firefox, Chromium
    ├── flatpak/          # Flatpak + Flathub (infra pronta, sem apps por padrão)
    ├── node|pyenv|rust|oh_my_bash|fonts/
    ├── dotfiles/         # symlinks de tudo em base_config/ (+ wallpapers)
    ├── github_cli/       # gh auth check
    └── claude/           # Claude Code CLI (pacote AUR `claude-code`, via paru)

base_config/              # fonte de verdade dos dotfiles (symlinkado p/ ~/.config)
├── bash/bashrc
├── fastfetch/
├── alacritty/alacritty.toml
├── tmux/tmux.conf        # symlinkado p/ ~/.tmux.conf
├── hypr/                 # hyprland.conf, conf.d/, monitors.conf, hyprlock, hypridle, scripts/
├── waybar/
├── swaync/
├── rofi/                 # tema spotlight-gray
├── gtk-3.0/ gtk-4.0/     # settings.ini (tema escuro)
└── qt5ct/ qt6ct/         # tema escuro dos apps Qt

docs/                     # PRD e SPEC da migração p/ Hyprland (histórico, ver nota)
wallpapers/
```

## Customização

- Pacotes/versões/paleta: `ansible/group_vars/all.yml`
- Atalhos: `base_config/hypr/conf.d/binds.conf`
- Animações: `base_config/hypr/conf.d/animations.conf`
- Barra: `base_config/waybar/`
- Control center: `base_config/swaync/`
