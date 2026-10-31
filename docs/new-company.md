# Onboarding a new company

Everything hangs off one lowercase identifier. Pick it first.

## 0. Choose the identifier

Lowercase, no spaces, hyphens or underscores — Go package naming:

| company | id |
| --- | --- |
| ITC Group | `itcgroup` |
| Acme Corp. | `acmecorp` |
| Foo-Bar Ltd | `foobar` |

It becomes the profile name, git identity filename, ssh host alias, age key
filename and secrets filename — changing it later touches all of them.

`acmecorp` below = your id.

---

## 1. SSH key

```sh
ssh-keygen -t ed25519 -C "you@acmecorp.com" -f ~/.ssh/id_ed25519_acmecorp
chmod 600 ~/.ssh/id_ed25519_acmecorp
```

Upload the `.pub` to the company forge as an authentication key and, if
supported, a signing key — **and to every other forge this machine will use**,
GitHub and gitlab.com included. A company machine has no other key to offer.
Details: [ssh.md](./ssh.md).

## 2. age key

```sh
age-keygen -o ~/.config/age/acmecorp-key.txt
chmod 600 ~/.config/age/acmecorp-key.txt
```

Note the `# public key: age1...` line — that is the **recipient**.

## 3. Register the age recipient

Add the profile to `$profileMeta` in `home/.chezmoi.toml.tmpl` — the **only**
place age keys and recipients are declared (`chezmoi init` runs before
`.chezmoidata` is readable; everything else reads it back from
`.chezmoi.config.age.*`).

```gotmpl
{{ $profileMeta := dict
     "personal" (dict ...)
     "itcgroup" (dict ...)
     "acmecorp" (dict
       "key" ".config/age/acmecorp-key.txt"
       "recipient" "age1....")
     "ephemeral" (dict ...)
}}
```

That one entry gives you the `profile` choice, the identity path and the
recipient.

> [!NOTE]
> Leave `ephemeral` alone. It is the keyless guest identity (empty `key` and
> `recipient`, skipped by both loops) and `$knownProfiles` deliberately sorts
> it last, after `personal` and the companies.

## 4. Profile file

Write the profile as plaintext YAML somewhere outside the repo, then encrypt it
for every recipient into `.chezmoitemplates/`:

```yaml
gitName: Your Name
gitEmail: you@acmecorp.com
signing: ssh
gpgKey: ""
sshKey: ~/.ssh/id_ed25519_acmecorp # git signing
ghUser: "" # company GitHub account, "" if none
```

```sh
chezmoi-encrypt-template.sh ./acmecorp.yml profiles/acmecorp.yml.age
shred -u ./acmecorp.yml
```

Edit later with `chezmoi decrypt` / `chezmoi encrypt` (the repo's `.nvim.lua`
binds them to `<localleader>d` / `<localleader>e`).

Only the active profile's file is decrypted, so no machine reads another
profile's data. It drives `~/.config/git/config`, `~/.config/gh/hosts.yml` and
`authorized_keys`.

## 5. SSH hosts

A plain ssh_config file, encrypted. It is a normal file in `config.d/`, so
write it with real ssh syntax:

```sh
cd ~/.local/share/chezmoi/home
$EDITOR /tmp/acmecorp.conf
chezmoi encrypt < /tmp/acmecorp.conf \
  > dot_ssh/config.d/encrypted_private_acmecorp.conf.age
shred -u /tmp/acmecorp.conf
```

```sshconfig
Host acmecorp
  HostName gitlab.acmecorp.com
  User your.name
  IdentityFile ~/.ssh/id_ed25519_acmecorp
  IdentitiesOnly yes

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_acmecorp
  IdentitiesOnly yes
```

**List every forge this identity uses**, public ones included. An `acmecorp`
machine has no personal key on it, so `github.com` must appear here or GitHub
is unreachable from it — and the key you register on GitHub is the *company*
key. Same for `gitlab.com`. Leave `ghUser` empty if there is no company GitHub
account; `hosts.yml` is then not managed and `gh auth login` writes its own.

