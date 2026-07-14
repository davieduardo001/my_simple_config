#!/bin/bash

# --- Configurações de Diretórios ---
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BASE_CONFIG="$REPO_ROOT/base_config"

# --- Funções de Ajuda ---
log()  { echo -e "\n* $1"; }
ok()   { echo -e "  ✅ $1"; }
warn() { echo -e "  ⚠️  $1"; }
err()  { echo -e "  ❌ $1"; }

# --- 0. Mirrors rápidos via reflector ---
setup_mirrors() {
    log "ATUALIZANDO MIRRORS (reflector)"
    sudo pacman -S --needed --noconfirm reflector
    sudo reflector \
        --country Brazil \
        --age 12 \
        --protocol https \
        --sort rate \
        --save /etc/pacman.d/mirrorlist
    ok "Mirrors atualizados!!"
}

# --- 1. Configurar pacman (paralelo + visual) ---
configure_pacman() {
    log "CONFIGURANDO PACMAN"
    local conf="/etc/pacman.conf"

    sudo sed -i 's/^#Color/Color/' "$conf"
    sudo sed -i '/^Color/a ILoveCandy' "$conf"
    sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' "$conf"

    ok "pacman configurado (Color, ILoveCandy, ParallelDownloads=10)!!"
}

# --- 1b. Configurar makepkg (desliga pacote de debug — inútil e lento em pacotes ---
# ---     AUR com muitos arquivos, tipo temas de ícone) ---
configure_makepkg() {
    log "CONFIGURANDO MAKEPKG (desativando pacote de debug)"
    sudo sed -i 's/ debug / !debug /' /etc/makepkg.conf
    ok "Pacote de debug desativado — builds AUR com muitos arquivos ficam bem mais rápidos"
}

