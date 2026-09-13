#!/usr/bin/env bash
# Regenerate ~/.config/zsh/completions from the tools actually installed.
#
# These used to be chezmoi templates calling `output "<tool>" completion zsh`,
# which is wrong for two reasons:
#   1. they run during `chezmoi apply`, i.e. BEFORE the package and mise
#      install scripts have put the binaries on $PATH — so on a fresh machine
#      every one of them either aborted the apply or produced an empty file;
#   2. an empty file never gets refilled, because chezmoi only re-renders a
#      template when its SOURCE changes, not when the environment does.
#
# A plain script run at the end of every apply has neither problem, and can be
# re-run by hand any time you install or upgrade a tool:
#
#   ~/.local/share/chezmoi/home/.chezmoiscripts/unix/run_after_90-generate-zsh-completions.sh
#
# (the `zshcomp` alias does this)

set -uo pipefail

COMP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completions"
mkdir -p "$COMP_DIR"

# Pick up tools that were just installed but are not yet on this shell's PATH.
export PATH="$HOME/.local/bin:${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims:$PATH"

# name:binary:args...
specs=(
  "_chezmoi:chezmoi:completion:zsh"
  "_cmctl:cmctl:completion:zsh"
  "_doggo:doggo:completions:zsh"
  "_just:just:--completions:zsh"
  "_kubectl-cnpg:kubectl-cnpg:completion:zsh"
  "_lstk:lstk:completion:zsh"
  "_npm:npm:completion"
  "_opencode:opencode:completion:zsh"
  "_pnpm:pnpm:completion:zsh"
  "_railway:railway:completion:zsh"
  "_rc:rc:completions:zsh"
  "_uv:uv:generate-shell-completion:zsh"
  "_gh:gh:completion:-s:zsh"
  "_mise:mise:completion:zsh"
  "_tree-sitter:tree-sitter:complete:--shell:zsh"
)

generated=0
skipped=()
for spec in "${specs[@]}"; do
  IFS=':' read -r -a parts <<<"$spec"
  name="${parts[0]}"
  bin="${parts[1]}"
  args=("${parts[@]:2}")

  if ! command -v "$bin" >/dev/null 2>&1; then
    skipped+=("$bin")
    continue
  fi

  tmp="$(mktemp)"
  if "$bin" "${args[@]}" >"$tmp" 2>/dev/null && [ -s "$tmp" ]; then
    mv "$tmp" "$COMP_DIR/$name"
    generated=$((generated + 1))
  else
    rm -f "$tmp"
    skipped+=("$bin")
  fi
done

# mc generates completions at runtime rather than emitting a script.
if command -v mc >/dev/null 2>&1; then
  cat >"$COMP_DIR/_mc" <<'MC'
#compdef mc
# vim:ft=zsh
_mc() {
  compadd -Q -- ${(f)"$(mc "${(@)words[2,CURRENT-1]}" --generate-bash-completion 2>/dev/null)"}
}
_mc "$@"
MC
  generated=$((generated + 1))
fi

echo "zsh completions: generated $generated in $COMP_DIR"
if [ ${#skipped[@]} -gt 0 ]; then
  echo "  not installed, skipped: ${skipped[*]}"
fi

# compinit caches the completion list; drop it so the new files are picked up.
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}"/zsh/zcompdump*