The file is already dropped on every other profile by the loop in
`.chezmoiignore.tmpl`. Its target `.ssh/config.d/acmecorp.conf` must also be
in the "SECRETS THAT NEED AN AGE IDENTITY" block — the `{{ if .isWork }}` entry
there covers any company.

## 6. Secrets file

The git identity and ssh hosts need no source file; they come from step 4.

```sh
cd ~/.local/share/chezmoi/home

printf '# %s secrets\n' acmecorp \
  | chezmoi encrypt \
  > dot_config/zsh/private_private/encrypted_private_acmecorp.zsh.age
```

`.config/zsh/private/**` is already listed in the "SECRETS THAT NEED AN AGE
IDENTITY" block of `home/.chezmoiignore.tmpl`, so this one is covered — but
**any encrypted file you add outside that glob needs its own target path
there**. chezmoi decrypts while rendering, so a single file no key can open
aborts the whole `chezmoi apply`, not just that file. Files under
`.chezmoitemplates/` are not targets and need no entry.

## 7. Packages (optional)

Company tooling goes in the `work` category of
`home/.chezmoidata/pkgs/{arch-based,ubuntu-based,fedora}.yml`, installed on any
machine with *a* company profile. mise tools go directly in
`home/dot_config/mise/config.toml.tmpl`, gated with `{{ if .isWork }}`.
Split `work` into `work.<id>` only if two companies ever need different sets.

## 8. Re-init

`~/.config/chezmoi/chezmoi.toml` is only generated at init time:

```sh
chezmoi init       # at the "profile" prompt, select acmecorp
chezmoi diff
chezmoi apply
```

Non-interactively:

```sh
chezmoi init --promptDefaults --promptChoice profile=acmecorp
```

The company only appears in the list once it is in `$profileMeta` (step 3) —
chezmoi rejects anything else.

Verify:

```sh
chezmoi data | jq '{profile, company, isWork}'
grep -A3 '\[age\]' ~/.config/chezmoi/chezmoi.toml
mkdir -p ~/projects/acmecorp && cd ~/projects/acmecorp
git init t && cd t && git config user.email     # -> you@acmecorp.com
```

## 9. Re-encrypt existing secrets

Existing files are still readable only by the old recipients:

```sh
cd ~/.local/share/chezmoi
chezmoi re-add          # every .age file should show as changed
git diff --stat
```

`re-add` skips `.chezmoitemplates/` — redo `profiles/*.yml.age` with the helper
in the [README](../README.md#-encrypted-files): `chezmoi decrypt` each to a
temp file, then `chezmoi-encrypt-template.sh`.

## 10. Back up the keys

Into Bitwarden, **before** you need them:

- `age: acmecorp` — `~/.config/age/acmecorp-key.txt`
- `ssh: acmecorp` — `~/.ssh/id_ed25519_acmecorp`

A rebuild should need nothing but Bitwarden and this repo.

---

## Worth doing

- **A company machine is company-only.** No way to also carry `personal` — that
  is the point. Register the company key with GitHub and work from it.
- **Every repo commits as this identity.** No gitdir scoping. One-off override:
  `user.name` / `user.email` in that repo's `.git/config`.
- **Check company policy** before pushing managed config to company machines, or
  putting any company secret here — even encrypted. Prefer their secret store,
  keep only references.
- **Separate browser profile** for work; `browser-data/` is already dropped on
  non-personal machines.
- **Don't reuse the personal GPG key** — SSH signing gives work a separate,
  revocable identity.
- **`AWS_PROFILE` / `KUBECONFIG` in the encrypted `acmecorp.zsh`**, not globally,
  so credentials cannot bleed across profiles.

## Leaving a company

1. Remove the entry from `$profileMeta`.
2. Delete `.chezmoitemplates/profiles/acmecorp.yml.age`,
   `dot_ssh/config.d/encrypted_private_acmecorp.conf.age` and
   `dot_config/zsh/private_private/encrypted_private_acmecorp.zsh.age`.
3. `chezmoi init && chezmoi apply` — pick another profile; removed files are
   cleaned up.
4. `chezmoi re-add`, then delete `~/.config/age/acmecorp-key.txt` and the
   Bitwarden entries.
5. Revoke the SSH key on the company forge.
