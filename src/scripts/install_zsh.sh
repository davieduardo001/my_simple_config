#!/bin/bash
#
# This script installs the Zsh shell on various Linux distributions.
#
set -e

# Define colors
if [[ -t 1 ]]; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RESET=$(tput sgr0)
else
    RED=""
    GREEN=""
    YELLOW=""
    RESET=""
fi

# --- Helper Functions ---
info() { echo "${GREEN}[INFO]${RESET} $1"; }
warn() { echo "${YELLOW}[WARN]${RESET} $1"; }
error() { echo "${RED}[ERROR]${RESET} $1" >&2; exit 1; }

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

# --- Zsh Installation ---
install_zsh() {
    info "Starting Zsh installation..."

    if command -v zsh &> /dev/null; then
        info "Zsh is already installed. Skipping installation."
        return
    fi

    local distro
    distro=$(get_distro)

    info "Detected distribution type: $distro"

    case "$distro" in
        "debian")
            info "Using APT for installation."
            sudo apt-get update
            sudo apt-get install -y zsh || error "Failed to install Zsh."
            ;;
        "fedora")
            info "Using DNF for installation."
            sudo dnf install -y zsh || error "Failed to install Zsh."
            ;;
        "arch")
            info "Using Pacman for installation."
            sudo pacman -S --noconfirm zsh || error "Failed to install Zsh."
            ;;
        *)
            error "Unsupported distribution: $OS. Cannot install Zsh automatically. Please install it manually."
            ;;
    esac
    info "Zsh installed successfully."
}

# --- Main Execution ---
install_zsh

# Make the script executable
chmod +x "$0"
