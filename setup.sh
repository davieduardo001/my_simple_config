#!/usr/bin/env bash
#
# setup.sh — setup distro-agnóstico (Ubuntu / Fedora / Arch) para GNOME e XFCE.
#
# O que instala:
#   - Homebrew (linuxbrew) + CLI tools (git, gh, eza, bat, zoxide, fzf, btop,
#     tmux, starship, fastfetch, ripgrep, fd, lazygit, unzip, curl, wget, jq,
#     opencode, syncthing)
#   - Fontes (JetBrainsMono Nerd, Cascadia Code Nerd, Inter)
#   - Ícones WhiteSur + cursor macOS (install.sh oficial do vinceliuice)
#   - Tema GTK WhiteSur-Dark
#   - Apps via Flatpak (Chromium, Firefox, OnlyOffice, GNOME Calculator, LocalSend)
#   - Shell mínimo (Starship + aliases eza/bat/zoxide)
#   - Wallpaper padrão (wallpapers/panting.jpg)
#
# Uso:
#   ./setup.sh                    # instala tudo
#   ./setup.sh packet-tracer ./CiscoPacketTracer_xxx_Ubuntu_64bit.deb
#                                 # helper do Packet Tracer (após baixar o .deb)
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------- detecção de distro / DE ----------
detect_distro() {
    local id
    id=$(. /etc/os-release && echo "${ID:-}")
    case "$id" in
        ubuntu|debian|linuxmint) echo "ubuntu" ;;
        fedora|rhel|centos)      echo "fedora" ;;
        arch)                    echo "arch" ;;
        *) echo "unknown:$id" ;;
    esac
}

detect_de() {
    local de="${XDG_CURRENT_DESKTOP:-}"
    de="${de,,}"
    case "$de" in
        *gnome*|*ubuntu*|*budgie*|*pop*) echo "gnome" ;;
        *xfce*)                         echo "xfce" ;;
        *) echo "unknown:$de" ;;
    esac
}

DISTRO="$(detect_distro)"
DE="$(detect_de)"

say()  { printf "\n\033[1;32m==> %s\033[0m\n" "$*"; }
info() { printf "    %s\n" "$*"; }
die()  { printf "\033[1;31merror:\033[0m %s\n" "$*" >&2; exit 1; }

case "$DISTRO" in
    ubuntu|fedora|arch) ;;
    *) die "Distro não suportada: $DISTRO" ;;
esac

# ---------- 1. toolchain do brew + flatpak ----------
install_toolchain() {
    say "Garantindo toolchain do Homebrew + Flatpak/Flathub"
    case "$DISTRO" in
        ubuntu)
            sudo apt-get update -y
            sudo apt-get install -y build-essential procps curl file git flatpak
            flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            ;;
        fedora)
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y procps-ng curl file git flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            ;;
        arch)
            sudo pacman -S --needed --noconfirm base-devel git curl wget flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            ;;
    esac
}

# ---------- 2. Homebrew + CLI ----------
BREW_FORMULAE=(git gh eza bat zoxide fzf btop tmux starship fastfetch ripgrep fd \
               lazygit unzip curl wget jq syncthing)

install_brew() {
    if command -v brew >/dev/null 2>&1; then
        info "Homebrew já instalado."
        return
    fi
    say "Instalando Homebrew (linuxbrew)"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # põe o brew no PATH da sessão e grava no shell
    if [[ -d /home/linuxbrew/.linuxbrew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -d "$HOME/.linuxbrew" ]]; then
        eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
    fi

    # brew no ~/.bashrc (idempotente)
    grep -q 'shellenv.*linuxbrew' "$HOME/.bashrc" 2>/dev/null || cat >> "$HOME/.bashrc" <<'EOF'

# Homebrew (linuxbrew)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null || $HOME/.linuxbrew/bin/brew shellenv 2>/dev/null)"
EOF
}

