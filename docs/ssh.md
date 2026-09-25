# SSH

## Convention

One machine → one profile → one key:

| profile | private key | public key |
| --- | --- | --- |
| `personal` | `~/.ssh/id_ed25519` | `~/.ssh/id_ed25519.pub` |
| `<company>` | `~/.ssh/id_ed25519_<company>` | `~/.ssh/id_ed25519_<company>.pub` |
| `ephemeral` | — | — |

`ephemeral` (guest / throwaway / CI) has no key: `~/.ssh` is **unmanaged** — no
`config`, `allowed_signers`, `.pub` or `authorized_keys`. The owner's existing
setup is left alone.

That one key authenticates to **every** forge the profile uses, GitHub included
— a company machine pushes to GitHub with the company key, so register it there
too. Forges come from `sshHosts` in `home/.chezmoidata/profiles.yml`; nothing is
hardcoded per host. Company ids: lowercase, no spaces or hyphens.

**Only public keys are committed** (`home/dot_ssh/`). Private keys come from
Bitwarden. `~/.ssh/config` + `~/.ssh/allowed_signers` are generated from
`profiles.yml` + those `.pub` files.

## Create a key

```sh
ssh-keygen -t ed25519 -C "kevin.t@itcgroup.io" -f ~/.ssh/id_ed25519_itcgroup
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519_itcgroup
chmod 644 ~/.ssh/id_ed25519_itcgroup.pub
```

ed25519, not RSA. `-C` = email shown in the forge's key list. Use a passphrase
(`ssh-agent` = type it once per session). Permissions matter — ssh refuses keys
that are too readable.

## Load it into the agent

```sh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_itcgroup
ssh-add -l
```

Windows (elevated, once):

```powershell
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add "$env:USERPROFILE\.ssh\id_ed25519_itcgroup"
```

WSL does not share the Windows agent — run its own, simpler than bridging with
`npiperelay` + `socat`.

## Tell the forge

Paste the **`.pub`**, never the private key.

- GitHub: Settings → SSH and GPG keys → **New SSH key**. Add it **twice** to
  sign commits: once as *Authentication*, once as *Signing*.
- GitLab: Preferences → SSH Keys.

## Per-host configuration

`~/.ssh/config` is generated from `profileDefs.<profile>.sshHosts` — a list,
since a company usually has its own git server *plus* the public forges:

```yaml
sshHosts:
  - name: itcgroup
    hostName: gitlab.itcgroup.io
    user: kevin.t
  - name: github.com
    hostName: github.com
    user: git
```

→

```sshconfig
Host itcgroup
  HostName gitlab.itcgroup.io
  User kevin.t
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/id_ed25519_itcgroup
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
```

- Every block gets the active profile's `sshKey` → a personal key can never
  reach a company machine's config.
- `IdentitiesOnly yes`: without it ssh offers every agent key, and a server with
  `MaxAuthTries 3` disconnects before the right one.
- `StrictHostKeyChecking accept-new`: first contact must not block on a prompt —
  `git-repo` externals are cloned non-interactively during `chezmoi apply`.
- Clone with the alias: `git clone itcgroup:team/repo.git`.

Ad-hoc personal hosts (homelab, tailnet, modem) are in `dot_ssh/config.tmpl`
behind `{{ if .isPersonal }}`.

## Signing commits with SSH

`personal` → GPG ([gpg.md](./gpg.md)), companies → SSH, `ephemeral` → none.
From `profiles.yml`:

```yaml
signing: ssh
sshKey: ~/.ssh/id_ed25519_itcgroup
```

with `home/dot_ssh/id_ed25519_itcgroup.pub` committed alongside → the IDENTITY
block at the bottom of `~/.config/git/config`:

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

### Why `allowed_signers` exists

Signing needs only the key; **verifying** needs git to know which public key may
sign as which identity. GPG uses your keyring — SSH has none, hence the file.
Without it `git log --show-signature` says *No principal matched*, even for your
own commits.

Generated from `profiles.yml` + the committed `.pub`, one line per signing
identity:

```
kevin.t@itcgroup.io namespaces="git" ssh-ed25519 AAAA... kevin.t@itcgroup.io
```

Check:

```sh
git commit --allow-empty -m 'test: signing'
git log --show-signature -1
```

## Test a connection

```sh
ssh -T git@github.com          # "Hi <user>! You've successfully authenticated"
ssh -vT itcgroup               # -v shows which key was offered and accepted
```

## Common problems

| Symptom | Fix |
| --- | --- |
| `Permissions 0644 ... are too open` | `chmod 600` the private key |
| `Too many authentication failures` | `IdentitiesOnly yes` on that Host block |
| Wrong account for a repo | clone via the host alias (`itcgroup:...`), not the raw hostname |
| Commit signed with wrong identity | one identity per machine; override in that repo's `.git/config` |
| `Load key ... invalid format` when signing | `user.signingkey` must point at the `.pub` |
| Host key changed / MITM warning | `ssh-keygen -R <host>`, reconnect, accept the new fingerprint |

**Lost private key**: the public one cannot sign or authenticate. New pair →
upload the `.pub` → replace `home/dot_ssh/<name>.pub` → `chezmoi apply` → revoke
the old one.

## Backup

Every private key → Bitwarden as `ssh: <profile>`, same place as the age keys. A
rebuild then needs only Bitwarden plus this repo.
