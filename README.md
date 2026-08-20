# dotfiles — setup agnóstico (Homebrew + Flatpak)

Setup **distro-agnóstico** de um desktop com visual **WhiteSur** (ícones,
cursor e tema GTK estilo macOS) para **GNOME** ou **XFCE**.

Funciona em **Ubuntu**, **Fedora** e **Arch** — sem depender de Hyprland nem
de config de rice. Só instala **ícones, fontes, apps, CLI tools via Homebrew**
e um **shell mínimo**.

> Esta é a branch `agnostic`. A branch `main` é o rice completo Arch + Hyprland.
> Escolha a branch conforme o propósito.

## O que o setup instala

- **Homebrew (linuxbrew)** + CLI: `git gh eza bat zoxide fzf btop tmux starship
  fastfetch ripgrep fd lazygit unzip curl wget jq opencode syncthing`
- **Fontes**: JetBrainsMono Nerd, Cascadia Code Nerd, Inter → `~/.local/share/fonts`
- **Ícones** WhiteSur + **cursor** macOS (install.sh oficial do vinceliuice)
- **Tema GTK** WhiteSur-Dark → `~/.themes`
- **Flatpak apps**: Chromium, Firefox, OnlyOffice, GNOME Calculator, LocalSend
- **Shell mínimo**: Starship + aliases `eza`/`bat`/`zoxide` no `~/.bashrc`
- **Wallpaper padrão**: `wallpapers/panting.jpg`
- **Packet Tracer**: helper manual (ver `docs/packettracer.md`)

## Requisitos

- Ubuntu / Fedora / Arch (x86-64)
- Usuário com `sudo`
- `git` + `curl` (o script instala o resto)

## Instalação

```bash
git clone <este-repo> ~/dotfiles
cd ~/dotfiles

# Instala tudo
./setup.sh
```

> O script detecta a distro (`/etc/os-release`) e o DE
> (`XDG_CURRENT_DESKTOP`) e aplica o tema/atalhos corretos para GNOME ou XFCE.

### Packet Tracer (manual, login da Cisco)

```bash
# 1. Baixa o .deb em docs/packettracer.md (netacad)
# 2. Instala:
./setup.sh packet-tracer /caminho/para/CiscoPacketTracer_xxx_Ubuntu_64bit.deb
```

## Documentação

- [Atalhos — para você configurar no seu DE](docs/shortcuts.md)
- [Apps — o que cada um faz](docs/apps.md)
- [Packet Tracer — download + instalação](docs/packettracer.md)

## Estrutura

```
.
├── setup.sh              # instalador principal + helper do Packet Tracer
├── README.md
├── docs/
│   ├── shortcuts.md
│   ├── apps.md
│   └── packettracer.md
└── wallpapers/panting.jpg   # wallpaper padrão
```