<h1 align=center>
  KEVINNITRO DOTFILES
</h1>

<div align=center>
  <a href="../../commits/main">
    <img alt="Last commit" src="https://img.shields.io/github/last-commit/KevinNitroG/dotfiles?style=for-the-badge&color=f2cdcd&labelColor=363a4f"/>
  </a>
  <img alt="Repo size" src="https://img.shields.io/github/repo-size/KevinNitroG/dotfiles?style=for-the-badge&color=eba0ac&labelColor=363a4f"/>
  <a href="https://www.chezmoi.io/">
    <img alt="Chezmoi" src="https://img.shields.io/badge/chezmoi-fab387?style=for-the-badge"/>
  </a>
  <a href="https://github.com/HyDE-Project/HyDE">
    <img alt="HyDE" src="https://img.shields.io/badge/Hyde-cba6f7?style=for-the-badge"/>
  </a>
</div>

<div align=center>
  <img alt="Arch" src="https://img.shields.io/badge/Arch-89b4fa?logo=arch-linux&logoColor=white&style=for-the-badge"/>
  <img alt="EndeavourOS" src="https://img.shields.io/badge/endeavour%20os-b4befe?logo=endeavouros&logoColor=white&style=for-the-badge"/>
  <img alt="CachyOS" src="https://img.shields.io/badge/cachy%20os-00AA88?logo=cachyos&logoColor=white&style=for-the-badge"/>
  <img alt="Ubuntu" src="https://img.shields.io/badge/Ubuntu-fab387?logo=ubuntu&logoColor=white&style=for-the-badge"/>
  <img alt="Windows" src="https://img.shields.io/badge/Windows-74c7ec?style=for-the-badge&logo=windows&logoColor=white"/>
  <img alt="WSL" src="https://img.shields.io/badge/WSL-a6e3a1?logo=linux&logoColor=black&style=for-the-badge"/>
</div>

<div align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</div>

---

