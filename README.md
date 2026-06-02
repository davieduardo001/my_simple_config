# dotfiles — Arch Linux Dev Environment

Automated setup for an Arch Linux development environment using **Ansible**.  
One playbook installs everything and wires up all dotfiles via symlinks.

## Stack

| Category | Tool |
|---|---|
| Shell | Bash + Oh-My-Bash |
| Prompt | Starship |
| Terminal | Ghostty |
| Browser | Brave |
| Editor | VS Code |
| System info | fastfetch |
| CLI tools | eza, bat, zoxide, fzf, btop |
| Fonts | CaskaydiaCove & JetBrainsMono Nerd Fonts |
| Runtimes | Node (NVM), Python (pyenv), Bun, Rust (rustup) |
| AUR helper | paru |

## Requirements

- Arch Linux (the pre-task validates this)
- `ansible` installed: `sudo pacman -S ansible`
- `python-jmespath` for some filters: `sudo pacman -S python-jmespath`

## Usage

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles/ansible

# Full setup
ansible-playbook site.yml --ask-become-pass

# Only dotfiles (symlinks)
ansible-playbook site.yml --ask-become-pass --tags dotfiles

# Skip interactive steps (gh auth, claude)
ansible-playbook site.yml --ask-become-pass --skip-tags interactive
```

> **Note:** `gh auth login` is interactive and cannot be automated — the playbook will print a reminder if you're not authenticated yet.

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
    ├── fonts/            # CaskaydiaCove + JetBrainsMono Nerd Fonts
    ├── dotfiles/         # Symlinks: .bashrc, fastfetch, ghostty
    ├── github_cli/       # gh auth status check
    └── claude/           # Claude Code CLI + RTK

base_config/              # Source of truth for dotfiles
├── bash/bashrc
├── fastfetch/config.jsonc
└── ghostty/config
```

## Customization

Edit `ansible/group_vars/all.yml` to change package lists or tool versions.  
Edit files in `base_config/` to change shell, terminal, or fastfetch configs.
