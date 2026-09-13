# SSH

How SSH keys are created, stored, used and signed with here.

## Convention

One key per identity, named after the profile:

| profile | private key | public key | used for |
| --- | --- | --- | --- |
| `personal` | `~/.ssh/id_ed25519` | `~/.ssh/id_ed25519.pub` | GitHub, personal servers |
| `<company>` | `~/.ssh/id_ed25519_<company>` | `~/.ssh/id_ed25519_<company>.pub` | company forge and hosts |

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

`~/.ssh/config` is generated from `profileDefs.<company>.sshHosts` in
`home/.chezmoidata/profiles.yml`:

```yaml
sshHosts:
  - name: itcgroup
    hostName: gitlab.itcgroup.io
    user: kevin.t
```

→

```sshconfig
Host itcgroup
  HostName gitlab.itcgroup.io
  User kevin.t
  IdentityFile ~/.ssh/id_ed25519_itcgroup
  IdentitiesOnly yes
```

`IdentitiesOnly yes` matters: without it ssh offers every key in the agent, and
a server with `MaxAuthTries 3` disconnects before reaching the right one.

Clone with the alias: `git clone itcgroup:team/repo.git`.

## Signing commits with SSH

Personal commits are GPG-signed, company commits SSH-signed. Set in
`profiles.yml`:

```yaml
signing: ssh
sshKey: ~/.ssh/id_ed25519_itcgroup
```

with `home/dot_ssh/id_ed25519_itcgroup.pub` committed alongside, producing
`~/.config/git/itcgroup`:

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
| Commit signed with wrong identity | identity is by directory — the repo must live under the profile's `gitDir`; check `git config user.email` |
| `Load key ... invalid format` when signing | `user.signingkey` must point at the `.pub`, and the private key must be loadable |
| Host key changed / MITM warning | `ssh-keygen -R <host>`, reconnect, accept the new fingerprint |

**Lost the private key**: the public one cannot sign or authenticate. Generate a
new pair, upload the new `.pub` to the forge, replace `home/dot_ssh/<name>.pub`,
`chezmoi apply`, revoke the old key.

## Backup

Every private key goes into Bitwarden as `ssh: <profile>` — same place as the
age keys. A rebuild then needs only Bitwarden plus this repo.