# --- 2. paru (AUR helper, feito em Rust) ---
install_paru() {
    log "INSTALANDO PARU (AUR HELPER)"
    if command -v paru &>/dev/null; then
        ok "paru já está instalado."
        return
    fi
    sudo pacman -S --needed --noconfirm git base-devel
    local tmp
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$tmp/paru"
    (cd "$tmp/paru" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    if ! command -v paru &>/dev/null; then
        err "paru falhou ao instalar — verifique base-devel/fakeroot."
        return 1
    fi
    ok "paru instalado!!"
}

# --- 3. Pacotes base via pacman ---
install_system_packages() {
    log "INSTALANDO PACOTES BASE (pacman)"
    sudo pacman -Syu --needed --noconfirm \
        base-devel git curl wget unzip \
        openssl zlib xz readline sqlite \
        github-cli fastfetch fontconfig \
        starship eza bat zoxide fzf btop timeshift
    ok "Pacotes base instalados!!"
}

# --- 4. Pacotes AUR via paru ---
install_aur_packages() {
    log "INSTALANDO PACOTES AUR (paru)"
    paru -S --needed --noconfirm \
        brave-bin \
        visual-studio-code-bin \
        ghostty
    ok "Pacotes AUR instalados!!"
}

# --- 5. NVM + Node.js ---
install_node() {
    log "INSTALANDO NVM + NODE"
    export NVM_DIR="$HOME/.nvm"
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh"
    if ! command -v node &>/dev/null; then
        nvm install --lts && nvm use --lts
    fi
    ok "Node $(node -v) disponível!!"
}

# --- 6. pyenv ---
install_pyenv() {
    log "INSTALANDO PYENV"
    if command -v pyenv &>/dev/null; then
        ok "pyenv já instalado."
        return
    fi
    curl https://pyenv.run | bash
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    ok "pyenv instalado!!"
}

# --- 7. Bun ---
install_bun() {
    log "INSTALANDO BUN"
    if command -v bun &>/dev/null; then
        ok "bun já instalado: $(bun --version)"
        return
    fi
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
    ok "bun instalado: $(bun --version)"
}

# --- 8. Rust via rustup ---
install_rust() {
    log "INSTALANDO RUST (rustup)"
    if command -v rustc &>/dev/null; then
        ok "Rust já instalado: $(rustc --version)"
        return
    fi
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
    ok "Rust instalado: $(rustc --version)"
}

# --- 9. GitHub CLI: autenticar ---
setup_gh() {
    log "CONFIGURANDO GITHUB CLI (gh)"
    if ! command -v gh &>/dev/null; then
        err "gh não encontrado — verifique o passo 3."
        return
    fi
    if gh auth status &>/dev/null; then
        ok "gh já autenticado."
    else
        gh auth login
        ok "gh autenticado!!"
    fi
}

# --- 10. Claude Code CLI ---
install_claude() {
    log "INSTALANDO CLAUDE CODE CLI"
    if command -v claude &>/dev/null; then
        ok "claude já instalado: $(claude --version 2>/dev/null || echo 'ok')"
        return
    fi
    npm install -g @anthropic-ai/claude-code
    ok "Claude Code instalado!!"
}

# --- 11. Plugins globais do Claude ---
install_claude_plugins() {
    log "INSTALANDO PLUGINS GLOBAIS DO CLAUDE"
    if ! command -v claude &>/dev/null; then
        warn "claude não encontrado. Pulando plugins."
        return
    fi

    log "  → claude-mem"
    claude plugin install thedotmack/claude-mem 2>/dev/null || \
        warn "claude-mem: falha ou já instalado"

    log "  → context-mode"
    claude plugin install anthropics/context-mode 2>/dev/null || \
        warn "context-mode: falha ou já instalado"

    log "  → RTK (Rust Token Killer)"
    if command -v rtk &>/dev/null; then
        ok "rtk já instalado: $(rtk --version 2>/dev/null)"
    else
        source "$HOME/.cargo/env" 2>/dev/null || true
        if command -v cargo &>/dev/null; then
            cargo install rtk || warn "RTK: falha no cargo install"
        else
            warn "RTK: rode install_rust primeiro"
        fi
    fi

    ok "Plugins Claude configurados!!"
}

# --- 12. Oh-My-Bash ---
install_ombash() {
    log "INSTALANDO OH-MY-BASH"
    if [ -d "$HOME/.oh-my-bash/" ]; then
        ok "oh-my-bash já instalado."
        return
    fi
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
    ok "oh-my-bash instalado!!"
}

# --- 13. Nerd Fonts ---
install_fonts() {
    log "INSTALANDO NERD FONTS (CaskaydiaCove + JetBrainsMono)"
    local fonts_dir="$HOME/.local/share/fonts"

    if find "$fonts_dir" -iname "*NerdFont*" 2>/dev/null | grep -q .; then
        ok "Nerd Fonts já instaladas."
        return
    fi

    mkdir -p "$fonts_dir" /tmp/fonts-unzip

    wget -q --show-progress -L -O /tmp/CaskaydiaCove.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CaskaydiaCove.zip
    wget -q --show-progress -L -O /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip

    unzip -q -o /tmp/CaskaydiaCove.zip -d /tmp/fonts-unzip/ || warn "CaskaydiaCove: falha no unzip"
    unzip -q -o /tmp/JetBrainsMono.zip -d /tmp/fonts-unzip/ || warn "JetBrainsMono: falha no unzip"

    find /tmp/fonts-unzip -type f \( -name "*.ttf" -o -name "*.otf" \) -exec mv {} "$fonts_dir/" \;
    rm -rf /tmp/CaskaydiaCove.zip /tmp/JetBrainsMono.zip /tmp/fonts-unzip
    fc-cache -fv > /dev/null
    ok "Fontes instaladas!!"
}

# --- 14. Ícones/cursor (AUR) + aplicar tema (GNOME ou XFCE) ---
THEMING_AUR_PACKAGES=(
    mcmojave-circle-icon-theme-git
    whitesur-icon-theme-git
    fluent-icon-theme-git
    quintom-cursor-theme-git
    apple_cursor
)
THEME_ICON="McMojave-circle"
THEME_CURSOR="macOS"
THEME_GTK="Adwaita"

install_theming_packages() {
    log "INSTALANDO TEMAS DE ÍCONE/CURSOR (AUR)"
    paru -S --needed --noconfirm "${THEMING_AUR_PACKAGES[@]}"
    ok "Pacotes de tema instalados!!"
}

apply_theme() {
    log "APLICANDO TEMA (ícones/cursor/GTK)"
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        warn "Nenhuma sessão gráfica detectada — pulando aplicação automática de tema."
        return
    fi

    case "$XDG_CURRENT_DESKTOP" in
        *GNOME*)
            gsettings set org.gnome.desktop.interface icon-theme "$THEME_ICON"
            gsettings set org.gnome.desktop.interface cursor-theme "$THEME_CURSOR"
            gsettings set org.gnome.desktop.interface gtk-theme "$THEME_GTK"
            ok "Tema aplicado via gsettings (GNOME)"
            ;;
        *XFCE*)
            xfconf-query -c xsettings -p /Net/IconThemeName -s "$THEME_ICON"
            xfconf-query -c xsettings -p /Net/ThemeName -s "$THEME_GTK"
            xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$THEME_CURSOR"
            ok "Tema aplicado via xfconf-query (XFCE)"
            warn "xfwm4 (bordas de janela) usa catálogo próprio de temas — confira em Configurações > Gerenciador de Janelas"
            ;;
        *)
            warn "Interface gráfica '$XDG_CURRENT_DESKTOP' não reconhecida — pulei a aplicação automática de tema."
            ;;
    esac
}

