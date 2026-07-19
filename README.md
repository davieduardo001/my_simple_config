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
| Wallpaper | swww (transição animada, aleatório de `wallpapers/`) |
| Lock/idle | hyprlock + hypridle |
| Screenshot | grim + slurp + satty (`Super+Shift+S`, estilo Windows) |
| Clipboard | cliphist (`Super+V`) |
| Shell | Bash + Oh-My-Bash + Starship |
| Terminal | Ghostty (Min Dark, JetBrainsMono) |
| Editor | Neovim + [LazyVim config](https://github.com/davieduardo001/lazyvim-config) |
| Browser | Firefox + Chromium |
| Office | OnlyOffice (AUR) — visualização/edição leve de docx/xlsx/pptx |
| Apps | GNOME Calculator, Syncthing (serviço habilitado), LocalSend |
| CLI tools | eza, bat, zoxide, fzf, btop, fastfetch |
| Fontes | CaskaydiaCove & JetBrainsMono Nerd Fonts (pacotes oficiais) |
| Ícones/cursor | Papirus-Dark (repo oficial) + macOS cursor (apple_cursor) |
| Runtimes | Node (NVM), Python (pyenv), Bun, Rust (rustup) |
| Rede | NetworkManager + BlueZ (instalados e habilitados pelo playbook) |
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
| `Super+Enter` | Terminal (Ghostty) |
| `Super+Shift+S` | Screenshot com anotação (satty) |
| `Print` / `Shift+Print` | Região → clipboard / tela → arquivo |
| `Super+V` | Histórico do clipboard |
| `Super+Escape` | Bloquear tela (hyprlock) |
| `Super+Q` | Fechar janela |
| `Super+1..9` | Workspaces |
| `Super+A` / `Super+D` | Workspace anterior / próximo |
| `Super+Shift+R` | Recarregar config do Hyprland |

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

### Trocar o wallpaper

`~/.config/hypr/scripts/wallpaper.sh` aplica um aleatório de `wallpapers/`
com transição do swww. Roda no autostart; rode de novo pra sortear outro.

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
    ├── sudoers/          # janela NOPASSWD temporária p/ o paru (aberta/fechada no site.yml)
    ├── packages/         # pacotes base + remoção de legados (vscode, rofi X11)
    ├── aur_packages/     # ghostty
    ├── network/          # NetworkManager + BlueZ habilitados
    ├── hyprland/         # compositor + waybar + swaync + rofi-wayland + tools
    ├── greetd/           # tuigreet → Hyprland, desabilita DM antigo
    ├── theming/          # ícones/cursor + renderiza a paleta grayscale
    ├── neovim/           # Neovim + clone da config LazyVim
    ├── apps/             # OnlyOffice, calculadora, Syncthing, LocalSend, Firefox, Chromium
    ├── flatpak/          # Flatpak + Flathub (infra pronta, sem apps por padrão)
    ├── node|pyenv|bun|rust|oh_my_bash|fonts/
    ├── dotfiles/         # symlinks de tudo em base_config/ (+ wallpapers)
    ├── github_cli/       # gh auth check
    └── claude/           # Claude Code CLI + RTK

base_config/              # fonte de verdade dos dotfiles (symlinkado p/ ~/.config)
├── bash/bashrc
├── fastfetch/
├── ghostty/config
├── hypr/                 # hyprland.conf, conf.d/, hyprlock, hypridle, scripts/
├── waybar/
├── swaync/
└── rofi/                 # tema spotlight-gray

docs/                     # PRD e SPEC da migração p/ Hyprland
wallpapers/
```

## Customização

- Pacotes/versões/paleta: `ansible/group_vars/all.yml`
- Atalhos: `base_config/hypr/conf.d/binds.conf`
- Animações: `base_config/hypr/conf.d/animations.conf`
- Barra: `base_config/waybar/`
- Control center: `base_config/swaync/`
