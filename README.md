# KEVINNITRO DOTFILES

[![GitHub last commit (by committer)](https://img.shields.io/github/last-commit/KevinNitroG/dotfiles?style=for-the-badge&color=FAB387)](../../commits/main)
![GitHub repo size](https://img.shields.io/github/repo-size/KevinNitroG/dotfiles?style=for-the-badge&color=B4BEFE)

Dotfiles managed with [chezmoi](https://www.chezmoi.io/):

- Windows
- Arch linux _([hyprdots](https://github.com/prasanthrangan/hyprdots/))_

> [!NOTE]
> Haven't enough money to buy Mac yet

> [!WARNING]
> This is for personal use, as it contains encrypted files.
>
> If you wish to use it, run chezmoi apply with the `--exclude=encrypted` argument.

---

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [😎 Showcase](#-showcase)
  - [Terminal](#terminal)
  - [Neovim](#neovim)
- [📝 Installation](#-installation)
- [💁 References](#-references)
  - [Wallpaper](#wallpaper)
  - [Other dotfiles](#other-dotfiles)
    - [Preconfig](#preconfig)
    - [Chezmoi](#chezmoi)
    - [Others](#others)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

---

## 😎 Showcase

### Terminal

| **Linux**                                             | **Windows**                                               |
| ----------------------------------------------------- | --------------------------------------------------------- |
| ![Linux terminal](./assets/images/linux/terminal.png) | ![Windows terminal](./assets/images/windows/terminal.png) |

### Neovim

| **Linux**                                         | **Windows**                                           |
| ------------------------------------------------- | ----------------------------------------------------- |
| ![Linux Neovim](./assets/images/linux/neovim.png) | ![Windows Neovim](./assets/images/windows/neovim.png) |

> [!NOTE]
> Neovim config <https://github.com/KevinNitroG/nvim>

---

## 📝 Installation

- Add ssh key
  - Linux
    ```sh
    eval "$(ssh-agent -s)"
    chmod 700 ~/.ssh/
    chmod 644 ~/.ssh/id_ed25519.pub
    chmod 600 ~/.ssh/id_ed25519
    ssh-add ~/.ssh/id_ed25519
    ```
  - Windows
    ```powershell
    Set-Service ssh-agent -StartupType Automatic
    Start-Service ssh-agent
    Ssh-Add "$env:USERPROFILE/.ssh/id_ed25519"
    ```
- Create `~/.age-key.txt` _(for encrypt/decrypt)_
- Install chezmoi and init, apply, and delete binary: _([docs](https://www.chezmoi.io/install))_
  - shell
    ```sh
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --ssh --purge-binary KevinNitroG
    ```
  - pwsh
    ```powershell
    iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply --ssh --purge-binary KevinNitroG"
    ```
- GPG for sign commit
  ```sh
  gpg --import public.gpg
  gpg --import secret.gpg
  gpg --edit-key KevinNitroG
  trust
  5
  y
  quit
  ```
  > On windows use GPG from git. We can open `git bash`

> - [Windows](./docs/windows.md)
> - [Linux](./docs/linux.md)

---

## 💁 References

### Wallpaper

- <https://github.com/D3Ext/aesthetic-wallpapers>
- <https://github.com/DenverCoder1/minimalistic-wallpaper-collection>
- <https://github.com/Gingeh/wallpapers>

### Other dotfiles

#### Preconfig

- <https://github.com/JaKooLit/Hyprland-Dots>
- <https://github.com/end-4/dots-hyprland>
- <https://github.com/gh0stzk/dotfiles> (BSPWM)
- <https://github.com/koeqaife/hyprland-material-you>
- <https://github.com/prasanthrangan/hyprdots>
- <https://gitlab.com/stephan-raabe/dotfiles>

#### Chezmoi

- <https://github.com/megabyte-labs/install.doctor>
- <https://github.com/lildude/dotfiles/> (Have config for codespace)

#### Others

- <https://github.com/2KAbhishek/dots2k>
- <https://github.com/2nthony/dotfiles> (Lazygit?)
- <https://github.com/Alexis12119/dotfiles>
- <https://github.com/Cybersnake223/Hypr>
- <https://github.com/Integralist/dotfiles>
- <https://github.com/JoosepAlviste/dotfiles>
- <https://github.com/asilvadesigns/config>
- <https://github.com/bahamas10/dotfiles> (YSAP)
- <https://github.com/chaneyzorn/dotfiles>
- <https://github.com/craftzdog/dotfiles-public>
- <https://github.com/dlvhdr/dotfiles>
- <https://github.com/dreamsofautonomy/zensh>
- <https://github.com/linkarzu/dotfiles-latest>
- <https://github.com/mischavandenburg/dotfiles>
- <https://github.com/nguyenvukhang/docker-dev>
- <https://github.com/nguyenvukhang/dots> (git config!)
- <https://github.com/omerxx/dotfiles> (have good tmux plugins)
- <https://github.com/p3nguin-kun/dotfiles>
- <https://github.com/petobens/dotfiles> (X config, tmux for linux & mac)
- <https://github.com/rusty-electron/dotfiles>
- <https://github.com/siduck/dotfiles>
- <https://github.com/stevearc/dotfiles>
- <https://github.com/wincent/wincent> (Old dotfiles 😱)
