# Environment Setup Documentation

This repository contains an automated environment setup for Arch Linux and Fedora systems.

## Workflow Overview

The setup process is orchestrated by `script.sh`, which follows these steps:

1.  **Homebrew Check**: Verifies if **Homebrew** is installed and installs it if missing.
2.  **OS Detection & Base Packages**: Detects if the system is running **Arch Linux** or **Fedora** and installs base tools like `git`, `curl`, `wget`, `unzip`, and `flatpak`.
3.  **Flatpak Installation**: Installs **Contour Terminal Emulator** and **Brave Browser** via Flathub (ensuring an "immutable" setup feeling).
4.  **Homebrew Packages**: Installs **NVM** via Homebrew for Node.js version management.
6.  **Oh-My-Bash**: Installs the framework for an enhanced shell.
7.  **Fonts**: Installs CaskaydiaCove and JetBrainsMono Nerd Fonts.
8.  **Configuration Deployment**: Deploys base configurations from `base_config/` (Contour, bashrc, neofetch) to the user's home directory via symbolic links.

## Installation

To install and configure your system, run:

```bash
chmod +x script.sh
./script.sh setup
```

## Key Files & Directories

*   `script.sh`: The main installation script.
*   `base_config/`: The source of truth for your configuration files (bashrc, neofetch, contour, etc.).
*   `wallpapers/`: A collection of wallpapers.

## Customization

To customize your configurations, modify the files within the `base_config/` directory.
