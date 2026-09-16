# Adding support for a new OS / distro

How to teach this repo about a distro it does not know yet. Written from the
Fedora port, which is the worked example throughout — see `docs/fedora.md` for
what that produced.

**The governing rule: replicate `arch-based.yml`.** Arch is the primary distro
here, so its package list is the reference set. A new distro's list is a
*translation* of `home/.chezmoidata/pkgs/arch-based.yml`, not a fresh list.
Anything Arch has that the new distro cannot provide falls through to mise.

**The second rule: verify, never guess.** Package names differ between distros
far more than seems reasonable, and assumptions are usually wrong in both
directions. Fedora 45 turned out to have dropped `wget` entirely; Ubuntu 26.04
turned out to carry far more than expected. Measure.

---

## 0. Decide whether it is a new family

`osFamily` picks the installer. A distro that can reuse an existing family's
package manager **and** package names should map onto that family instead of
getting its own — that is why CachyOS and EndeavourOS are just `arch`.

Give it a new family only if the package *names* differ. Debian is the
cautionary case: same `apt`, different package set and no PPAs, so it
deliberately lands in `other` (= no installer runs) rather than pretending to be
Ubuntu.

## 1. Detection — `home/.chezmoi.toml.tmpl`

Add a branch to the `$osFamily` block. Match on `id` **or** `idLike` so the
rebuilds come along for free:

```
  {{ else if or (contains "fedora" $ids) (contains "rhel" $ids) }}
    {{ $osFamily = "fedora" }}
```

Update the comment listing the valid values, and the matching line in the
"Gating vocabulary" header of `home/.chezmoiignore.tmpl`.

Test the logic against real `os-release` values before trusting it — build a
throwaway template that loops over `(dict "id" ... "like" ...)` cases and prints
the resolved family, and include the distros you did **not** intend to catch, to
prove there is no regression:

```sh
chezmoi execute-template --file /tmp/detect-test.tmpl
```

## 2. Find a container to verify against

```sh
docker run -d --name oscheck <distro>:<tag> sleep infinity
```

**Check what you actually got.** A tag that exists is not always a release —
`fedora:46` exists but is Rawhide (`VERSION="46 (Container Image Prerelease)"`,
only a `rawhide` repo), so the port was verified on `fedora:45` instead. Confirm
with:

```sh
docker exec oscheck grep -E '^(ID|ID_LIKE|VERSION_ID|VERSION)=' /etc/os-release
docker exec oscheck <pkgmgr> repolist        # dnf
docker exec oscheck apt-cache policy         # apt
```

**Disable testing/proposed repos** before querying, or you will "verify" a
package that only exists in a testing build:

```sh
dnf repoquery --disablerepo='*-testing' ...
```

Say in the commit or docs which tag you used.

## 3. Translate the package list

Copy the *structure* of the nearest existing list (`ubuntu-based.yml` is the
most elaborate) and walk `arch-based.yml` top to bottom. Keep the same
categories (`common` / `personal` / `work` / `laptop`) and the same
`cli` / `gui` split — `gui` is skipped whenever `.isGui` is false (WSL,
containers, servers).

Bulk-check candidate names in one pass rather than one at a time:

```sh
while read -r p; do
  out=$(dnf repoquery --disablerepo='*-testing' --qf '%{name}|%{repoid}' "$p" 2>/dev/null | sort -u | head -1)
  [ -n "$out" ] && echo "OK   $p -> $out" || echo "MISS $p"
done < candidates.txt
```

For a `MISS`, find what really provides the binary before giving up:

```sh
dnf repoquery --whatprovides /usr/bin/wget     # -> wget2-wget
apt-file search bin/wget                       # apt equivalent
```

That step is what turns `wget` MISS into `wget2-wget`, `npm` into `nodejs-npm`,
and `vim` into `vim-enhanced`. Also confirm a package is the thing you *think*
it is — Fedora's `yq` is mikefarah's Go yq, Ubuntu's is python-yq; Fedora's
`tldr` is the python client, not tealdeer.

Record renames and binary-name differences as inline `#` comments in the YAML.
Keep rejected entries commented out, as the other lists do.

**No web search needed if a container is available** — the package manager's own
query tools are authoritative and faster. Use the distro's web package search
only when no container exists (e.g. a distro with no official image).

## 4. Repositories

Each distro's third-party repo mechanism gets its **own** shape in the YAML;
do not bend one distro's shape onto another. Compare:

| distro | keys | mechanism |
| --- | --- | --- |
| Ubuntu | `repositories`, `aptRepos` | PPAs; `sources.list.d` + `signed-by` keyring |
| Fedora | `releaseRpms`, `coprs`, `dnfRepos` | release RPMs; `dnf copr enable`; `yum.repos.d` + `gpgkey=` |

Keep third-party repos to a minimum — each is a trust and maintenance burden.
Before adding one, check the repo actually has builds for this release *and*
architecture, and prefer the better-maintained option when several exist.

## 5. The installer script

Model it on `run_once_before_10-install-pkgs-ubuntu-based.sh.tmpl` and preserve
its resilience properties, which are deliberate:

- **No `set -e`** (only `set -uo pipefail`). One missing package must not abort
  the whole bootstrap.
- **One merged install invocation, with a per-package fallback.** Join all
  `cli`/`gui` packages into a single transaction (`apt-get install ...`,
  `dnf install ...`, `yay -S ...`) so the solver resolves dependencies once
  and downloads in parallel. If that single transaction fails (one rename or
  missing package on that release), fall back to a per-package loop that
  collects failures into an array and prints them at the end. Never ship only
  the single transaction — it makes the bootstrap brittle across releases —
  and never ship only the loop — it is slow and hides solver conflicts.
