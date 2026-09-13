# AGENTS.md

Guidance for AI agents working in this repository.

## What this repo is

A personal **dotfiles repo managed by [chezmoi](https://www.chezmoi.io/)**, targeting
**Arch-based Linux** (CachyOS/EndeavourOS + HyDE/Hyprland), **Ubuntu-based Linux**
(including WSL), **Fedora-based Linux**, and **Windows**. Theming is Catppuccin-driven
and flows from one prompt at `chezmoi init` time into ~40 generated config files.

`.chezmoiroot` contains `home`, so **the chezmoi source directory is `home/`, not the
repo root**. Everything outside `home/` (`README.md`, `docs/`, `AGENTS.md`,
`.gitattributes`) is repo metadata that chezmoi never sees.

## Repository layout

```
.chezmoiroot                 -> "home"  (source dir is home/)
.gitattributes               linguist overrides for the many odd file types
README.md, docs/             human docs
CLAUDE.md                    symlink -> AGENTS.md
home/                        === CHEZMOI SOURCE DIRECTORY ===
├── .chezmoi.toml.tmpl       generates ~/.config/chezmoi/chezmoi.toml at `init`
├── .chezmoidata/            static data merged into `.` for every template
│   ├── global.yml           githubUsername, externalGitArgs
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

A *profile* is one identity the machine carries: `personal`, or a company id
(lowercase, no spaces or hyphens — `itcgroup`). `home/.chezmoidata/profiles.yml`
declares each one once (`profileDefs.<name>`) and that single block drives:

- `~/.config/git/<name>` — rendered from `.chezmoitemplates/git/identity`
- the `includeIf "gitdir:"` entries in `~/.config/git/config`
- the `Host` blocks in `~/.ssh/config` and the `~/.ssh/allowed_signers` lines
- which files `.chezmoiignore.tmpl` drops on machines without that profile

The age key path and recipient are the exception: they live in `$profileMeta` in
`home/.chezmoi.toml.tmpl`, which runs before `.chezmoidata` is readable.

Adding a company = one entry in `$profileMeta`, one block in `profiles.yml`, one
one-line `dot_config/git/<name>.tmpl`, one committed `.pub`, one encrypted
`<name>.zsh.age`. See `docs/new-company.md`.

### Where to find things

| Looking for… | Go to |
| --- | --- |
| Template data / new variables | `home/.chezmoi.toml.tmpl` (`[data]`) and `home/.chezmoidata/` |
| Package lists | `home/.chezmoidata/pkgs/{arch-based,ubuntu-based,fedora,windows}.yml` |
| Adding a whole new distro | `docs/support-new-os.md` |
| Fedora specifics / limitations | `docs/fedora.md` |
| mise tools | `home/dot_config/mise/mise.toml.tmpl` (edited directly) |
| Identities (git/ssh per profile) | `home/.chezmoidata/profiles.yml` |
| age keys / recipients | `$profileMeta` in `home/.chezmoi.toml.tmpl` |
| Install / bootstrap logic | `home/.chezmoiscripts/{linux,unix,windows}/` |
| What gets skipped on which machine | `home/.chezmoiignore.tmpl` |
| Shell config | `home/dot_zshenv` (stub) + `home/dot_config/zsh/` |
| Secrets (env vars, tokens) | `home/dot_config/zsh/private_private/*.age` |
| Git identity / aliases | `home/dot_config/git/config.tmpl` + `<profile>.tmpl` |
| Themed third-party files pulled from the net | `home/.chezmoiexternals/*.toml.tmpl` |
| Reusable template fragments | `home/.chezmoitemplates/` |

## Chezmoi mechanics used here

### Attributes (source filename prefixes)

`dot_` → `.`, `private_` → mode 0600, `executable_` → +x, `encrypted_` → age-encrypted,
`empty_` → keep even if empty, `create_` → write once, never overwrite,
`symlink_` → create a symlink, `once_` → only on first apply.
Suffix `.tmpl` → render as a Go template; the suffix is stripped from the target.

### Templating

Data is exposed at `.`:

- `.chezmoi.*` — built-ins (`os`, `arch`, `hostname`, `osRelease.id`, `homeDir`, …),
  plus `.chezmoi.config.age.*` for the age identity and recipients
- `[data]` from `.chezmoi.toml.tmpl` — the *prompted* / *detected* values:
  - identity: `profiles`, `companies`, `company`, `isWork`, `isPersonal`
  - platform: `osId`, `osFamily`, `isWsl`, `isGui`, `isLaptop`, `useHyde`
  - theme: `theme`, `catppuccinFlavor`, `catppuccinAccentColor`,
    `terminalFontSize`, `opacity`, `transparent`
- `.chezmoidata/**` — merged by top-level key: `.pkgs.*`, `.profileDefs.*`,
  `.config.windows.*`, `.githubUsername`, `.externalGitArgs`

The two key discriminators:

- `osFamily` — `arch` / `ubuntu` / `fedora` / `windows` / `darwin` / `other`. Picks
  the package installer. Derived from `osRelease.id` + `idLike`, so CachyOS and
  EndeavourOS both resolve to `arch`, Nobara/Bazzite/RHEL-likes to `fedora`.
  Debian deliberately does *not* map to `ubuntu` (different package set, no PPAs);
  it lands in `other`, which means no installer runs.
- `osId` — `windows`, `darwin`, or `linux-<osRelease.id>`. For finer branching.

`isGui` is false on WSL, in containers and on headless servers; it is the single
switch that strips terminal emulators, fonts, input methods, desktop config and
GUI applications. Prefer it over testing `isWsl` directly.

Prompt names are short and stable (`profiles`, `isGui`, `isLaptop`, `theme`, …)
so they can be scripted. `profiles` is a `promptMultichoice`, validated against
`$knownProfiles`, and its separator is `/`:

```sh
chezmoi init --promptDefaults --promptMultichoice profiles=personal/itcgroup
```

Previous answers are read back out of the existing config, so re-running
`chezmoi init` is non-destructive.

**Always render a template before committing it:**

```sh
chezmoi execute-template < home/dot_config/zsh/dot_zshrc.tmpl
chezmoi execute-template --init < home/.chezmoi.toml.tmpl   # for the config template
chezmoi cat ~/.zshrc          # rendered target content
chezmoi data                  # everything available at `.`
chezmoi doctor
chezmoi apply --dry-run --verbose
```

### Ignore vs. remove

- `home/.chezmoiignore.tmpl` — a gitignore-syntax, **templated** list of *target*
  paths (relative to `~`, no leading `~/`) chezmoi should pretend do not exist.
  This is the main modularity lever: OS gating, WSL gating, machine-role gating.
  It also gates `.chezmoiscripts/**` so scripts for other platforms never run.
- `home/.chezmoiremove.tmpl` — targets chezmoi should actively **delete** on apply.

Both are evaluated as templates, so any `.data` value can drive them.

### Scripts

Named `run_[once_|onchange_][before_|after_]<NN>-<name>.sh[.tmpl]`. `before`/`after`
is relative to applying the rest of the target state; the numeric prefix orders them.
`run_once_` state is tracked in chezmoi's persistent state — use
`chezmoi state delete-bucket --bucket=scriptState` to force a re-run.
Scripts are gated by platform/profile in `.chezmoiignore.tmpl`, *not* by an `if`
inside the script.

Unix ordering: `before_10` distro packages → `after_20` mise tools
(`run_onchange_`, keyed on the rendered `mise.toml` hash) → `after_90` zsh
completion generation.

### Externals

`home/.chezmoiexternals/*.toml.tmpl` declare `type = "file" | "archive" | "git-repo"`
entries keyed by target path. They are templated, so Catppuccin flavour/accent flow
straight into the download URL. `{{ .externalGitArgs }}` injects shallow-clone args.

### Encryption (age)

`encryption = "age"`, `armor = true`. Encrypted source files carry the
`encrypted_` attribute and/or an `.age` suffix.

`$profileMeta` in `home/.chezmoi.toml.tmpl` is the **single source of truth** for
both the key path and the recipient of every profile. Everything else reads it back
from `.chezmoi.config.age.*`, so there is nothing to keep in sync.

- **identities** — one private key file per profile, `~/.config/age/key.txt`
  (personal) and `~/.config/age/<company>-key.txt`. Never committed. The
  generated config lists only the ones that actually exist on this machine, so
  adding a key later requires re-running `chezmoi init`.
- **recipients** — *always every known recipient*, regardless of this machine's
  profiles. Otherwise `chezmoi re-add` on a work-only box would re-encrypt files
  so the personal key could no longer read them.

`chezmoi re-add` re-encrypts managed files but **not** `.chezmoitemplates/` —
use `~/.local/bin/chezmoi-encrypt-template.sh` for those.

## Conventions

- Company/organisation identifiers are **lowercase, no spaces or hyphens**, Go-package
  style: `itcgroup`, not `ITC Group` / `itc-group`. Use this for filenames
  (`~/.config/git/itcgroup`), SSH hosts, key names, and directory scopes
  (`~/projects/itcgroup/`).
- Comment section separators in shell/zsh files use a row of `#` (`##########…`).
- Package lists are YAML lists of strings with inline `#` comments explaining
  non-obvious entries; commented-out entries are kept as a "considered and rejected"
  record.
- Scratch material that helps while working but does not belong in the repo
  (e.g. `MISSING_<DISTRO>_PKGS.md`) goes in `tmp/`, which is gitignored.
  `.chezmoiroot` is `home`, so chezmoi never sees it.

## Working rules for agents

1. **Never edit files under `~` directly.** Edit the source in `home/` and run
   `chezmoi apply`, or use `chezmoi re-add` to pull target changes back in.
2. **Verify every template renders** with `chezmoi execute-template` before finishing.
   A template that fails to parse breaks *all* of `chezmoi apply`.
3. Target paths in `.chezmoiignore` / `.chezmoiremove` are **relative to `~`** and must
   not be prefixed with `home/` — that prefix belongs to the source tree only.
4. Adding a package = edit the YAML under `home/.chezmoidata/pkgs/`, not the
   script. Each category (`common`/`personal`/`work`/`laptop`) has a `cli` list
   (always) and a `gui` list (only when `.isGui`). **mise tools are the
   exception**: they are edited directly in
   `home/dot_config/mise/mise.toml.tmpl` with inline `{{ if .isWork }}` style
   guards, deliberately *not* via `.chezmoidata`.
5. Adding a machine-class distinction = add a `[data]` value in `.chezmoi.toml.tmpl`
   and branch on it, rather than hard-coding hostnames.
6. **Adding a whole distro** = follow `docs/support-new-os.md`. Package names
   must be verified against a real container of that distro (with testing repos
   disabled), never guessed, and new lists are translated from `arch-based.yml`
   — Arch is the reference set. Whatever the distro cannot provide falls
   through to mise.
7. `git` autoAdd is on (`[git] autoAdd = true`), so chezmoi stages source changes
   automatically; commits/pushes are manual.
8. Do not commit secrets. Anything sensitive goes through `encrypted_` + age.
9. **Never generate a file by shelling out to a tool from a template.** A
   template runs during `chezmoi apply`, before the package/mise install scripts
   have put anything on `$PATH`, and it is only re-rendered when its *source*
   changes — so `{{ output "foo" ... }}` either aborts the apply or bakes in an
   empty file forever. Use a `run_after_` script instead; see
   `.chezmoiscripts/unix/run_after_90-generate-zsh-completions.sh`.
10. Script ordering on unix: `10` package install (before) → `20` mise install
   (after, `run_onchange_` keyed on the mise.toml hash) → `90` completions.
11. Export `GITHUB_TOKEN` before a first bootstrap; chezmoi externals and mise
    both hammer the GitHub API and the anonymous limit is 60/hour.