## ToC

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [😎 Showcase](#-showcase)
  - [Terminal](#terminal)
  - [Neovim](#neovim)
- [🧩 How it is organised](#-how-it-is-organised)
- [⚙️ Installation](#-installation)
  - [0. Prerequisites per platform](#0-prerequisites-per-platform)
  - [1. SSH key](#1-ssh-key)
  - [2. age key](#2-age-key)
  - [3. GitHub API rate limits](#3-github-api-rate-limits)
  - [4. Install chezmoi and apply](#4-install-chezmoi-and-apply)
  - [5. Commit signing](#5-commit-signing)
- [Manually add/sync encrypted file to template](#manually-addsync-encrypted-file-to-template)
- [📝 Other notes](#-other-notes)
- [💁 References](#-references)
  - [Wallpaper](#wallpaper)
  - [Other dotfiles](#other-dotfiles)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

---

## 😎 Showcase

### Terminal

| **Linux**                                                                                          | **Windows**                                                                                          |
| -------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| ![linux_terminal](https://github.com/user-attachments/assets/7f1d8bc3-8e39-4954-b3b2-bf677a577f34) | ![windows_terminal](https://github.com/user-attachments/assets/909fa526-38ee-48af-b397-bb420430bb62) |

### Neovim

![Neovim](https://github.com/user-attachments/assets/77cc3e3f-7b73-4b83-acc2-8b96faf81c3a)

> [!NOTE]
> Neovim config <https://github.com/uitdots/nvim>

---

## 🧩 How it is organised

`chezmoi init` asks a few questions; the answers decide what gets installed and
which files exist:

| value      | meaning                                                              |
| ---------- | -------------------------------------------------------------------- |
| `profiles` | identities this machine carries — `personal`, `personal,[company]`   |
| `osFamily` | `arch` / `ubuntu` / `fedora` / `windows` / `darwin` — picks installer |
| `isWsl`    | auto-detected                                                        |
| `isGui`    | auto-detected; false on WSL, containers, headless                    |
| `isLaptop` | auto-detected; adds power management                                 |

Identities live in `home/.chezmoidata/profiles.yml`, one block per profile —
see [docs/new-company.md](./docs/new-company.md).

Packages live in `home/.chezmoidata/pkgs/`, split `common` / `personal` /
`work` / `laptop`, each with `cli` (always) and `gui` (desktop only).
Full repo map: [AGENTS.md](./AGENTS.md).

---

## ⚙️ Installation

### 0. Prerequisites per platform

<details>
<summary><b>Windows</b></summary>

> [!IMPORTANT]
> Needs **administrator privileges**. Run from an elevated PowerShell and
> expect UAC prompts: `run_once_before_0_config-windows.ps1.tmpl` toggles
> Windows optional features (WSL, Virtual Machine Platform, .NET), and the
> Scoop/Choco bootstrap plus the `ssh-agent` service need it too.
> User `PATH` entries do not.

</details>

<details>
<summary><b>WSL</b></summary>

Install WSL from the [Microsoft Store](https://apps.microsoft.com/detail/9PDXGNCFSCZV),
then:

```powershell
wsl --install -d Ubuntu
wsl --set-default Ubuntu
```

Inside the guest, follow the Linux instructions. `isWsl` is auto-detected and
skips what makes no sense in a guest: terminal emulators, fonts, `fcitx5`,
Hyprland/HyDE/sddm/systemd desktop units, `kanata`, and the personal leisure
dotfiles (browser data, OBS, rclone, ncspot, …).

`~/.wslconfig` configures the VM, so it is applied on the **Windows host**, not
in the guest.

</details>

<details>
<summary><b>Linux</b></summary>

Arch-based (Arch, CachyOS, EndeavourOS), Ubuntu-based (Mint, Pop!\_OS) and
Fedora-based are supported; the installer is picked from `osFamily`. On Ubuntu,
`ppa:neovim-ppa/stable` is added so neovim is current. Anything apt lacks comes
from mise.

</details>

### 1. SSH key

One key per identity. Full guide: [docs/ssh.md](./docs/ssh.md).

- Linux / WSL / macOS
  ```sh
  eval "$(ssh-agent -s)"
  chmod 700 ~/.ssh/
  chmod 644 ~/.ssh/id_ed25519.pub
  chmod 600 ~/.ssh/id_ed25519
  ssh-add ~/.ssh/id_ed25519
  ```
- Windows _(elevated PowerShell)_
  ```powershell
  Set-Service ssh-agent -StartupType Automatic
  Start-Service ssh-agent
  ssh-add "$env:USERPROFILE/.ssh/id_ed25519"
  ```

### 2. age key

Encrypted files use [age](https://age-encryption.org/). One identity file per
profile under `~/.config/age/`, **never committed**:

| profile     | identity file                     |
| ----------- | --------------------------------- |
| `personal`  | `~/.config/age/key.txt`           |
| `<company>` | `~/.config/age/<company>-key.txt` |

Restore from Bitwarden, or generate:

```sh
mkdir -p ~/.config/age
age-keygen -o ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt
```

Every file is encrypted to **all** known recipients. `chezmoi init` only lists
identity files that exist, so adding a key later means re-running it.

> [!NOTE]
> This repo is personal and contains encrypted files you cannot decrypt. Apply
> with `--exclude=encrypted`.

### 3. GitHub API rate limits

chezmoi externals and mise both hammer the GitHub API on a first apply, and the
anonymous limit is **60/hour** — you will hit `API rate limit exceeded` and get
a half-installed machine. Export a token first (a classic PAT with no scopes is
enough; this is only about the rate limit):

```sh
export GITHUB_TOKEN='ghp_...'
```

Only matters for the first bootstrap — afterwards the token lives in the
encrypted `~/.config/zsh/private/personal.zsh`.

> [!TIP]
> `gh auth login && export GITHUB_TOKEN=$(gh auth token)` works too.

### 4. Install chezmoi and apply

_([docs](https://www.chezmoi.io/install))_

- shell
  ```sh
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --ssh --depth 1 --purge-binary KevinNitroG
  ```
- pwsh _(elevated — see the Windows note above)_
  ```powershell
  iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply --ssh --depth 1 --purge-binary KevinNitroG"
  ```

Pick `profiles` from the list — `personal`, or `personal` + `[company]` on a
work machine. To script it (`promptMultichoice` separates with `/`):

```sh
chezmoi init --promptDefaults --promptMultichoice profiles=personal/[company]
```

### 5. Commit signing

Per profile in `profiles.yml`: `personal` signs with **GPG**, companies with
their **SSH** key. Identity is picked by directory (`includeIf "gitdir:"`), so
work repos must live under the profile's `gitDir`.

GPG (personal):

```sh
gpg --import public.gpg
gpg --import secret.gpg
gpg --edit-key <key-id>
trust
5
y
quit
```

> On Windows use the GPG shipped with git — open `git bash`.

SSH signing needs only the key; `~/.ssh/allowed_signers` is generated. Verify
with `git log --show-signature -1`.

## Manually add/sync encrypted file to template

`chezmoi re-add` re-encrypts managed files, but not `home/.chezmoitemplates/`.
Use the helper for those:

```sh
chezmoi-encrypt-template.sh ~/.config/Code/User/settings.json VSCode/encrypted_settings.json
chezmoi-encrypt-template.sh ~/.config/rclone/rclone.conf rclone/encrypted_rclone.conf
```

It reads chezmoi's own recipients, so every file stays readable by every
profile. The raw equivalent:

```sh
age -a $(chezmoi data --format json | jq -r '.chezmoi.config.age.recipients | map("-r " + .) | join(" ")') \
  file >"$(chezmoi source-path)/.chezmoitemplates/file"
```

> [!NOTE]
> `$(chezmoi source-path)` already points _inside_ `home/` because of
> `.chezmoiroot` — do not add another `home/` to the path.

---

## 📝 Other notes

- [New company onboarding](./docs/new-company.md)
- [SSH keys & commit signing](./docs/ssh.md)
- [Repo architecture (for humans and agents)](./AGENTS.md)
- [Windows](./docs/windows.md)
- [Linux](./docs/linux.md)
- [Browser](./docs/browser.md)
- [Terminal](./docs/terminal.md)
- [Zathura](./docs/zathura.md)

---

## 💁 References

### Wallpaper

- <https://github.com/D3Ext/aesthetic-wallpapers>
- <https://github.com/DenverCoder1/minimalistic-wallpaper-collection>
- <https://github.com/Gingeh/wallpapers>

### Other dotfiles

<details>
<summary>
Click to expand
</summary>

- For use
  - <https://github.com/HyDE-Project/HyDE>
  - <https://github.com/JaKooLit/Hyprland-Dots>
  - <https://github.com/end-4/dots-hyprland>
  - <https://github.com/gh0stzk/dotfiles> (BSPWM)
  - <https://github.com/koeqaife/hyprland-material-you>
  - <https://github.com/prasanthrangan/hyprdots>
  - <https://gitlab.com/stephan-raabe/dotfiles>
- Chezmoi
  - <https://github.com/megabyte-labs/install.doctor>
  - <https://github.com/lildude/dotfiles/> (Have config for codespace)
- Others
  - <https://github.com/2KAbhishek/dots2k>
  - <https://github.com/2nthony/dotfiles> (Lazygit?)
  - <https://github.com/Alexis12119/dotfiles>
  - <https://github.com/Cybersnake223/Hypr>
  - <https://github.com/Integralist/dotfiles>
  - <https://github.com/JoosepAlviste/dotfiles>
  - <https://github.com/amitds1997/dotfiles> (setup for arch and mac, git stuff, something is new to me)
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
- Nix
  - <https://git.aquaticservers.com/aqua/AquaticOS> (Hyprland)
  - <https://codeberg.org/HirschBerge/hyprlua> (Temp lua hyprland)
  </details>
