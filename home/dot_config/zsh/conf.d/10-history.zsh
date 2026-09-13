# History + shell options.

export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"

# One-time migration from the pre-ZDOTDIR location.
if [[ ! -f "$HISTFILE" && -f "$HOME/.zsh_history" ]]; then
  mv "$HOME/.zsh_history" "$HISTFILE"
fi

HISTORY_SUBSTRING_SEARCH_PREFIXED=1
SAVEHIST=5000
HISTSIZE=6000 # SAVEHIST * 120%

setopt SHARE_HISTORY          # Share history across all open sessions
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first when cutting down history
setopt HIST_IGNORE_ALL_DUPS   # Clear old duplicates, keeping only the newest unique command
setopt HIST_SAVE_NO_DUPS      # Do not write duplicate commands to the history file
setopt HIST_FIND_NO_DUPS      # Do not display duplicates when searching
setopt HIST_IGNORE_SPACE      # Do not record commands starting with a space

setopt GLOBDOTS               # Include hidden files in autocomplete
setopt PROMPT_SUBST           # Enable evaluation in prompt
setopt IGNOREEOF              # Prevents Ctrl-D from exiting the shell
unsetopt BEEP                 # Silence terminal bells

# Prevents sensitive words from being written to history
zshaddhistory() {
  emulate -L zsh
  if [[ "$1" =~ (password|secret|private|BBb) ]] || [[ "$1" == \ * ]]; then
    return 1
  fi
}
