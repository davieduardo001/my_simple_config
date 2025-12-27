#!/bin/bash
#
# This script installs the Alacritty terminal emulator on various Linux distributions.
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

# --- Alacritty Installation ---
install_alacritty() {
    info "Starting Alacritty terminal installation..."

    if command -v alacritty &> /dev/null; then
        info "Alacritty is already installed. Skipping installation."
        return
    fi

    local distro
    distro=$(get_distro)

    info "Detected distribution type: $distro"

    case "$distro" in
        "debian")
            action_required "Using APT for installation."
            sudo apt-get update
            sudo apt-get install -y alacritty || error "Failed to install Alacritty."
            ;;
        "fedora")
            action_required "Using DNF for installation."
            sudo dnf install -y alacritty || error "Failed to install Alacritty."
            ;;
        "arch")
            action_required "Using Pacman for installation."
            sudo pacman -S --noconfirm alacritty || error "Failed to install Alacritty."
            ;;
        *)
            warn "Unsupported distribution for package manager installation."
            warn "Please install Alacritty manually."
            ;;
    esac
    info "Alacritty installed successfully."
}

# --- Main Execution ---
install_alacritty

# Make the script executable
chmod +x "$0"
