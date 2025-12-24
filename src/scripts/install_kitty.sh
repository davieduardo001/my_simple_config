#!/bin/bash
#
# This script installs the kitty terminal emulator on various Linux distributions.
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

# --- kitty Installation ---
install_kitty() {
    info "Starting kitty terminal installation..."

    if command -v kitty &> /dev/null; then
        info "kitty is already installed. Skipping installation."
        return
    fi

    local distro
    distro=$(get_distro)

    info "Detected distribution type: $distro"

    case "$distro" in
        "debian")
            info "Using APT for installation."
            sudo apt-get update
            sudo apt-get install -y kitty || error "Failed to install kitty."
            ;;
        "fedora")
            info "Using DNF for installation."
            sudo dnf install -y kitty || error "Failed to install kitty."
            ;;
        "arch")
            info "Using Pacman for installation."
            sudo pacman -S --noconfirm kitty || error "Failed to install kitty."
            ;;
        *)
            warn "Unsupported distribution. Falling back to official binary installer."
            curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
            warn "You may need to add kitty to your PATH manually."
            ;;
    esac
    info "kitty installed successfully."
}

# --- Main Execution ---
install_kitty

# Make the script executable
chmod +x "$0"