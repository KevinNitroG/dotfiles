# SSH

How SSH keys are created, stored, used and signed with in this dotfiles repo.

## Convention

One key per identity, named after the profile:

| profile | private key | public key | used for |
| --- | --- | --- | --- |
| `personal` | `~/.ssh/id_ed25519` | `~/.ssh/id_ed25519.pub` | GitHub, personal servers |
| `<company>` | `~/.ssh/id_ed25519_<company>` | `~/.ssh/id_ed25519_<company>.pub` | company forge, company hosts |

Company ids are lowercase with no spaces or hyphens (`itcgroup`), the same
identifier used everywhere else in this repo.

**Only public keys are committed**, as plain files in `home/dot_ssh/`
(`id_ed25519.pub`, `id_ed25519_itcgroup.pub`, ...). Private keys never enter the
repo — they come from Bitwarden, or are regenerated. `~/.ssh/config` and
`~/.ssh/allowed_signers` are generated from `home/.chezmoidata/profiles.yml`
plus those committed `.pub` files.

## Create a key

```sh
ssh-keygen -t ed25519 -C "kevin.t@itcgroup.io" -f ~/.ssh/id_ed25519_itcgroup
```

- `-t ed25519` — small, fast, modern. Do not use RSA for new keys.
- `-C` — a comment; use the email the key belongs to. It is what you will see
  in GitHub/GitLab's key list.
- Use a passphrase. `ssh-agent` means you only type it once per session.

Permissions matter — sshd and ssh both refuse keys that are too readable:

```sh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519_itcgroup
chmod 644 ~/.ssh/id_ed25519_itcgroup.pub
```

## Load it into the agent

Linux / macOS:

```sh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_itcgroup
ssh-add -l            # list loaded keys
```

Windows (PowerShell as Administrator, once):

```powershell
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add "$env:USERPROFILE\.ssh\id_ed25519_itcgroup"
```

WSL does not share the Windows agent by default. Either run a Linux
`ssh-agent` inside WSL, or bridge to the Windows one with `npiperelay` +
`socat`. Running a separate agent inside WSL is simpler.

## Tell the forge about it

- GitHub: Settings → SSH and GPG keys → **New SSH key**. Add it twice if you
  want to sign commits: once as an *Authentication key*, once as a *Signing key*.
- GitLab (self-hosted, e.g. `gitlab.itcgroup.io`): Preferences → SSH Keys.

Paste the contents of the **`.pub`** file. Never the private one.

## Per-host configuration

`~/.ssh/config` is generated. Host blocks for a company come from
`profileDefs.<company>.sshHosts` in `home/.chezmoidata/profiles.yml`:

```yaml
sshHosts:
  - name: itcgroup
    hostName: gitlab.itcgroup.io
    user: kevin.t
```

which renders to:

```sshconfig
Host itcgroup
  HostName gitlab.itcgroup.io
  User kevin.t
  IdentityFile ~/.ssh/id_ed25519_itcgroup
  IdentitiesOnly yes
```

`IdentitiesOnly yes` is important: without it ssh offers every key in the agent
in turn, and a server with `MaxAuthTries 3` will disconnect you before it
reaches the right one.

Clone with the alias: `git clone itcgroup:team/repo.git`.

## Signing commits with SSH

Personal commits are signed with GPG; company commits are signed with the
company **SSH** key. That is set per profile in `profiles.yml`:

```yaml
signing: ssh
sshKey: ~/.ssh/id_ed25519_itcgroup
```

with `home/dot_ssh/id_ed25519_itcgroup.pub` committed alongside it,

which produces, in `~/.config/git/itcgroup`:

```gitconfig
[user]
  signingkey = ~/.ssh/id_ed25519_itcgroup.pub
[gpg]
  format = ssh
[gpg "ssh"]
  allowedSignersFile = ~/.ssh/allowed_signers
[commit]
  gpgsign = true
```

### Why `~/.ssh/allowed_signers` exists

Signing a commit only needs the key. **Verifying** one needs git to know which
public keys are allowed to sign as which identity — that list is
`~/.ssh/allowed_signers`. Without it, `git log --show-signature` reports *No
principal matched* even for commits you just made yourself. GPG gets this from
your keyring; SSH has no keyring, hence the file.

It is generated from `profiles.yml` (for the email and which profiles sign with
ssh) plus the committed `.pub` files, one line per signing identity:

```
kevin.t@itcgroup.io namespaces="git" ssh-ed25519 AAAA... kevin.t@itcgroup.io
```

Verify it works:

```sh
cd ~/projects/itcgroup/some-repo
git commit --allow-empty -m 'test: signing'
git log --show-signature -1
```

## Test a connection

```sh
ssh -T git@github.com          # expect: "Hi <user>! You've successfully authenticated"
ssh -T git@gitlab.itcgroup.io
ssh -vT itcgroup               # -v shows which key was offered and accepted
```

## Common problems

**`Permissions 0644 for '...' are too open`**
`chmod 600` the private key.

**`Too many authentication failures`**
The agent offered too many keys. Add `IdentitiesOnly yes` to that Host block
(the generated config already does this for profile hosts).

**Wrong account is used for a repo**
Clone via the host alias (`itcgroup:...`) rather than the raw hostname, or the
`Host *` default key gets offered first.

**Commit is signed with the wrong identity**
Identity is selected by directory, not by remote. Work repos must live under
the `gitDir` declared in `profiles.yml` (`~/projects/itcgroup/`). Check with
`git config user.email` inside the repo.

**`error: Load key ... invalid format` when signing**
`user.signingkey` must point at the `.pub` file, and the matching private key
must be loadable (in the agent, or on disk next to it).

**Lost the private key**
The public key alone cannot sign or authenticate. Generate a new pair, upload
the new public key to the forge, replace `home/dot_ssh/<name>.pub` in this repo
with the new one, and run `chezmoi apply`. Revoke the old key on the forge.

**Host key changed / MITM warning after reinstalling a server**
`ssh-keygen -R <host>` then reconnect and accept the new fingerprint.

## Backup

Store every private key in Bitwarden as a secure note or file attachment, named
`ssh: <profile>` — same place the age keys live. A machine rebuild then needs
only Bitwarden plus this repo.
