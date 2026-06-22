# Dotfiles

Personal configuration files for Omarchy Linux, managed in mirror mode.

The repository structure mirrors the home directory (`~/`), making it easy to back up, track changes with Git, and restore configurations on a fresh installation.

> [!WARNING]  
> This setup is tailored to my personal workflow and system. Use it at your own risk. Always review the installation script and configuration files before applying them to your machine.

## 🛠️ Included Configurations

- **Hyprland** — Wayland compositor and window manager
- **Waybar** — Status bar with custom modules and scripts
- **Fastfetch** — System information display
- **Starship** — Shell prompt configuration

## 📋 Requirements

Install the required packages before applying the configuration:

```bash
sudo pacman -Syu playerctl wireguard-tools openresolv copyq
yay -S zscroll-git walker-bin
```

These packages are used by Waybar modules and various desktop utilities included in the configuration.

## 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/adrian-lis/dotfiles.git ~/dotfiles
```

Run the installation script:

```bash
cd ~/dotfiles
./install.sh
```

> [!WARNING]  
> The installation script will overwrite existing files in your home directory. Backup copies are created automatically before any file is replaced.

## 🛡️ Backup & Safety

Before replacing a file, the installer creates a backup with the `.bak` extension.

Example:

```text
~/.bashrc -> ~/.bashrc.bak
```

If the installer is run again, the backup will be updated with the latest version of the replaced file.

## 📂 Repository Layout

```bash
dotfiles/
├── .config/   # Core configuration files (deployed to ~/.config)
├── .git/      # Git metadata [Ignored by script]
├── .gitignore # Rules for untracked files [Ignored by script]
├── install.sh # Automation setup script [Ignored by script]
├── LICENSE    # Project license [Ignored by script]
└── README.md  # Documentation guide [Ignored by script]
```

The structure mirrors the home directory, allowing files to be deployed directly to their target locations.

## 💡 Notes

- Review the installation script and configuration files before running them on a new system.
- Existing configuration files may be overwritten.
- Designed for Arch Linux and Arch-based distributions.
- Tested primarily on Omarchy.
- Feel free to adapt any configuration to your own setup.
