#!/bin/bash
#
# This script installs Neovim, a hyperextensible Vim-based text editor,
# on various Linux distributions.
#
set -e

# Define colors
if [[ -t 1 ]]; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
else
    RED=""
    GREEN=""
    YELLOW=""
    CYAN=""
    RESET=""
fi

# --- Helper Functions ---
info() { echo "✨ ${GREEN}[INFO]${RESET} $1"; }
warn() { echo "⚠️  ${YELLOW}[WARN]${RESET} $1"; }
error() { echo "❌ ${RED}[ERROR]${RESET} $1" >&2; exit 1; }
action_required() { echo "🚀 ${CYAN}[ACTION]${RESET} $1"; }

# --- OS Detection ---
get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint)
                echo "debian"
                ;;
            fedora)
                echo "fedora"
                ;;
            arch)
                echo "arch"
                ;;
            *)
                # If ID is not matched, check ID_LIKE
                if [ -n "$ID_LIKE" ]; then
                    case "$ID_LIKE" in
                        *debian*) echo "debian" ;; 
                        *fedora*) echo "fedora" ;; 
                        *arch*)   echo "arch"   ;; 
                        *)        echo "unknown" ;; 
                    esac
                else
                    echo "unknown"
                fi
                ;;
        esac
    else
        echo "unknown"
    fi
}

# --- Neovim Installation ---
install_neovim() {
    info "Starting Neovim installation..."

    if command -v nvim &> /dev/null; then
        info "Neovim is already installed. Skipping installation."
        return
    fi

    local distro
    distro=$(get_distro)

    info "Detected distribution type: $distro"

    case "$distro" in
        "debian")
            action_required "Using APT with PPA for installation."
            
            info "Updating package lists and installing dependencies..."
            sudo apt-get update || error "Failed to update package lists."
            sudo apt-get install -y software-properties-common || error "Failed to install software-properties-common."
            
            info "Adding Neovim PPA..."
            sudo add-apt-repository ppa:neovim-ppa/unstable -y || error "Failed to add Neovim PPA."
            
            info "Installing Neovim..."
            sudo apt-get update || error "Failed to update package lists."
            sudo apt-get install -y neovim || error "Failed to install Neovim."
            info "Neovim installed successfully."
            ;;
            
        "fedora")
            action_required "Using DNF for installation."
            info "Installing Neovim..."
            sudo dnf install -y neovim || error "Failed to install Neovim with DNF."
            info "Neovim installed successfully."
            ;;
            
        "arch")
            action_required "Using Pacman for installation."
            info "Installing Neovim..."
            sudo pacman -S --noconfirm neovim || error "Failed to install Neovim with Pacman."
            info "Neovim installed successfully."
            ;;
            
        *)
            warn "Unsupported distribution for native package installation."
            action_required "Attempting to install with Snap or Flatpak..."
            if command -v snap &> /dev/null; then
                info "Using Snap to install Neovim..."
                sudo snap install nvim --classic || error "Failed to install Neovim via Snap."
                info "Neovim installed successfully via Snap."
            elif command -v flatpak &> /dev/null; then
                info "Using Flatpak to install Neovim..."
                flatpak install flathub io.neovim.nvim -y || error "Failed to install Neovim via Flatpak."
                info "Neovim installed successfully via Flatpak."
            else
                error "Unsupported distribution and Snap/Flatpak not found. Please install Neovim manually."
            fi
            ;;
    esac
}

# --- Main Execution ---
install_neovim

# Make the script executable
chmod +x "$0"