install_brew_packages() {
    say "Instalando CLI tools via Homebrew"
    brew install "${BREW_FORMULAE[@]}"

    say "Instalando opencode (tap oficial)"
    brew tap anomalyco/tap
    brew install opencode

    if brew services list >/dev/null 2>&1; then
        info "Syncthing disponível como serviço: 'brew services start syncthing' (opcional)."
    fi
}

# ---------- 3. fontes ----------
install_fonts() {
    say "Instalando fontes (Nerd Fonts + Inter)"
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"

    local -A fonts=(
        ["JetBrainsMono"]="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        ["CascadiaCode"]="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
        ["Inter"]="https://github.com/rsms/inter/releases/latest/download/Inter.zip"
    )

    for name in "${!fonts[@]}"; do
        local tmp
        tmp="$(mktemp -d)"
        info "Baixando $name"
        curl -fsSL -o "$tmp/$name.zip" "${fonts[$name]}"
        unzip -oq "$tmp/$name.zip" -d "$tmp" || true
        find "$tmp" -maxdepth 1 -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp {} "$fonts_dir/" \;
        rm -rf "$tmp"
    done

    fc-cache -f >/dev/null 2>&1
}

# ---------- 4. ícones + cursor (install.sh oficial vinceliuice) ----------
install_theme_icons() {
    say "Instalando ícones WhiteSur + cursor macOS"
    local src="$HOME/.cache/agnostic-theme-src"

    if [[ ! -d "$HOME/.icons/WhiteSur" ]]; then
        git clone --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$src/WhiteSur-icon-theme"
        (cd "$src/WhiteSur-icon-theme" && ./install.sh -d "$HOME/.icons")
    fi

    if [[ ! -d "$HOME/.icons/macOS" ]]; then
        git clone --depth 1 https://github.com/vinceliuice/macOS-cursors.git "$src/macOS-cursors"
        (cd "$src/macOS-cursors" && ./install.sh -d "$HOME/.icons")
    fi
}

install_gtk_theme() {
    say "Instalando tema GTK WhiteSur-Dark"
    local src="$HOME/.cache/agnostic-theme-src"
    if [[ ! -d "$HOME/.themes/WhiteSur-Dark" ]]; then
        git clone --depth 1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git "$src/WhiteSur-gtk-theme"
        (cd "$src/WhiteSur-gtk-theme" && ./install.sh -c dark -d "$HOME/.themes")
    fi
}

# ---------- 5. aplicar tema por DE ----------
apply_de() {
    say "Aplicando tema ($DE)"
    case "$DE" in
        gnome)
            gsettings set org.gnome.desktop.interface icon-theme    "WhiteSur"
            gsettings set org.gnome.desktop.interface cursor-theme  "macOS"
            gsettings set org.gnome.desktop.interface gtk-theme     "WhiteSur-Dark"
            gsettings set org.gnome.desktop.interface color-scheme  "prefer-dark"
            gsettings set org.gnome.desktop.interface font-name     "Inter 11"
            gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:"
            # portal de integração (diálogos, screenshare)
            sudo apt-get install -y xdg-desktop-portal-gtk 2>/dev/null \
                || sudo dnf install -y xdg-desktop-portal-gtk 2>/dev/null \
                || sudo pacman -S --needed --noconfirm xdg-desktop-portal-gtk 2>/dev/null || true
            ;;
        xfce)
            xfconf-query -c xsettings -p /Net/IconThemeName -s "WhiteSur" 2>/dev/null || true
            xfconf-query -c xsettings -p /Net/ThemeName    -s "WhiteSur-Dark" 2>/dev/null || true
            xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "macOS" 2>/dev/null || true
            xfconf-query -c xsettings -p /Gtk/FontName -s "Inter 11" 2>/dev/null || true
            ;;
        *)
            info "DE desconhecido — pule a aplicação automática de tema (configure na mão)."
            ;;
    esac
}

# ---------- 6. apps via Flatpak ----------
FLATPAK_APPS=(
    org.chromium.Chromium
    org.mozilla.firefox
    org.onlyoffice.desktopeditors
    org.gnome.Calculator
    org.localsend.localsend_app
)

