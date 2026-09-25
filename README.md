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
  <a href="https://wakatime.com/badge/github/KevinNitroG/dotfiles">
    <img src="https://wakatime.com/badge/github/KevinNitroG/dotfiles.svg?style=for-the-badge" alt="wakatime">
  </a>
</div>

<div align=center>
  <img alt="Arch" src="https://img.shields.io/badge/Arch-89b4fa?logo=arch-linux&logoColor=white&style=for-the-badge"/>
  <img alt="EndeavourOS" src="https://img.shields.io/badge/endeavour%20os-b4befe?logo=endeavouros&logoColor=white&style=for-the-badge"/>
  <img alt="CachyOS" src="https://img.shields.io/badge/cachy%20os-00AA88?logo=cachyos&logoColor=white&style=for-the-badge"/>
  <img alt="Ubuntu" src="https://img.shields.io/badge/Ubuntu-fab387?logo=ubuntu&logoColor=white&style=for-the-badge"/>
  <img alt="Fedora" src="https://img.shields.io/badge/Fedora-51A2DA?logo=fedora&logoColor=white&style=for-the-badge"/>
  <img alt="Windows" src="https://img.shields.io/badge/Windows-74c7ec?style=for-the-badge&logo=windows&logoColor=white"/>
  <img alt="WSL" src="https://img.shields.io/badge/WSL-0272cb?logo=linux&logoColor=white&style=for-the-badge"/>
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
  - [4. Slow network](#4-slow-network)
  - [5. Install chezmoi and apply](#5-install-chezmoi-and-apply)
  - [6. Commit signing](#6-commit-signing)
- [👤 Ephemeral / guest machines](#-ephemeral--guest-machines)
- [🔐 Encrypted files](#-encrypted-files)
  - [Then list it in `.chezmoiignore.tmpl`](#then-list-it-in-chezmoiignoretmpl)
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

`chezmoi init` prompts; the answers decide what exists.

| value      | meaning                                                      |
| ---------- | ------------------------------------------------------------ |
| `profile`  | the ONE identity — `personal`, a company id, or `ephemeral`  |
| `osFamily` | `arch` / `ubuntu` / `fedora` / `windows` / `darwin`          |
| `isWsl`    | auto                                                         |
| `isGui`    | auto; false on WSL, containers, headless                     |
| `isLaptop` | auto; adds power management                                  |

- Identities → `home/.chezmoidata/profiles.yml`, one block each ([new company](./docs/new-company.md)).
- Packages → `home/.chezmoidata/pkgs/`, split `common`/`personal`/`work`/`laptop` × `cli`/`gui`.
- Repo map → [AGENTS.md](./AGENTS.md).

**Not me? Use [`ephemeral`](#-ephemeral--guest-machines).**

---

## ⚙️ Installation

### 0. Prerequisites per platform

<details>
<summary><b>Windows</b></summary>

> [!IMPORTANT]
> Needs **admin**. Elevated PowerShell, expect UAC:
> `run_once_before_0_config-windows.ps1.tmpl` toggles optional features (WSL,
> Virtual Machine Platform, .NET); Scoop/Choco and `ssh-agent` need it too.
> User `PATH` does not.

</details>

<details>
<summary><b>WSL</b></summary>

[Store](https://apps.microsoft.com/detail/9PDXGNCFSCZV), then:

```powershell
wsl --install -d Ubuntu
wsl --set-default Ubuntu
```

Then follow Linux. `isWsl` is auto and drops: terminal emulators, fonts,
fcitx5, Hyprland/HyDE/sddm/systemd desktop units, kanata, leisure dotfiles.

`~/.wslconfig` belongs to the **Windows host**, not the guest.

</details>

<details>
<summary><b>Linux</b></summary>

Arch-based, Ubuntu-based, Fedora-based. Installer picked from `osFamily`.
Ubuntu adds `ppa:neovim-ppa/stable`; whatever apt/dnf lacks comes from mise.

</details>

### 1. SSH key

> [!TIP]
> `ephemeral` has no keys — skip steps 1, 2, 6.

One key per identity → [docs/ssh.md](./docs/ssh.md).

- Linux / WSL / macOS
  ```sh
  eval "$(ssh-agent -s)"
  chmod 700 ~/.ssh/
  chmod 644 ~/.ssh/id_ed25519.pub
  chmod 600 ~/.ssh/id_ed25519
  ssh-add ~/.ssh/id_ed25519
  ```
- Windows _(elevated)_
  ```powershell
  Set-Service ssh-agent -StartupType Automatic
  Start-Service ssh-agent
  ssh-add "$env:USERPROFILE/.ssh/id_ed25519"
  ```

### 2. age key

[age](https://age-encryption.org/) identity per profile, **never committed**:

| profile     | identity file                     |
| ----------- | --------------------------------- |
| `personal`  | `~/.config/age/key.txt`           |
| `<company>` | `~/.config/age/<company>-key.txt` |
| `ephemeral` | none                              |

Restore from Bitwarden, or:

```sh
mkdir -p ~/.config/age
age-keygen -o ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt
```

- Encrypted to **all** recipients → any one key opens everything.
- `init` only lists keys that exist → new key = re-run `chezmoi init`.
- No key at all = encrypted targets skipped, apply still succeeds. No
  `--exclude=encrypted` needed.

### 3. GitHub API rate limits

Externals + mise hammer the API (anon limit 60/h).

```sh
export GITHUB_TOKEN='ghp_...'          # or: $(gh auth token)
```

First bootstrap only; afterwards it lives in `~/.config/zsh/private/personal.zsh`.

### 4. Slow network

```sh
export MISE_JOBS=2
export MISE_HTTP_TIMEOUT=10m
export MISE_FETCH_REMOTE_VERSIONS_TIMEOUT=10m
```

### 5. Install chezmoi and apply

_([docs](https://www.chezmoi.io/install))_

- shell
  ```sh
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --ssh --depth 1 KevinNitroG
  ```
- pwsh _(elevated)_
  ```powershell
  iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply --ssh --depth 1 KevinNitroG"
  ```

> [!CAUTION]
> No `--purge-binary` unless your package manager ships chezmoi. It deletes
> `~/.local/bin/chezmoi` at the end — without a packaged chezmoi you are left
> with none and cannot re-apply.
>
> - **Arch-based** — `chezmoi` is in the package list → safe, and avoids two
>   copies shadowing each other.
> - **Everything else** — leave it off. To clean up later: install chezmoi
>   properly (`mise use -g chezmoi`, package manager), then
>   `rm ~/.local/bin/chezmoi`.

Scripted:

```sh
chezmoi init --promptDefaults --promptChoice profile=[company]
```

### 6. Commit signing

`personal` → **GPG**, companies → **SSH**, `ephemeral` → none. One identity per
machine, so every repo signs the same way.

- SSH: needs only the key; `~/.ssh/allowed_signers` is generated.
  Check: `git log --show-signature -1`.
- GPG: keys imported **by hand** → [docs/gpg.md](./docs/gpg.md).

---

## 👤 Ephemeral / guest machines

A friend's laptop, throwaway VM, container, devcontainer, CI — **no age key, no
ssh key**.

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --depth 1 \
  --promptChoice profile=ephemeral KevinNitroG
```

<details>
<summary>Fully non-interactive (CI)</summary>

```sh
chezmoi init --apply --depth 1 \
  --promptChoice 'profile=ephemeral,What theme to use=dark,catppuccin light flavour=latte,catppuccin dark flavour=mocha,catppuccin accentColor=lavender' \
  --promptBool 'Is this machine GUI=false,Is this a laptop=false' \
  --promptInt 'Terminal font size=13' \
  --promptString 'Opacity=0.8' \
  KevinNitroG
```

</details>

Not touched:

| area           | behaviour                                                       |
| -------------- | ---------------------------------------------------------------- |
| `~/.ssh`       | unmanaged entirely — your keys and `config` stay                 |
| git identity   | no `[user]` block; your existing one wins                        |
| commit signing | off                                                              |
| secrets        | no age key ⇒ every `encrypted_` target skipped                   |
| `gh`           | `hosts.yml` unmanaged                                            |
| packages       | `common` only                                                    |

You still get: zsh + oh-my-zsh + starship, editors, Catppuccin, the `common`
CLI toolchain.

> [!NOTE]
> `git-repo` externals clone over **https** unless the profile's private ssh key
> is actually on disk (then `git@github.com:`) — a keyless clone never blocks on
> a host-key prompt.

Promote to a real identity later: drop the age + ssh keys in place, then
`chezmoi init --promptChoice profile=personal && chezmoi apply`.

---

## 🔐 Encrypted files

`chezmoi re-add` re-encrypts managed files, but **not** `home/.chezmoitemplates/`:

```sh
chezmoi-encrypt-template.sh ~/.config/rclone/rclone.conf rclone/encrypted_rclone.conf
```

<details>
<summary>Raw equivalent</summary>

```sh
age -a $(chezmoi data --format json | jq -r '.chezmoi.config.age.recipients | map("-r " + .) | join(" ")') \
  file >"$(chezmoi source-path)/.chezmoitemplates/file"
```

`$(chezmoi source-path)` is already _inside_ `home/` — don't add it again.

</details>

### Then list it in `.chezmoiignore.tmpl`

**Every** encrypted file needs its target path in the "SECRETS THAT NEED AN AGE
IDENTITY" block. Adding an `encrypted_` / `.age` source is a **two-file change**.

Why: chezmoi decrypts while rendering the target state, so one unreadable file
aborts the whole `chezmoi apply`, not just itself.

Audit:

```sh
find home -name '*encrypted_*' -o -name '*.age'
```

> [!TIP]
> CI proves the keyless path still works —
> [`.github/workflows/smoke-ephemeral.yml`](./.github/workflows/smoke-ephemeral.yml)
> applies the `ephemeral` profile on `ubuntu-latest` every Wednesday 03:00
> UTC+7.

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
