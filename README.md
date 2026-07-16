# dotfiles — Arch Linux Dev Environment

Automated setup for an Arch Linux development environment using **Ansible**.  
One playbook installs everything and wires up all dotfiles via symlinks.

## Stack

| Category | Tool |
|---|---|
| Shell | Bash + Oh-My-Bash |
| Prompt | Starship |
| Terminal | Ghostty |
| Browser | Brave (AUR) + Zen Browser (Flatpak) |
| Editor | VS Code |
| System info | fastfetch |
| CLI tools | eza, bat, zoxide, fzf, btop |
| Fonts | CaskaydiaCove & JetBrainsMono Nerd Fonts |
| Icon/cursor theme | McMojave-circle + macOS cursor (AUR, applied via gsettings/xfconf-query) |
| Runtimes | Node (NVM), Python (pyenv), Bun, Rust (rustup) |
| AUR helper | paru |
| Launcher | Rofi, Spotlight-style theme (AUR), `Super+Space` |
| Containers *(server profile)* | Podman + podman-compose |
| Media *(server profile)* | Kodi + RetroArch (Flatpak) |
| Remote access *(server profile)* | OpenSSH (sshd enabled) |

## Requirements

- A fresh Arch Linux install (the pre-task validates this) with a `sudo`-capable user
- Everything else (paru, packages, runtimes, fonts, theming...) is installed by the playbook itself — you only need `git` + `ansible` + `python-jmespath` to get it started

## Install

Copy-paste on a fresh Arch install:

```bash
# 1. Bootstrap: only what's needed to run the playbook
sudo pacman -Sy --needed git ansible python-jmespath

# 2. Clone this repo
git clone <this-repo> ~/dotfiles
cd ~/dotfiles/ansible

# 3. Run the full setup (asks for your sudo password once)
ansible-playbook site.yml --ask-become-pass
```

## Install profiles

Every install (both the playbook and `script.sh`) asks which profile to set up:

- **normal** — full dev desktop: dotfiles, dev tooling, GUI apps, icon/cursor/GTK theming, Flatpak + Zen Browser.
- **server** — everything in `normal`, **plus** OpenSSH (sshd enabled), Podman + podman-compose, and Kodi + RetroArch via Flatpak. Meant for a living-room TV box / HTPC you reach over SSH — `server` is a superset of `normal`, not a stripped-down version.

```bash
# Ansible: prompts interactively (1=normal, 2=server)
ansible-playbook site.yml --ask-become-pass

# Ansible: skip the prompt, force a profile non-interactively
ansible-playbook site.yml --ask-become-pass -e install_profile_choice=2

# script.sh: prompts interactively if the profile is omitted
./script.sh setup

# script.sh: skip the prompt
./script.sh setup server
```

Add more Flatpak apps by editing `flatpak_apps` (both profiles) or `flatpak_apps_server` (server only) in `ansible/group_vars/all.yml` (and the matching `FLATPAK_APPS` / `FLATPAK_APPS_SERVER` arrays in `script.sh`).

## Usage

Re-run the playbook any time — every role is idempotent (`--needed` on pacman/paru, symlinks, etc.):

```bash
# Only dotfiles (symlinks)
ansible-playbook site.yml --ask-become-pass --tags dotfiles

# Only icon/cursor/GTK theming
ansible-playbook site.yml --ask-become-pass --tags theming

# Only the server-profile extras (SSH, Podman) — still needs -e install_profile_choice=2
ansible-playbook site.yml --ask-become-pass --tags server -e install_profile_choice=2

# Skip interactive steps (gh auth, claude)
ansible-playbook site.yml --ask-become-pass --skip-tags interactive
```

> **Note:** `gh auth login` is interactive and cannot be automated — the playbook will print a reminder if you're not authenticated yet.

> **Note:** icon/cursor/GTK theming is applied automatically on both GNOME and XFCE — the `theming` role detects the desktop via `XDG_CURRENT_DESKTOP` and uses `gsettings` or `xfconf-query` accordingly.

> **Note:** Rofi's `Super+Space` shortcut is applied the same way (GNOME/XFCE detection). On GNOME this combo is the *default* binding for `switch-input-source` (keyboard layout switcher) — the `rofi` role/function clears that binding automatically **only if** it's still set to `Super+Space`, and only then. On XFCE there's no known default on that combo, but it's worth checking after applying.

> **Note:** the `vars_prompt` profile question always shows up, even when passing `-e install_profile_choice=...` — Ansible has no built-in way to skip a prompt when an extra-var is already set. The typed answer is simply overridden by the extra-var afterwards, so non-interactive automation still works, it's just not silent.

## Structure

```
ansible/
├── ansible.cfg           # Ansible configuration
├── inventory/
│   └── hosts.yml         # Localhost connection
├── group_vars/
│   └── all.yml           # Package lists and versions (single source of truth)
├── site.yml              # Main playbook
└── roles/
    ├── mirrors/          # Update mirrorlist via reflector
    ├── pacman/           # Color, ILoveCandy, ParallelDownloads
    ├── paru/             # AUR helper (Rust)
    ├── packages/         # pacman packages
    ├── aur_packages/     # AUR packages via paru
    ├── node/             # NVM + Node LTS
    ├── pyenv/            # Python version manager
    ├── bun/              # Bun runtime
    ├── rust/             # Rust via rustup
    ├── oh_my_bash/       # Oh-My-Bash framework
    ├── makepkg/          # Disables makepkg debug-package generation (faster AUR builds)
    ├── fonts/            # CaskaydiaCove + JetBrainsMono Nerd Fonts
    ├── theming/          # Icons/cursor (AUR) + applies via gsettings (GNOME) or xfconf-query (XFCE)
    ├── rofi/             # Rofi + Spotlight theme (AUR) + Super+Space shortcut (GNOME/XFCE)
    ├── flatpak/          # Flatpak + Flathub remote + Zen Browser (Kodi/RetroArch on server profile)
    ├── ssh/              # OpenSSH, sshd enabled (server profile only)
    ├── podman/           # Podman + podman-compose (server profile only)
    ├── dotfiles/         # Symlinks: .bashrc, fastfetch, ghostty, rofi
    ├── github_cli/       # gh auth status check
    └── claude/           # Claude Code CLI + RTK

base_config/              # Source of truth for dotfiles
├── bash/bashrc
├── fastfetch/config.jsonc
├── ghostty/config
└── rofi/config.rasi
```

## Customization

Edit `ansible/group_vars/all.yml` to change package lists or tool versions.  
Edit files in `base_config/` to change shell, terminal, or fastfetch configs.