install_flatpak_apps() {
    say "Instalando apps via Flatpak"
    for app in "${FLATPAK_APPS[@]}"; do
        info "flatpak install $app"
        flatpak install --user --noninteractive -y flathub "$app"
    done
}

# ---------- 7. shell mínimo ----------
install_shell_min() {
    say "Configurando shell mínimo (Starship + aliases)"
    grep -q 'starship' "$HOME/.bashrc" 2>/dev/null || cat >> "$HOME/.bashrc" <<'EOF'

# Starship prompt
eval "$(starship init bash)"

# Aliases (eza/bat/zoxide)
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first"
alias cat="bat"
alias cd="z"
eval "$(zoxide init bash)"
EOF
    info "Starship precisa de um tema? Coloque um em ~/.config/starship.toml."
}

# ---------- 8. wallpaper padrão ----------
install_wallpaper() {
    say "Definindo wallpaper padrão (panting.jpg)"
    local bg_dir="$HOME/.local/share/backgrounds"
    mkdir -p "$bg_dir"
    cp "$REPO_ROOT/wallpapers/panting.jpg" "$bg_dir/panting.jpg"

    case "$DE" in
        gnome)
            gsettings set org.gnome.desktop.background picture-uri         "file://$bg_dir/panting.jpg"
            gsettings set org.gnome.desktop.background picture-uri-dark    "file://$bg_dir/panting.jpg"
            gsettings set org.gnome.desktop.background picture-options     "zoom"
            ;;
        xfce)
            for monitor in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep '/backdrop' | grep 'last-image' | sort -u); do
                xfconf-query -c xfce4-desktop -p "$monitor" -s "$bg_dir/panting.jpg" 2>/dev/null || true
            done
            ;;
    esac
}

# ---------- Packet Tracer helper ----------
cmd_packet_tracer() {
    local deb="${1:-}"
    [[ -n "$deb" && -f "$deb" ]] || die "Uso: $0 packet-tracer /caminho/para/CiscoPacketTracer_xxx_Ubuntu_64bit.deb"
    local name
    name="$(basename "$deb")"

    say "Instalando Packet Tracer em $DISTRO"
    case "$DISTRO" in
        ubuntu)
            sudo apt-get install -y "./$name" 2>/dev/null || {
                sudo dpkg -i "$deb"
                sudo apt-get -f install -y
            }
            ;;
        fedora)
            local script="$HOME/.cache/packettracer-rpm-based"
            git clone --depth 1 https://github.com/thiagoojack/packettracer-rpm-based.git "$script"
            info "Rode o instalador abaixo e selecione Install/Upgrade + escolha o $name:"
            info "  cd $script && ./setup"
            ;;
        arch)
            die "Arch não é alvo desta branch (use a branch main/Hyprland)."
            ;;
    esac

    ensure_pt_launcher
}

ensure_pt_launcher() {
    # garante .desktop/ícone quando o instalado não criou menu (Fedora/Arch)
    local appimage="/usr/lib/packettracer/packettracer.AppImage"
    if [[ ! -f "$appimage" ]]; then
        return
    fi
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/packettracer.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Packet Tracer
Exec=$appimage
Icon=packettracer
Terminal=false
Categories=Network;Education;
EOF
    info "Launcher do Packet Tracer garantido em ~/.local/share/applications."
}

# ---------- main ----------
main() {
    case "${1:-}" in
        packet-tracer)
            cmd_packet_tracer "${2:-}"
            ;;
        *)
            install_toolchain
            install_brew
            install_brew_packages
            install_fonts
            install_theme_icons
            install_gtk_theme
            apply_de
            install_flatpak_apps
            install_shell_min
            install_wallpaper
            say "Setup agnóstico concluído!"
            info "Packet Tracer: baixe o .deb da Cisco (docs/packettracer.md) e rode:"
            info "  $0 packet-tracer ./CiscoPacketTracer_xxx_Ubuntu_64bit.deb"
            ;;
    esac
}

main "$@"