#!/bin/bash
#
# This script installs VSCodium, a community-driven, freely-licensed binary
# distribution of VS Code, on various Linux distributions.
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


# --- VSCodium Installation ---
install_vscodium() {
    info "Starting VSCodium installation..."

    if command -v codium &> /dev/null; then
        info "VSCodium is already installed. Skipping installation."
        return
    fi

    local distro
    distro=$(get_distro)

    info "Detected distribution type: $distro"

    case "$distro" in
        "debian")
            info "Using APT for installation."
            local URL="https://github.com/VSCodium/vscodium/releases/download/1.106.37943/codium_1.106.37943_amd64.deb"
            local FILE="/tmp/VSCodium.deb"
            trap 'rm -f "$FILE"' EXIT
            
            info "Downloading .deb package..."
            if curl -fL -o "$FILE" "$URL"; then
                info "Download complete. Installing..."
                sudo apt-get update
                sudo apt-get install -y "$FILE" || error "Failed to install .deb package."
                info "VSCodium installed successfully."
            else
                error "Failed to download VSCodium .deb package."
            fi
            ;;
            
        "fedora")
            info "Using DNF for installation."
            info "Importing GPG key..."
            sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg || error "Failed to import GPG key."
            
            info "Adding VSCodium repository..."
            printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee /etc/yum.repos.d/vscodium.repo > /dev/null
            
            info "Installing VSCodium..."
            sudo dnf install -y codium || error "Failed to install VSCodium with DNF."
            info "VSCodium installed successfully."
            ;;
            
        "arch")
            info "Using AUR for installation."
            if ! command -v yay &> /dev/null; then
                error "AUR helper 'yay' not found. Please install it first to proceed with VSCodium installation on Arch Linux."
            fi
            
            info "Installing 'vscodium-bin' with yay..."
            yay -S --noconfirm vscodium-bin || error "Failed to install VSCodium with yay."
            info "VSCodium installed successfully."
            ;;
            
        *)
            error "Unsupported distribution. Cannot install VSCodium automatically. Please install it manually."
            ;;
    esac
}

# --- Main Execution ---
install_vscodium

# Make the script executable
chmod +x "$0"