- **Arch is the exception: always full-upgrade.** Never `pacman -Sy` without
  `-u`, and never `yay -S --needed` without `-u`. A sync-only DB plus a
  version-pinned dep (e.g. `python-uv` requiring `uv=0.12.13`) breaks the
  transaction. Use `pacman -Syu` / `yay -Syu --needed`.
- **Roll back any repo that breaks the metadata refresh.** Add the repo, run
  `dnf makecache` / `apt-get update`, and remove it again if that fails.
- **Guard anything idempotent-sensitive.** Use the *real* package name —
  `rpm -q rpmfusion-free` never matches, because the package is
  `rpmfusion-free-release`.
- Add a symlink step **only if needed**: Debian renames `fd`→`fdfind` and
  `bat`→`batcat`, Fedora does not.

## 6. Gate the script

In `home/.chezmoiignore.tmpl`, next to the existing rules:

```
{{ if ne .osFamily "fedora" }}
.chezmoiscripts/linux/*-fedora*
{{ end }}
```

Verify that **exactly one** installer survives per family, and none on `other`:

```sh
for fam in arch ubuntu fedora other; do
  echo "--- $fam ---"
  chezmoi --config /tmp/cfg-$fam.toml execute-template \
    --file home/.chezmoiignore.tmpl | grep 'chezmoiscripts/linux/\*'
done
```

(A `/tmp/cfg-<fam>.toml` is just a stub config with a `[data]` table holding
`osFamily`, `isGui`, `isPersonal`, … — enough to render templates for a machine
you are not on.)

## 7. Fill the gaps with mise

Anything the distro genuinely lacks goes in a
`{{ if eq .osFamily "<family>" }}` block in
`home/dot_config/mise/mise.toml.tmpl`.

**Do not copy another distro's block.** Diff against what you measured — the
Fedora block drops `yq`/`helm`/`uv`/`astroterm` because dnf has them, and adds
`procs`/`dysk`/`dust`/`xh`/`jqp`/`kubecolor`/`tmuxinator` because apt had them
and dnf does not.

Choosing a backend, in order of preference:

1. **Short registry name** — `htmlq = "latest"`. Check with `mise registry <name>`;
   it prints the backends it maps to. Simplest, use it when it exists.
2. **`aqua:<owner>/<repo>`** — prebuilt binaries, correct asset mapping, and no
   `rename_exe` needed. `mise registry` only knows *short* names, so it will say
   nothing for e.g. `procs` even though `aqua:dalance/procs` works. Check the
   real question with `mise ls-remote aqua:<owner>/<repo>`.
3. **`github:<owner>/<repo>`** — when aqua has no package. Bare-binary assets
   need `rename_exe`.
4. **`cargo:` / `npm:` / `pipx:` / `gem:`** — last resort. `cargo:` *compiles
   from source* and is dramatically slower than a prebuilt binary; prefer aqua
   whenever it exists.

Never add `ubi:` — mise deprecates it ("will be removed in mise 2027.1.0").

Before adding a `github:` entry, confirm it actually publishes release assets
for linux x86_64:

```sh
gh api repos/<owner>/<repo>/releases/latest --jq '.tag_name, (.assets[].name)'
```

Then **install it and run it** in a throwaway root — do not trust a successful
`mise install`:

```sh
MISE_DATA_DIR=/tmp/misetest mise install '<backend>:<spec>@latest'
MISE_DATA_DIR=/tmp/misetest mise which <bin>     # this is the real test
```

Two traps that both report success and deliver nothing:

- an arch-less archive with per-platform subdirectories installs fine but
  exposes **no binary** — it needs `bin_path` (see `github:Canop/dysk`);
- the `http:` backend pointed at a non-executable asset (a `.gem`, say) prints
  `✓ installed` and leaves an **empty directory**.

If an entry needs mise's own `{{ }}` templating, escape it so chezmoi passes it
through — see the `mcp-grafana` `asset_pattern` and the `dysk` `bin_path`. Note
that a *comment* containing a bare `{{ }}` breaks the template too.

Switching `github:` → `aqua:` does **not** reduce GitHub API usage — both spend
one API call per version lookup. The fix for rate limits is `GITHUB_TOKEN`
(AGENTS.md working rule 11), not the backend choice.

## 8. Verify everything renders, then clean up

```sh
chezmoi execute-template --file home/.chezmoidata/... # every changed template
bash -n /tmp/rendered-installer.sh                    # generated scripts
shellcheck -S warning /tmp/rendered-installer.sh
```

Render the installer for **both** `isGui: true` and `false` — the headless
render should drop the GUI repos and GUI install scripts.

Stronger, and worth doing: run the repo-setup half of the rendered script inside
the container, confirm it is **idempotent** on a second run, and resolve the
full package list as one transaction to catch conflicts:

```sh
dnf install --assumeno <every package>     # resolves without downloading
```

Beware of testing against a container you have already polluted — a conflict
that appears only after an out-of-order manual install is an artifact, not a
bug. Re-test on a fresh container before "fixing" it.

Finally: `docker rm -f` the containers (and `docker rmi` the images if you are
done), and delete throwaway mise roots under `/tmp`.

## 9. Document and wire it up

- Add `docs/<distro>.md` covering repos, naming gotchas, and — most importantly
  — **limitations**: what works on Arch and cannot work here, and what happens
  instead. `docs/fedora.md` is the template.
- Keep the "which Arch packages have no equivalent" scratch list in `tmp/`
  (gitignored), not in the repo.
- Add a badge to `README.md`, alongside the other distro badges.
- Update `home/.chezmoidata/pkgs/` references in `AGENTS.md` and
  `docs/new-company.md` if you added a new list file.

Do **not** run `chezmoi apply` to test a distro you are not on.