# --- 15. Flatpak (Zen Browser sempre + Kodi/RetroArch no perfil server) ---
FLATPAK_APPS=(
    app.zen_browser.zen
)
FLATPAK_APPS_SERVER=(
    org.libretro.RetroArch
    tv.kodi.Kodi
)

install_flatpak() {
    log "INSTALANDO FLATPAK + ZEN BROWSER"
    sudo pacman -S --needed --noconfirm flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y flathub "${FLATPAK_APPS[@]}"
    ok "Flatpak + Zen Browser instalados!!"
}

install_flatpak_server_apps() {
    log "INSTALANDO KODI + RETROARCH (FLATPAK)"
    sudo flatpak install -y flathub "${FLATPAK_APPS_SERVER[@]}"
    ok "Kodi + RetroArch instalados!!"
}

# --- 16. SSH (perfil server) ---
install_ssh() {
    log "INSTALANDO E HABILITANDO SSH"
    sudo pacman -S --needed --noconfirm openssh
    sudo systemctl enable --now sshd
    ok "SSH habilitado (sshd rodando)!!"
}

# --- 17. Podman (perfil server) ---
install_podman() {
    log "INSTALANDO PODMAN"
    sudo pacman -S --needed --noconfirm podman podman-compose
    ok "Podman instalado!!"
}

