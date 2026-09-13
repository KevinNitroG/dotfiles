# Onboarding a new company

Everything company-specific in this repo hangs off one lowercase identifier.
Pick it first, then work down the list.

## 0. Choose the identifier

Lowercase, no spaces, no hyphens, no underscores — Go package naming:

| company | id |
| --- | --- |
| ITC Group | `itcgroup` |
| Acme Corp. | `acmecorp` |
| Foo-Bar Ltd | `foobar` |

That id becomes the profile name, the git identity filename, the ssh host
alias, the age key filename and the secrets filename. Changing it later means
touching all of them, so get it right once.

Throughout this document, replace `acmecorp` with your id.

---

## 1. Generate an SSH key

```sh
ssh-keygen -t ed25519 -C "you@acmecorp.com" -f ~/.ssh/id_ed25519_acmecorp
chmod 600 ~/.ssh/id_ed25519_acmecorp
```

Upload `~/.ssh/id_ed25519_acmecorp.pub` to the company forge as both an
authentication key and (if supported) a signing key.

See [ssh.md](./ssh.md) for the full guide.

## 2. Generate an age key

```sh
age-keygen -o ~/.config/age/acmecorp-key.txt
chmod 600 ~/.config/age/acmecorp-key.txt
```

Note the `# public key: age1...` line it prints — that is the **recipient**.

## 3. Register the age recipient

The recipient has to be declared in three places (chezmoi's own config template
cannot read `.chezmoidata`, hence the duplication):

**a. `home/.chezmoi.toml.tmpl`** — add to all three inline maps:

```gotmpl
{{ $knownProfiles := list
     "personal"
     "itcgroup"
     "acmecorp"
}}

{{ $ageKeyFiles := dict
     ...
     "acmecorp" ".config/age/acmecorp-key.txt"
}}

{{ $ageRecipients := dict
     ...
     "acmecorp" "age1...."
}}
```

**b. `home/.chezmoidata/global.yml`** — append to `ageRecipients`.

**c. `home/.chezmoidata/profiles.yml`** — add the profile block (step 4).

## 4. Add the profile definition

In `home/.chezmoidata/profiles.yml`:

```yaml
  acmecorp:
    gitName: Your Name
    gitEmail: you@acmecorp.com
    gitDir: ~/projects/acmecorp/
    signing: ssh
    gpgKey: ""
    sshKey: ~/.ssh/id_ed25519_acmecorp
    ageKeyFile: ~/.config/age/acmecorp-key.txt
    ageRecipient: age1....
    sshHosts:
      - name: acmecorp
        hostName: gitlab.acmecorp.com
        user: your.name
```

This single block drives:

- `~/.config/git/acmecorp` — the git identity + signing config
- the `includeIf "gitdir:~/projects/acmecorp/"` entry in `~/.config/git/config`
- the `Host acmecorp` block in `~/.ssh/config`
- the `~/.ssh/allowed_signers` entry
- which files `.chezmoiignore.tmpl` drops on machines without this profile

## 5. Create the source files

Two one-line files, copied from the `itcgroup` ones:

```sh
cd ~/.local/share/chezmoi/home

printf '%s\n' '{{ includeTemplate "git/identity" (dict "profile" "acmecorp" "ctx" .) }}' \
  > dot_config/git/acmecorp.tmpl
```

Commit the public key itself as a plain file (same as `id_ed25519.pub`):

```sh
cp ~/.ssh/id_ed25519_acmecorp.pub dot_ssh/id_ed25519_acmecorp.pub
```

And an encrypted secrets file for the profile:

```sh
printf '# %s secrets\n' acmecorp \
  | chezmoi encrypt \
  > dot_config/zsh/private_private/encrypted_private_acmecorp.zsh.age
```

## 6. Add packages (optional)

Company-only tooling goes in the `work` category of
`home/.chezmoidata/pkgs/{arch-based,ubuntu-based}.yml`. It is installed on any
machine carrying *a* company profile. mise tools are edited directly in
`home/dot_config/mise/mise.toml.tmpl`, gated inline with `{{ if .isWork }}`.
If two companies ever need different tool sets, split `work` into `work.<id>`
at that point — not before.

## 7. Re-init the machine

`~/.config/chezmoi/chezmoi.toml` is only generated at init time, so the new
profile and age identity need a re-init:

```sh
chezmoi init
# at the "profiles" prompt, select both: personal and acmecorp
chezmoi diff       # review
chezmoi apply
```

Non-interactively (`promptMultichoice` uses `/` as its separator):

```sh
chezmoi init --promptDefaults --promptMultichoice profiles=personal/acmecorp
```

The new company only appears in that list once it is in `$knownProfiles` in
`home/.chezmoi.toml.tmpl` (step 3a) — chezmoi rejects anything else.

Verify:

```sh
chezmoi data | jq '{profiles, company, isWork}'
cat ~/.config/chezmoi/chezmoi.toml | grep -A3 '\[age\]'
mkdir -p ~/projects/acmecorp && cd ~/projects/acmecorp
git init t && cd t && git config user.email     # -> you@acmecorp.com
```

## 8. Re-encrypt existing secrets for the new recipient

Existing encrypted files can still only be read by the old recipients. After
step 3, re-encrypt everything so the new key can read it too:

```sh
cd ~/.local/share/chezmoi
chezmoi re-add          # re-encrypts every managed encrypted file
git diff --stat         # every .age file should show as changed
```

For `.chezmoitemplates/` files (which `re-add` does not cover), redo them with
the helper in the [README](../README.md#manually-addsync-encrypted-file-to-template).

## 9. Back up the keys

Put both new keys in Bitwarden **before** you need them:

- `age: acmecorp` — contents of `~/.config/age/acmecorp-key.txt`
- `ssh: acmecorp` — contents of `~/.ssh/id_ed25519_acmecorp` (and the `.pub`)

A machine rebuild should need nothing but Bitwarden and this repo.

---

## Other things worth doing

- **Keep the personal profile on the work machine.** `profiles = ["personal",
  "acmecorp"]` is the normal answer — personal GitHub still gets used from work.
  Machine-class gating (`.isWsl`, `.isGui`) already strips the leisure dotfiles.
- **Put work repos under `~/projects/acmecorp/`.** Identity selection is by
  directory. A work repo cloned to `~/code/whatever` will be signed with your
  personal key and email.
- **Check the company's policy** before pushing dotfiles-managed config to
  company machines, and before putting any company secret in this repo — even
  encrypted. Prefer the company's own secret store and keep only references here.
- **Use a separate browser profile** for work, and keep `browser-data/` out of
  it (already handled: it is dropped on WSL and on non-personal machines).
- **Do not reuse the personal GPG key** for work signing. The SSH-signing path
  exists exactly so work commits carry a separate, revocable identity.
- **Set `AWS_PROFILE` / `KUBECONFIG` per profile** in the encrypted
  `acmecorp.zsh` rather than globally, so personal and work credentials cannot
  bleed into each other.

## Leaving a company

1. Remove the block from `profiles.yml` and the three maps in
   `.chezmoi.toml.tmpl`; drop the recipient from `global.yml`.
2. Delete `dot_config/git/acmecorp.tmpl`,
   `dot_ssh/id_ed25519_acmecorp.pub` and
   `dot_config/zsh/private_private/encrypted_private_acmecorp.zsh.age`.
3. `chezmoi init && chezmoi apply` — the removed files are cleaned up.
4. `chezmoi re-add` to re-encrypt everything without the old recipient, then
   delete `~/.config/age/acmecorp-key.txt` and the Bitwarden entries.
5. Revoke the SSH key on the company forge.
