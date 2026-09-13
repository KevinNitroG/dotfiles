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

Every machine answers a handful of questions at `chezmoi init`, and the answers
drive what gets installed and which config files exist:

| value | meaning |
| --- | --- |
| `profiles` | the identities this machine carries, e.g. `personal`, `personal,itcgroup` |
| `osFamily` | `arch` / `ubuntu` / `windows` / `darwin` — picks the package installer |
| `isWsl` | auto-detected; drops terminal emulators, fonts, input methods, desktop config |
| `isGui` | auto-detected; false on WSL, containers and headless servers |
| `isLaptop` | auto-detected; adds power management |

Identities (git name/email, signing key, ssh host, age key, secrets file) are
declared once per profile in `home/.chezmoidata/profiles.yml`. Adding a company
is one block there — see [docs/new-company.md](./docs/new-company.md).

Packages live in `home/.chezmoidata/pkgs/` split into `common` / `personal` /
`work` / `laptop`, each with a `cli` list (always) and a `gui` list (desktop
only). See [AGENTS.md](./AGENTS.md) for the full repo map.

---

## ⚙️ Installation

### 0. Prerequisites per platform

<details>
<summary><b>Windows</b></summary>

> [!IMPORTANT]
> These dotfiles currently require **administrator privileges** on Windows.
> `home/.chezmoiscripts/windows/run_once_before_0_config-windows.ps1.tmpl`
> self-elevates via UAC to toggle Windows optional features (WSL, Virtual
> Machine Platform, .NET) and to adjust machine-wide policy; the Scoop/Choco
> bootstrap and the `ssh-agent` service also need it. Run the install from an
> elevated PowerShell and expect UAC prompts.
>
> User `PATH` entries themselves are set with
> `[Environment]::SetEnvironmentVariable(..., User)`, which does *not* need
> admin — only the feature toggles do.

</details>

<details>
<summary><b>WSL</b></summary>

Install Windows Subsystem for Linux from the Microsoft Store:
<https://apps.microsoft.com/detail/9PDXGNCFSCZV>

Then install a distribution and set it as default:

```powershell
wsl --install -d Ubuntu
wsl --set-default Ubuntu
```

Inside the WSL guest, follow the Linux instructions below. WSL is detected
automatically (`isWsl`), and the following are skipped because they make no
sense in a guest:

- terminal emulators (alacritty, kitty, ghostty, wezterm) — the Windows
  terminal is the terminal
- fonts, `fcitx5` input method, `~/.gtkrc-2.0.mine`
- Hyprland / HyDE / sddm / systemd desktop units, `kanata`, browser flag files
- personal "leisure" dotfiles (browser data, OBS, rclone mounts, ncspot, …)

`~/.wslconfig` configures the WSL VM and therefore belongs on the **Windows
host**, not inside the guest — it is only applied on Windows.

</details>

<details>
<summary><b>Linux</b></summary>

Arch-based (Arch, CachyOS, EndeavourOS) and Ubuntu (including Mint and Pop!_OS,
which report `ID_LIKE=ubuntu`) are supported; the right installer script is
selected from `osFamily`. On Ubuntu,
`software-properties-common` plus `ppa:neovim-ppa/stable` are set up
automatically so neovim is current. Tools apt does not carry come from
mise.

</details>

### 1. SSH key

You need an SSH key to clone this repo over SSH, and one per identity you use.
Full guide: [docs/ssh.md](./docs/ssh.md).

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

Encrypted files are decrypted with [age](https://age-encryption.org/). The
convention is **one identity file per profile**, all under `~/.config/age/`,
and **none of them are ever committed**:

| profile | identity file |
| --- | --- |
| `personal` | `~/.config/age/key.txt` |
| `<company>` | `~/.config/age/<company>-key.txt` |

Restore them from Bitwarden, or generate a new one:

```sh
mkdir -p ~/.config/age
age-keygen -o ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt
```

Every encrypted file in this repo is encrypted to **all** known recipients, so
any machine can read anything its profiles entitle it to. `chezmoi init` only
lists identity files that actually exist, so adding a key later means re-running
`chezmoi init`.

> [!NOTE]
> This repo is personal and contains encrypted files you cannot decrypt. To use
> it anyway, run chezmoi apply with `--exclude=encrypted`.

### 3. GitHub API rate limits

Both **chezmoi** and **mise** hit the GitHub API a lot during a first apply —
chezmoi for `type = "git-repo"` / release externals, mise for every
`github:owner/repo` and `npm:`/`cargo:` tool it resolves. Anonymous requests are
capped at **60/hour**, which is nowhere near enough: you will see
`API rate limit exceeded` and a half-installed machine.

Export a token **before** running init. A classic PAT with no scopes at all is
enough — this is only about the rate limit, not about access:

```sh
export GITHUB_TOKEN='ghp_...'
```

Both tools read `GITHUB_TOKEN` (mise also accepts `MISE_GITHUB_TOKEN`), which
raises the limit to 5000/hour. On an already-provisioned machine the token
lives in the encrypted `~/.config/zsh/private/personal.zsh` and is exported by
every shell, so this only matters for the very first bootstrap — before the
secrets exist.

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

You will be asked to pick `profiles` from a list — `personal` on a personal
machine, or both `personal` and `itcgroup` on a work machine that also uses the
personal GitHub account. To script it, note that `promptMultichoice` separates
values with `/`:

```sh
chezmoi init --promptDefaults --promptMultichoice profiles=personal/itcgroup
```

### 5. Commit signing

Signing is configured per profile in `home/.chezmoidata/profiles.yml`:
`personal` signs with **GPG**, company profiles sign with their **SSH** key.
Identity is chosen by directory (`includeIf "gitdir:"`), so work repos must
live under the profile's `gitDir` (e.g. `~/projects/itcgroup/`).

GPG, for the personal profile:

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

SSH signing needs nothing beyond the key itself; `~/.ssh/allowed_signers` is
generated from `profiles.yml`. Verify with `git log --show-signature -1`.

## Manually add/sync encrypted file to template

`chezmoi re-add` re-encrypts every *managed* file, but it does not touch
`home/.chezmoitemplates/`. Use the helper for those:

```sh
chezmoi-encrypt-template.sh ~/.config/Code/User/settings.json VSCode/encrypted_settings.json
chezmoi-encrypt-template.sh ~/.config/rclone/rclone.conf       rclone/encrypted_rclone.conf
```

It reads the recipients chezmoi itself is configured with, so every file ends
up readable by every profile. The raw equivalent:

```sh
age -a $(chezmoi data --format json | jq -r '.chezmoi.config.age.recipients | map("-r " + .) | join(" ")') \
  file > "$(chezmoi source-path)/.chezmoitemplates/file"
```

> [!NOTE]
> `$(chezmoi source-path)` already points *inside* `home/` because of
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
