# SSH

How SSH keys are created, stored, used and signed with here.

## Convention

A machine carries **one** profile, and that profile has **one** key:

| profile | private key | public key |
| --- | --- | --- |
| `personal` | `~/.ssh/id_ed25519` | `~/.ssh/id_ed25519.pub` |
| `<company>` | `~/.ssh/id_ed25519_<company>` | `~/.ssh/id_ed25519_<company>.pub` |

That key authenticates to **every** forge the profile talks to, GitHub
included. A company machine has no personal key on it, so it pushes to GitHub
with the company key — register that key on GitHub too, alongside the company
forge and gitlab.com. Which forges a profile uses is its `sshHosts` list in
`home/.chezmoidata/profiles.yml`; nothing is hardcoded per host.

Company ids are lowercase, no spaces or hyphens (`itcgroup`).

**Only public keys are committed**, as plain files in `home/dot_ssh/`. Private
keys come from Bitwarden or are regenerated. `~/.ssh/config` and
`~/.ssh/allowed_signers` are generated from `home/.chezmoidata/profiles.yml`
plus those committed `.pub` files.

## Create a key

```sh
ssh-keygen -t ed25519 -C "kevin.t@itcgroup.io" -f ~/.ssh/id_ed25519_itcgroup
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519_itcgroup
chmod 644 ~/.ssh/id_ed25519_itcgroup.pub
```

ed25519, not RSA. `-C` is the email, shown in the forge's key list. Use a
passphrase — `ssh-agent` means typing it once per session. Permissions matter:
ssh refuses keys that are too readable.

## Load it into the agent

```sh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_itcgroup
ssh-add -l
```

Windows (elevated PowerShell, once):

```powershell
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add "$env:USERPROFILE\.ssh\id_ed25519_itcgroup"
```

WSL does not share the Windows agent. Run a separate `ssh-agent` inside WSL —
simpler than bridging with `npiperelay` + `socat`.

## Tell the forge

Paste the **`.pub`**, never the private key.

- GitHub: Settings → SSH and GPG keys → **New SSH key**. Add it twice to sign
  commits: once as *Authentication*, once as *Signing*.
- GitLab: Preferences → SSH Keys.

## Per-host configuration

`~/.ssh/config` is generated from `profileDefs.<profile>.sshHosts` in
`home/.chezmoidata/profiles.yml`. It is a list — a company usually has its own
git server *plus* the public forges where its key is registered:

```yaml
sshHosts:
  - name: itcgroup
    hostName: gitlab.itcgroup.io
    user: kevin.t
  - name: gitlab.com
    hostName: gitlab.com
    user: git
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

Host gitlab.com
  ...
Host github.com
  ...
```

Every block gets the active profile's `sshKey`, so there is no way for a
personal key to end up on a company machine's config.

`IdentitiesOnly yes` matters: without it ssh offers every key in the agent, and
a server with `MaxAuthTries 3` disconnects before reaching the right one.

Clone with the alias: `git clone itcgroup:team/repo.git`.

## Signing commits with SSH

Personal commits are GPG-signed (imported by hand — see [gpg.md](./gpg.md)),
company commits SSH-signed. Set in `profiles.yml`:

```yaml
signing: ssh
sshKey: ~/.ssh/id_ed25519_itcgroup
```

with `home/dot_ssh/id_ed25519_itcgroup.pub` committed alongside, producing the
IDENTITY block at the bottom of `~/.config/git/config`:

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

Signing needs only the key; **verifying** needs git to know which public keys
may sign as which identity. GPG gets that from your keyring — SSH has none,
hence the file. Without it `git log --show-signature` says *No principal
matched* even for your own commits.

It is generated from `profiles.yml` plus the committed `.pub` files, one line
per signing identity:

```
kevin.t@itcgroup.io namespaces="git" ssh-ed25519 AAAA... kevin.t@itcgroup.io
```

Verify:

```sh
cd ~/projects/itcgroup/some-repo
git commit --allow-empty -m 'test: signing'
git log --show-signature -1
```

## Test a connection

```sh
ssh -T git@github.com          # "Hi <user>! You've successfully authenticated"
ssh -T git@gitlab.itcgroup.io
ssh -vT itcgroup               # -v shows which key was offered and accepted
```

## Common problems

| Symptom | Fix |
| --- | --- |
| `Permissions 0644 ... are too open` | `chmod 600` the private key |
| `Too many authentication failures` | add `IdentitiesOnly yes` to that Host block |
| Wrong account used for a repo | clone via the host alias (`itcgroup:...`), not the raw hostname |
| Commit signed with wrong identity | the machine has one identity for every repo; override it in that repo's own `.git/config` |
| `Load key ... invalid format` when signing | `user.signingkey` must point at the `.pub`, and the private key must be loadable |
| Host key changed / MITM warning | `ssh-keygen -R <host>`, reconnect, accept the new fingerprint |

**Lost the private key**: the public one cannot sign or authenticate. Generate a
new pair, upload the new `.pub` to the forge, replace `home/dot_ssh/<name>.pub`,
`chezmoi apply`, revoke the old key.

## Backup

Every private key goes into Bitwarden as `ssh: <profile>` — same place as the
age keys. A rebuild then needs only Bitwarden plus this repo.
