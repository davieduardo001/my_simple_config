# My Linux Dotfiles Setup

This project contains a set of scripts to automate the setup of a personalized Linux environment. It is designed to be OS-agnostic, supporting Debian-based (like Ubuntu), Fedora-based, and Arch-based distributions.

## ✨ Features

- **OS-Agnostic Installation:** Automatically detects the Linux distribution and uses the appropriate package manager (`apt`, `dnf`, `pacman`) to install software.
- **Automated Software Installation:**
  - **Zsh Shell:** Installs the Zsh binary.
  - **Oh My Zsh:** Installs the popular framework for managing Zsh configuration.
  - **NVM & Node.js:** Installs Node Version Manager (NVM) to manage and install the latest LTS version of Node.js.
  - **Google Gemini CLI:** Installs the command-line interface for interacting with Google's Gemini models.
  - **VSCodium:** Installs the community-driven, freely-licensed binary distribution of VS Code.
  - **Nerd Fonts:** Installs BlexMono, CaskaydiaCove, and FiraCode Nerd Fonts for a great terminal experience.
- **Configuration Deployment:** Automatically symlinks the configuration files for Kitty and Zsh.
- **Aesthetic CLI Output:** Provides stylish, emoji-enhanced feedback during the installation process.
- **Interactive Setup:** Asks for user confirmation before making critical changes, like setting the default shell.

## 🚀 Usage

To set up your environment, simply run the main script:

```bash
./script.sh
```

The script will guide you through the process, installing the necessary software and deploying the configuration files.

## 📂 Project Structure

- `script.sh`: The main entry point for the setup process.
- `src/config/`: Contains all the configuration files that will be deployed.
  - `zshrc`: Configuration for the Zsh shell, designed to work with Oh My Zsh.
  - `my_vscod_profile.code-profile`: A profile for VSCodium.
- `src/scripts/`: Contains the individual, OS-agnostic installation scripts for each piece of software.
- `src/wallpapers/`: Contains wallpapers for the desktop environment. (Note: The script does not automatically set the wallpaper.)

## 🔧 Customization

You can easily customize this setup to fit your needs:

- **Add New Software:** Create a new installation script in `src/scripts/` and add a call to it in the main `script.sh`.
- **Change Configurations:** Simply edit the files in the `src/config/` directory. The next time you run the script, your changes will be applied.
- **Add New Fonts:** Create a new font installation script in `src/scripts/` modeled after the existing ones.
