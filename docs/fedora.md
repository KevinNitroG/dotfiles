# Fedora

What is different about Fedora in this repo, and what it cannot do.

Everything here was verified against a **`fedora:45`** container. The
`fedora:46` tag exists but is still **Rawhide** (`VERSION="46 (Container Image
Prerelease)"`, only a `rawhide` repo), so it is not a meaningful target yet.

- Package list: `home/.chezmoidata/pkgs/fedora.yml`
- Installer: `home/.chezmoiscripts/linux/run_once_before_10-install-pkgs-fedora.sh.tmpl`
- Gated by `osFamily == "fedora"` in `home/.chezmoiignore.tmpl`

`osFamily` resolves to `fedora` from `osRelease.id` **or** `idLike` containing
`fedora` or `rhel`, so Nobara, Bazzite, RHEL, CentOS, Rocky and AlmaLinux all
land here too. Only Fedora itself is actually tested.

## Repositories

Fedora needs three different mechanisms where apt needed two, so
`fedora.yml` declares three lists instead of reusing the apt shape:

| key | analogue | used for |
| --- | --- | --- |
| `releaseRpms` | *(none on apt)* | RPM Fusion free + nonfree, installed by URL. These ship their own `.repo` file **and** their gpg key, so a hand-written repo file would be wrong. |
| `coprs` | `repositories` (PPAs) | `owner/project` strings enabled with `dnf copr enable`. |
| `dnfRepos` | `aptRepos` | hand-written `/etc/yum.repos.d/*.repo` with `baseurl=` + `gpgkey=`; the key is imported with `rpm --import` first. |

Three COPRs are used, because the packages are not in Fedora proper:

| COPR | gives |
| --- | --- |
| `atim/lazygit` | `lazygit` |
| `atim/starship` | `starship` |
| `lihaohong/yazi` | `yazi` **and** `resvg` (yazi's SVG preview dep) |

RPM Fusion **free** is required for `ffmpeg` (yazi video thumbnails); Fedora's
own `ffmpeg-free` is codec-limited. Nonfree is added for the codec and driver
packages the media apps pull in later.

Like the Ubuntu installer, each repo is added, verified with
`dnf makecache`, and **rolled back if it breaks** — a COPR with no build for
this Fedora release must not wedge every later `dnf` call.

## Naming gotchas

Fedora differs from **both** Arch and Ubuntu. The ones that actually bite:

| want | Fedora package | note |
| --- | --- | --- |
| `wget` | `wget2-wget` | **F45 dropped `wget` entirely**; this provides `/usr/bin/wget` |
| `npm` | `nodejs-npm` | a no-op after `nodejs`, which already pulls npm |
| `vim` | `vim-enhanced` | plain `vim` is only a virtual provide |
| pynvim | `python3-neovim` | |
| `7z` | `7zip` | not `p7zip` |
| ctags | `ctags` | this **is** Universal Ctags 6.2.1; there is no `universal-ctags` |
| gnupg | `gnupg2` | |
| `lsb_release` | `lsb_release` | `redhat-lsb-core` is gone |
| ImageMagick | `ImageMagick` | capitalised; 7.1.2, so new enough for yazi |

**No symlink step.** Unlike Debian, `fd-find` ships `/usr/bin/fd` and `bat`
ships `/usr/bin/bat`, so the Fedora installer has no equivalent of the Ubuntu
script's "LINKING DEBIAN-RENAMED BINARIES" section.

`cargo` and `rustup` are separate packages and coexist — `rustup` does not own
`/usr/bin/cargo`. Both are installed, along with `ruby`/`rubygems`, because the
mise `cargo:` and `gem:` backends need those toolchains present.

## What Fedora does better than Ubuntu

These are packaged on Fedora but not Ubuntu, so they are deliberately **absent**
from the fedora block in `mise.toml.tmpl`:

`yq` (genuinely mikefarah's Go yq 4.53.3, unlike Debian's python-yq), `helm`,
`uv`, `astroterm`, `tailscale` (Ubuntu needs the install script), and `resvg`
(via the yazi COPR).

## Limitations

Things that work on Arch but **cannot** work on Fedora:

| missing | why, and what happens instead |
| --- | --- |
| nerd fonts | not packaged at all (only `texlive-inconsolata-nerd-font`). Same gap as Ubuntu. Install manually if you want them; they are GUI-only. |
| `tealdeer` | no package. `tldr` is installed instead — it is the **python** client, not the Rust one. Same command, slower. |
| `kanata` | no package (Arch uses `kanata-bin` from the AUR). The kanata config and systemd unit still deploy, but the binary does not. |
| `tlpui` | no package, and no COPR with a current build. `tlp`/`tlp-rdw` still install, so power management works — only the GUI is missing. |
| `grub-customizer` | no package. |
| `spotify` | no package. |
| `brave` | no package; installed via `https://dl.brave.com/install.sh`, as on Ubuntu. |
| `kubectl` | **only versioned** `kubernetesN.NN-client` packages exist, which cannot be pinned sanely — it comes from mise instead. |
| `lstk`, `cmctl` | no package; `cmctl` already comes from mise everywhere. |

Anything dnf lacks is picked up by the `{{ if eq .osFamily "fedora" }}` block in
`home/dot_config/mise/mise.toml.tmpl`. Compared to Ubuntu's block, Fedora
additionally needs `procs`, `dysk`, `dust`, `xh`, `jqp`, `kubecolor` and
`tmuxinator`, all of which apt carried and dnf does not.

## Known rough edges

- **`tmuxinator` drags in Ruby.** Upstream publishes only a `.gem`, which is a
  ruby package rather than an executable, so there is no prebuilt binary to use.
  Beware: pointing mise's `http:` backend at the `.gem` URL reports
  `✓ installed` and leaves an **empty directory** — a false success.
- **`dysk` needs `bin_path`.** Upstream ships one arch-less zip containing
  per-triple subdirectories. `aqua:` installs it but exposes no binary, and the
  deprecated `ubi:` backend silently installs the **macOS arm64** build, which
  fails with `exec format error`. Hence the explicit `github:Canop/dysk` entry
  with a `bin_path`.
- The installer deliberately does **not** `set -e`. Failures are collected and
  printed at the end; most of what dnf lacks is expected to come from mise.
