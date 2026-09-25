# AGENTS.md

Guidance for AI agents working in this repository.

## What this repo is

Personal **dotfiles managed by [chezmoi](https://www.chezmoi.io/)** for
**Arch-based** (CachyOS/EndeavourOS + HyDE/Hyprland), **Ubuntu-based** (incl.
WSL), **Fedora-based** and **Windows**. Catppuccin theming flows from one
`chezmoi init` prompt into ~40 generated files.

`.chezmoiroot` = `home`, so **the source dir is `home/`, not the repo root**.
Everything outside `home/` (`README.md`, `docs/`, `AGENTS.md`, `.github/`,
`.gitattributes`) is repo metadata chezmoi never sees.

## Repository layout

```
.chezmoiroot                 -> "home"  (source dir is home/)
.gitattributes               linguist overrides for the many odd file types
README.md, docs/             human docs
CLAUDE.md                    symlink -> AGENTS.md
.github/workflows/           CI; smoke-ephemeral.yml proves the keyless path
home/                        === CHEZMOI SOURCE DIRECTORY ===
├── .chezmoi.toml.tmpl       generates ~/.config/chezmoi/chezmoi.toml at `init`
├── .chezmoidata/            static data merged into `.` for every template
│   ├── global.yml           externalGitArgs
│   ├── profiles.yml         profileDefs: one block per identity (see below)
│   ├── catppuccin/*.toml    full palettes (latte/frappe/macchiato/mocha)
│   ├── config/windows.yml   Windows env vars + optional-features lists
│   └── pkgs/*.yml           arch-based.yml, ubuntu-based.yml, fedora.yml,
│                            windows.yml
├── .chezmoiexternals/*.tmpl externally-fetched files/archives/git repos
├── .chezmoiignore.tmpl      per-OS / per-machine exclusion rules
├── .chezmoiremove.tmpl      targets to delete on apply
├── .chezmoiscripts/         hooks, split by platform
│   ├── linux/ unix/ windows/
├── .chezmoitemplates/       shared fragments, `includeTemplate`d elsewhere
├── dot_zshenv               -> ~/.zshenv  (stub: sets ZDOTDIR, nothing else)
├── dot_config/zsh/          -> ~/.config/zsh  ($ZDOTDIR)
│   ├── dot_zshenv.tmpl      env vars, PATH, sources private/*.zsh
│   ├── dot_zprofile.tmpl    login shells (input method, GUI only)
│   ├── dot_zshrc.tmpl       oh-my-zsh + sources conf.d/*.zsh
│   ├── conf.d/NN-*.zsh      interactive config fragments, sourced in order
│   └── private_private/     -> ~/.config/zsh/private/ (0700), encrypted
│       encrypted_private_{common,personal,<company>}.zsh.age
├── dot_config/              -> ~/.config/...
├── dot_local/bin/           -> ~/.local/bin/...
├── dot_ssh/                 config.tmpl, allowed_signers.tmpl, *.pub
└── AppData/, Documents/     -> Windows-only targets
```

### Identity profiles

One _profile_ = one identity: `personal`, a company id (lowercase, no spaces or
hyphens — `itcgroup`), or `ephemeral`.

**One machine, one profile** — `promptChoice`, not a list. A company machine has
no personal ssh key, gpg key, `private/*.zsh` or git identity; it reaches GitHub
with the *company* key because that is the only key it has.

`home/.chezmoidata/profiles.yml` declares each profile once
(`profileDefs.<name>`); that one block drives:

- the `[user]` / `[gpg]` / `[commit]` blocks at the bottom of
  `~/.config/git/config` — inline, no include file, no `includeIf`, no gitdir
  scoping
- every `Host` block in `~/.ssh/config` (`sshHosts` is a **list** — a company
  usually has its own git server plus github.com / gitlab.com) and the
  `~/.ssh/allowed_signers` line
- `~/.config/gh/hosts.yml` via `ghUser`; empty ⇒ file not managed
- what `.chezmoiignore.tmpl` drops on machines that are not this profile

Exception: age key path + recipient live in `$profileMeta` in
`home/.chezmoi.toml.tmpl`, which runs before `.chezmoidata` is readable.

GPG is deliberately **not** automated: only `personal` signs with gpg, the key
is imported by hand (`docs/gpg.md`), `profiles.yml` carries only the public id.

New company = one `$profileMeta` entry + one `profiles.yml` block + one
committed `.pub` + one encrypted `<name>.zsh.age`. See `docs/new-company.md`.

#### `ephemeral` — the keyless guest identity

Friend's box, throwaway VM, container, CI: **no age key, no ssh key, no git
identity, no secrets**. Every `profileDefs.ephemeral` field is empty on purpose;
`$profileMeta.ephemeral` has empty `key`/`recipient` (both loops skip empties) ⇒
`.chezmoi.config.age.identities` is `[]` ⇒ the "SECRETS THAT NEED AN AGE
IDENTITY" block drops every encrypted target.

- `.isEphemeral` true; `.isPersonal` **and** `.isWork` both false; `.company`
  `""`. `isWork` is no longer `not isPersonal` — do not reintroduce that.
- `.chezmoiignore.tmpl` drops `.ssh/**` wholesale. Guest keeps their own keys
  and `config`; nothing of this repo's identity lands on their machine.
- `git/config.tmpl` omits `[user]` when `gitName` is empty — never commit as
  someone else.
- Personal-only ad-hoc `Host` blocks in `dot_ssh/config.tmpl` are behind
  `{{ if .isPersonal }}`.
- Packages: `common` only.

**Keep it applyable without any key.** Anything needing a key, token or TTY must
degrade to a warning, never abort. Traps already hit — do not undo:

- `progress = "auto"`, **not** `true`. `true` forces a download progress bar,
  which opens `/dev/tty` → `could not open a new TTY` in any container/CI.
- `encryption = "age"` is always emitted, even with zero identities. It is what
  strips `encrypted_` / `.age` when mapping source → target; without it
  `encrypted_private_dot_npmrc.age` becomes a literal `~/.npmrc.age` no ignore
  entry matches.
- Scripts must not need a TTY: `run_onchange_after_chsh.sh` tolerates `chsh`
  failing under PAM.

CI guards this: `.github/workflows/smoke-ephemeral.yml` (ubuntu-latest, weekly +
on `home/**` changes). Reproduce locally in a container, don't reason about it.

### Where to find things

| Looking for…                                 | Go to                                                                 |
| -------------------------------------------- | --------------------------------------------------------------------- |
| Template data / new variables                | `home/.chezmoi.toml.tmpl` (`[data]`) and `home/.chezmoidata/`         |
| Package lists                                | `home/.chezmoidata/pkgs/{arch-based,ubuntu-based,fedora,windows}.yml` |
| Adding a whole new distro                    | `docs/support-new-os.md`                                              |
| Fedora specifics / limitations               | `docs/fedora.md`                                                      |
| mise tools                                   | `home/dot_config/mise/config.toml.tmpl` (edited directly)             |
| Identities (git/ssh per profile)             | `home/.chezmoidata/profiles.yml`                                      |
| age keys / recipients                        | `$profileMeta` in `home/.chezmoi.toml.tmpl`                           |
| Install / bootstrap logic                    | `home/.chezmoiscripts/{linux,unix,windows}/`                          |
| What gets skipped on which machine           | `home/.chezmoiignore.tmpl`                                            |
| Shell config                                 | `home/dot_zshenv` (stub) + `home/dot_config/zsh/`                     |
| Secrets (env vars, tokens)                   | `home/dot_config/zsh/private_private/*.age`                           |
| Git identity / aliases                       | `home/dot_config/git/config.tmpl` (identity is the last block)        |
| Themed third-party files pulled from the net | `home/.chezmoiexternals/*.toml.tmpl`                                  |
| Reusable template fragments                  | `home/.chezmoitemplates/`                                             |

## Chezmoi mechanics used here

### Attributes (source filename prefixes)

`dot_` → `.`, `private_` → 0600, `executable_` → +x, `encrypted_` → age,
`empty_` → keep if empty, `create_` → write once, `symlink_` → symlink.
Suffix `.tmpl` → Go template, suffix stripped.

`once_` is a **script** attribute only — on a regular file it stays in the name
(`once_foo.conf` → `~/…/once_foo.conf`). `create_` is the file equivalent.

### Templating

Data at `.`:

- `.chezmoi.*` — built-ins (`os`, `arch`, `hostname`, `osRelease.id`,
  `homeDir`, …) plus `.chezmoi.config.age.*`
- `[data]` from `.chezmoi.toml.tmpl`:
  - identity — `profile`, `company` (`""` unless `isWork`), `isPersonal` /
    `isWork` / `isEphemeral` (mutually exclusive)
  - platform — `osId`, `osFamily`, `isWsl`, `isGui`, `isLaptop`, `useHyde`
  - theme — `theme`, `catppuccinFlavor`, `catppuccinAccentColor`,
    `terminalFontSize`, `opacity`, `transparent`
- `.chezmoidata/**` — merged by top-level key: `.pkgs.*`, `.profileDefs.*`,
  `.config.windows.*`, `.externalGitArgs`

Key discriminators:

- `osFamily` — `arch`/`ubuntu`/`fedora`/`windows`/`darwin`/`other`; picks the
  installer. From `osRelease.id` + `idLike`, so CachyOS/EndeavourOS → `arch`,
  Nobara/Bazzite/RHEL-likes → `fedora`. Debian deliberately → `other` (different
  package set, no PPAs) ⇒ no installer runs.
- `osId` — `windows`, `darwin`, or `linux-<osRelease.id>`, for finer branching.
- `isGui` — false on WSL/containers/headless. The single switch for terminal
  emulators, fonts, input methods, desktop config, GUI apps. Prefer it over
  `isWsl`.

The **prompt text is the key** `--promptX` matches, not the variable. `profile`
is prompted as the bare word `profile` so it stays scriptable and is validated
against `$knownProfiles`:

```sh
chezmoi init --promptDefaults --promptChoice profile=itcgroup
```

Other prompts are human-worded (`Is this machine GUI`, …) — script them with the
full text as key. `--promptBool` can't express one containing a comma.

Previous answers are read back from the existing config ⇒ re-running
`chezmoi init` is non-destructive.

**Always render before committing:**

```sh
chezmoi execute-template <home/dot_config/zsh/dot_zshrc.tmpl
chezmoi execute-template --init <home/.chezmoi.toml.tmpl # config template
chezmoi cat ~/.zshrc                                     # rendered target
chezmoi data                                             # everything at `.`
chezmoi doctor
chezmoi apply --dry-run --verbose
```

### Ignore vs. remove

- `.chezmoiignore.tmpl` — templated gitignore-syntax list of _target_ paths
  (relative to `~`) to pretend don't exist. Main modularity lever: OS / WSL /
  role gating. Also gates `.chezmoiscripts/**`.
- `.chezmoiremove.tmpl` — targets to actively **delete** on apply.

Both are templates, so any `.data` value can drive them.

### Scripts

`run_[once_|onchange_][before_|after_]<NN>-<name>.sh[.tmpl]`. `before`/`after`
is relative to applying the rest of the target state; `NN` orders them.
`run_once_` state lives in chezmoi's persistent state — force a re-run with
`chezmoi state delete-bucket --bucket=scriptState`. Gate scripts in
`.chezmoiignore.tmpl`, _not_ with an `if` inside the script.

Unix order: `before_10` distro packages + the mise binary → `after_20` mise
tools (`run_onchange_`, keyed on the rendered `config.toml` hash) → `after_90`
zsh completions.

### Externals

`home/.chezmoiexternals/*.toml.tmpl`: `type = "file" | "archive" | "git-repo"`
keyed by target path, templated (Catppuccin flavour/accent flow into URLs).
`{{ .externalGitArgs }}` injects shallow-clone args.

`git-repo` remotes pick their scheme from whether the profile's private ssh key
is on disk: `git@github.com:` if yes, `https://` otherwise. Never hardcode ssh —
a keyless machine would block on the host-key prompt with no TTY.

### Encryption (age)

`encryption = "age"`, `armor = true`. Encrypted sources carry `encrypted_`
and/or `.age`.

`$profileMeta` in `home/.chezmoi.toml.tmpl` is the **single source of truth** for
key path + recipient; everything else reads `.chezmoi.config.age.*`.

- **identities** — one private key per profile (`~/.config/age/key.txt`,
  `~/.config/age/<company>-key.txt`), never committed. The config lists this
  machine's key *only if the file exists* ⇒ adding a key later means re-running
  `chezmoi init`. An **empty** list is supported, not an error.
- **recipients** — _always all of them_, whatever this machine is. Otherwise
  `chezmoi re-add` on a work box would re-encrypt so the personal key can no
  longer read it. Upshot: whichever key you hold opens everything.

`chezmoi re-add` does **not** cover `.chezmoitemplates/` — use
`~/.local/bin/chezmoi-encrypt-template.sh`.

#### Invariant: every encrypted file is listed in `.chezmoiignore.tmpl`

chezmoi decrypts while computing the target state, so **one unreadable
encrypted file aborts the entire `chezmoi apply`**, not just itself. The
"SECRETS THAT NEED AN AGE IDENTITY" block lists every encrypted target and drops
them all when `.chezmoi.config.age.identities` is empty. That is what keeps a
keyless machine applyable.

Adding an `encrypted_` / `.age` source is a **two-file change**. Audit:

```sh
find home -name '*encrypted_*' -o -name '*.age'
```

## Conventions

- Company ids: **lowercase, no spaces or hyphens**, Go-package style —
  `itcgroup`, not `ITC Group` / `itc-group`. Same for filenames, SSH hosts, key
  names, directory scopes (`~/projects/itcgroup/`).
- Section separators in shell/zsh files: a row of `#`.
- Package lists: YAML string lists with inline `#` comments on non-obvious
  entries; commented-out entries kept as a considered-and-rejected record.
- Scratch material (`MISSING_<DISTRO>_PKGS.md`, …) goes in `tmp/` — gitignored,
  and outside `home/` so chezmoi never sees it.
- oh-my-zsh plugins: `home/.chezmoidata/zsh.yml` (`.zsh.plugins`), lists under
  `pre`, `mid` (`common`/`personal`/`work`), `post`. `work` is keyed per company
  (`work.<company>`) and the template renders only `index work .company`. Lists
  preserve order, maps do not ⇒ name each list explicitly, never range over the
  `mid` or `work` maps.

## Chezmoi tips

- Per-template delimiters, as a comment at the top:
  ```gotmpl
  {{/* chezmoi:template:left-delimiter=%% right-delimiter=%% */}}
  ```

## Working rules for agents

1. **Never edit files under `~` directly.** Edit `home/` + `chezmoi apply`, or
   `chezmoi re-add`.
2. **Verify every template renders** (`chezmoi execute-template`) before
   finishing. One parse error breaks _all_ of `chezmoi apply`.
3. Paths in `.chezmoiignore` / `.chezmoiremove` are **relative to `~`** — never
   prefixed with `home/`.
4. Adding a package = edit `home/.chezmoidata/pkgs/`, not the script. Categories
   `common`/`personal`/`work`/`laptop`, each with `cli` (always) and `gui`
   (`.isGui` only). **mise tools are the exception** — edited directly in
   `home/dot_config/mise/config.toml.tmpl` with inline `{{ if .isWork }}` guards.
5. Machine-class distinctions = a new `[data]` value, never a hardcoded hostname.
6. **New distro** = `docs/support-new-os.md`. Verify package names against a real
   container (testing repos disabled), never guess; translate from
   `arch-based.yml` (the reference set). Gaps fall through to mise.
7. `[git] autoAdd = true` stages source changes automatically; commits/pushes are
   manual.
8. Do not commit secrets — `encrypted_` + age, **and** the target path in the
   "SECRETS THAT NEED AN AGE IDENTITY" block. Miss it and a keyless machine
   cannot apply anything at all.
9. **A template may not depend on anything the apply itself produces.**
   - No shelling out: templates run before the package/mise scripts have touched
     `$PATH`, and re-render only when the _source_ changes, so
     `{{ output "foo" }}` either aborts the apply or bakes in an empty file
     forever. Use a `run_after_` script — see
     `.chezmoiscripts/unix/run_after_90-generate-zsh-completions.sh`.
   - No `include` of a path under `.chezmoi.homeDir`: externals are fetched
     *during* apply, so on a fresh machine (and under `--dry-run`) the file is
     not there yet and the whole apply dies. To re-run a `run_once_` script when
     a themed external changes, put the **data** in the script
     (`# theme: {{ .catppuccinFlavor }}`) — `run_once_` keys on script content,
     so that is enough. `.chezmoiscripts/*/run_once_after_bat-build-cache.*`
     used to hash the fetched `.tmTheme` and broke exactly this way.
10. Unix script order: `10` distro packages + the mise **binary** (guarded by
    `command -v mise`, deliberately not a pkgs-YAML `scripts:` entry — that list
    is for one-shot `curl | sh` installers with no idempotency of their own, e.g.
    tailscale, brave) → `20` mise **tools** → `90` completions.
11. Export `GITHUB_TOKEN` before a first bootstrap (externals + mise hammer the
    API; anon limit 60/h). A missing token must **never** fail an apply:
    `run_onchange_after_20-mise-install.sh.tmpl` warns, prints the recovery
    command, `exit 0`. Every bootstrap script follows that rule.
12. **Do not add comments to files under `home/`.** No explanatory,
    section-header or rationale comments in templates, scripts, data files or
    configs. Only comments already present, and commented-out entries kept as a
    considered-and-rejected record. Invariants belong here or in `docs/`. If you
    think a comment is load-bearing, ask first.
