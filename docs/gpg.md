# GPG

Only the `personal` profile signs with GPG; companies sign with their SSH key
(see [ssh.md](./ssh.md)). The key itself is **imported by hand** — nothing in
this repo imports, trusts or installs a private key. `profiles.yml` carries
only the public `gpgKey` id, so `~/.config/git/personal` knows what to sign
with.

Get the key from Bitwarden.

| | |
| --- | --- |
| long key id | `071E9CD8A2D41057` — this is `gpgKey` in `profiles.yml`, what git signs with |
| fingerprint | `780EDBE72B368638D3DA4691071E9CD8A2D41057` — for `--edit-key` / `trusted-key`, recorded here only |

The fingerprint is **not** in `profiles.yml`: nothing renders from it any more
now that the key is imported by hand, and a value no template reads is a value
that silently goes stale.

`-a` / `--armor`: ASCII armored output.

## Install

- **Arch / Fedora / Ubuntu** — `gnupg` is in the package lists already.
- **Windows** — use the GPG shipped with Git for Windows rather than a second
  installation; `gpg.exe` lives in `C:\Program Files\Git\usr\bin` and is on
  `PATH` inside **git bash**. Run every command below from git bash.

  A standalone [Gpg4win](https://www.gpg4win.org/) works too, but then two
  `gpg` binaries with two separate keyrings are on the machine and git will
  use whichever `gpg.program` resolves to — importing into one and signing
  with the other is the usual confusion.

  The agent does not start on its own at logon. `Start GPG.xml` in
  `~/.config/windows-tasks-scheduler/` imports a Task Scheduler job that runs:

  ```powershell
  gpgconf --launch gpg-agent
  gpgconf --launch keyboxd
  ```

  The same thing is available in the PowerShell profile as `Start-GPG` /
  `Stop-GPG` / `Restart-GPG`.

## Export

From the machine that already has the key.

### Private

```sh
gpg -a --export-secret-keys trannguyenthaibinh46@gmail.com
```

### Public

```sh
gpg -a --export trannguyenthaibinh46@gmail.com
```

## Import

> [!NOTE]
> Importing the private key also imports the public key.

```sh
gpg --import << 'EOF'
# Content here
EOF
```

From a file instead — the Windows path, where heredocs are awkward:

```sh
gpg --import kevinnitro-secret-gpg-key.asc
```

## Trust the key

A freshly imported key is valid but not *trusted*, so git prints a warning on
every signature. Set ultimate trust once:

```sh
gpg --edit-key 071E9CD8A2D41057
```

then at the `gpg>` prompt: `trust` → `5` → `y` → `save`.

## Verify

```sh
gpg --list-secret-keys --keyid-format=long
cd ~/projects/some-repo
git commit --allow-empty -m 'test: signing'
git log --show-signature -1
```

`gpgKey` in `home/.chezmoidata/profiles.yml` must match the long key id shown
above, or git signs with nothing.