# --- 18. Aplicar configurações (symlinks) ---
apply_config() {
    local src="$1"
    local desc="$2"
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    log "APLICANDO $desc (Links Simbólicos)"

    # Backup dos dotfiles existentes
    mkdir -p "$backup_dir"
    [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$backup_dir/.bashrc" 2>/dev/null
    ok "Backup em $backup_dir"

    if [ -f "$src/bash/bashrc" ]; then
        ln -sf "$src/bash/bashrc" "$HOME/.bashrc"
        ok "Link: ~/.bashrc -> $src/bash/bashrc"
    fi

    mkdir -p "$HOME/.config"
    for app_path in "$src"/*/; do
        [ -d "$app_path" ] || continue
        local app
        app=$(basename "$app_path")
        [[ "$app" =~ ^(bash|themes|icons)$ ]] && continue
        # Backup do config existente antes de sobrescrever
        [ -e "$HOME/.config/$app" ] && cp -r "$HOME/.config/$app" "$backup_dir/" 2>/dev/null
        rm -rf "$HOME/.config/$app"
        ln -sf "$app_path" "$HOME/.config/$app"
        ok "Link: ~/.config/$app -> $app_path"
    done

    if [ -d "$src/themes" ]; then
        mkdir -p "$HOME/.themes"
        for theme in "$src/themes"/*; do
            [ -e "$theme" ] || continue
            ln -sf "$theme" "$HOME/.themes/"
            ok "Tema: $(basename "$theme")"
        done
    fi

    if [ -d "$src/icons" ]; then
        mkdir -p "$HOME/.icons" "$HOME/.local/share/icons"
        for icon in "$src/icons"/*; do
            [ -e "$icon" ] || continue
            ln -sf "$icon" "$HOME/.icons/"
            ln -sf "$icon" "$HOME/.local/share/icons/"
            ok "Ícone: $(basename "$icon")"
        done
    fi
}

# --- Setup completo ---
setup_system() {
    if [ ! -f /etc/arch-release ]; then
        warn "Este script é otimizado para Arch Linux."
        read -r -p "Continuar mesmo assim? [s/N] " resp
        [[ "$resp" =~ ^[Ss]$ ]] || { echo "Abortando."; exit 1; }
    fi

    local profile="$1"
    if [[ -z "$profile" ]]; then
        echo
        echo "Tipo de instalação:"
        PS3="Escolha [1-2]: "
        select opt in \
            "Normal (desktop completo)" \
            "Server (TV box: tudo do normal + SSH + Podman + Kodi/RetroArch)"; do
            case "$REPLY" in
                1) profile="normal"; break ;;
                2) profile="server"; break ;;
                *) echo "Opção inválida." ;;
            esac
        done
    fi

    log "AUTENTICANDO SUDO"
    sudo -v || { err "Senha de sudo incorreta ou indisponível."; exit 1; }
    ok "Sudo autenticado — não deve pedir senha de novo durante a instalação"

    configure_pacman           # Color, ILoveCandy, ParallelDownloads=10
    configure_makepkg          # desativa pacote de debug (builds AUR mais rápidos)
    install_paru               # AUR helper (Rust)
    install_system_packages    # pacman: gh, starship, eza, bat, zoxide, fzf, btop, timeshift...
    install_aur_packages       # paru: brave, vscode, wezterm
    install_node               # nvm → Node LTS
    install_pyenv              # pyenv
    install_bun                # bun
    install_rust               # rustup
    setup_gh                   # gh auth login
    install_claude             # npm → claude
    install_claude_plugins     # claude-mem, context-mode, RTK
    install_ombash             # oh-my-bash
    install_fonts              # Nerd Fonts
    install_theming_packages   # paru: ícones/cursor (McMojave, WhiteSur, Fluent, apple_cursor...)
    apply_theme                # gsettings (GNOME) ou xfconf-query (XFCE), conforme detectado
    install_flatpak            # flatpak + flathub + Zen Browser (sempre)
    apply_config "$BASE_CONFIG" "CONFIGURAÇÕES"

    if [[ "$profile" == "server" ]]; then
        install_ssh                    # sshd habilitado
        install_podman                 # containers via Podman
        install_flatpak_server_apps    # Kodi + RetroArch
    fi

    log "Tudo pronto! Reinicie o terminal."
    log "Lembre-se de rodar: source ~/.bashrc"
}

# --- Menu ---
case "$1" in
    setup)    setup_system "$2" ;;
    gh)       setup_gh ;;
    claude)   install_claude && install_claude_plugins ;;
    fonts)    install_fonts ;;
    theme)    install_theming_packages && apply_theme ;;
    makepkg)  configure_makepkg ;;
    flatpak)  install_flatpak ;;
    ssh)      install_ssh ;;
    podman)   install_podman ;;
    config)   apply_config "$BASE_CONFIG" "CONFIGURAÇÕES" ;;
    mirrors)  setup_mirrors ;;
    *)
        echo "Uso: $0 {setup [normal|server]|gh|claude|fonts|theme|makepkg|flatpak|ssh|podman|config|mirrors}"
        echo ""
        echo "  setup [normal|server] - Instalação completa (pede pra escolher o perfil se omitido)"
        echo "  gh       - Configura GitHub CLI"
        echo "  claude   - Instala Claude Code + plugins globais"
        echo "  fonts    - Instala Nerd Fonts"
        echo "  theme    - Instala ícones/cursor (AUR) e aplica (GNOME/XFCE)"
        echo "  makepkg  - Desativa pacote de debug do makepkg (builds AUR mais rápidos)"
        echo "  flatpak  - Instala Flatpak + Zen Browser"
        echo "  ssh      - Instala e habilita SSH (perfil server)"
        echo "  podman   - Instala Podman (perfil server)"
        echo "  config   - Aplica symlinks das configs"
        echo "  mirrors  - Atualiza mirrorlist via reflector"
        ;;
esac
