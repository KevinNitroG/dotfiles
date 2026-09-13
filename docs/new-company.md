# Onboarding a new company

Everything company-specific hangs off one lowercase identifier. Pick it first.

## 0. Choose the identifier

Lowercase, no spaces, hyphens or underscores — Go package naming:

| company | id |
| --- | --- |
| ITC Group | `itcgroup` |
| Acme Corp. | `acmecorp` |
| Foo-Bar Ltd | `foobar` |

It becomes the profile name, git identity filename, ssh host alias, age key
filename and secrets filename. Changing it later means touching all of them.

Replace `acmecorp` with your id below.

---

## 1. SSH key

```sh
ssh-keygen -t ed25519 -C "you@acmecorp.com" -f ~/.ssh/id_ed25519_acmecorp
chmod 600 ~/.ssh/id_ed25519_acmecorp
```

Upload the `.pub` to the company forge as an authentication key and, if
supported, a signing key. Details: [ssh.md](./ssh.md).

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
}}
```

That one entry gives you the `profiles` choice, the identity path and the
recipient.

## 4. Profile definition

In `home/.chezmoidata/profiles.yml`:

```yaml
  acmecorp:
    gitName: Your Name
    gitEmail: you@acmecorp.com
    gitDir: ~/projects/acmecorp/
    signing: ssh
    gpgKey: ""
    sshKey: ~/.ssh/id_ed25519_acmecorp
    sshHosts:
      - name: acmecorp
        hostName: gitlab.acmecorp.com
        user: your.name
```

Drives `~/.config/git/acmecorp`, the `includeIf "gitdir:"` entry, the
`Host acmecorp` block in `~/.ssh/config`, the `allowed_signers` line, and what
`.chezmoiignore.tmpl` drops on machines without this profile.

## 5. Source files

```sh
cd ~/.local/share/chezmoi/home

printf '%s\n' '{{ includeTemplate "git/identity" (dict "profile" "acmecorp" "ctx" .) }}' \
  > dot_config/git/acmecorp.tmpl

cp ~/.ssh/id_ed25519_acmecorp.pub dot_ssh/id_ed25519_acmecorp.pub

printf '# %s secrets\n' acmecorp \
  | chezmoi encrypt \
  > dot_config/zsh/private_private/encrypted_private_acmecorp.zsh.age
```

## 6. Packages (optional)

Company tooling goes in the `work` category of
`home/.chezmoidata/pkgs/{arch-based,ubuntu-based,fedora}.yml`, installed on any
machine with *a* company profile. mise tools go directly in
`home/dot_config/mise/mise.toml.tmpl`, gated with `{{ if .isWork }}`.
Split `work` into `work.<id>` only if two companies ever need different sets.

## 7. Re-init

`~/.config/chezmoi/chezmoi.toml` is only generated at init time:

```sh
chezmoi init       # at the "profiles" prompt, select personal and acmecorp
chezmoi diff
chezmoi apply
```

Non-interactively (`promptMultichoice` separates with `/`):

```sh
chezmoi init --promptDefaults --promptMultichoice profiles=personal/acmecorp
```

The company only appears in the list once it is in `$profileMeta` (step 3) —
chezmoi rejects anything else.

Verify:

```sh
chezmoi data | jq '{profiles, company, isWork}'
grep -A3 '\[age\]' ~/.config/chezmoi/chezmoi.toml
mkdir -p ~/projects/acmecorp && cd ~/projects/acmecorp
git init t && cd t && git config user.email     # -> you@acmecorp.com
```

## 8. Re-encrypt existing secrets

Existing files are still readable only by the old recipients:

```sh
cd ~/.local/share/chezmoi
chezmoi re-add          # every .age file should show as changed
git diff --stat
```

`re-add` skips `.chezmoitemplates/` — redo those with the helper in the
[README](../README.md#manually-addsync-encrypted-file-to-template).

## 9. Back up the keys

Into Bitwarden, **before** you need them:

- `age: acmecorp` — `~/.config/age/acmecorp-key.txt`
- `ssh: acmecorp` — `~/.ssh/id_ed25519_acmecorp` (and the `.pub`)

A rebuild should need nothing but Bitwarden and this repo.

---

## Worth doing

- **Keep `personal` on the work machine.** `profiles = ["personal", "acmecorp"]`
  is the normal answer; `.isWsl` / `.isGui` already strip the leisure dotfiles.
- **Put work repos under `~/projects/acmecorp/`.** Identity is selected by
  directory — a repo in `~/code/whatever` gets signed with your personal key.
- **Check company policy** before pushing dotfiles-managed config to company
  machines, or putting any company secret here — even encrypted. Prefer their
  secret store and keep only references.
- **Separate browser profile** for work; `browser-data/` is already dropped on
  non-personal machines.
- **Don't reuse the personal GPG key.** SSH signing exists so work commits carry
  a separate, revocable identity.
- **Set `AWS_PROFILE` / `KUBECONFIG` in the encrypted `acmecorp.zsh`**, not
  globally, so credentials cannot bleed across profiles.

## Leaving a company

1. Remove the block from `profiles.yml` and the entry from `$profileMeta`.
2. Delete `dot_config/git/acmecorp.tmpl`, `dot_ssh/id_ed25519_acmecorp.pub`,
   `dot_config/zsh/private_private/encrypted_private_acmecorp.zsh.age`.
3. `chezmoi init && chezmoi apply` — removed files are cleaned up.
4. `chezmoi re-add`, then delete `~/.config/age/acmecorp-key.txt` and the
   Bitwarden entries.
5. Revoke the SSH key on the company forge.
