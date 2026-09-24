zmodload -F zsh/stat b:zstat

typeset -g _hist_seen_size=0

_hist_note_size() {
  local -a s
  zstat -A s +size "$HISTFILE" 2>/dev/null && _hist_seen_size=$s[1]
}

_hist_import_maybe() {
  local -a s
  zstat -A s +size "$HISTFILE" 2>/dev/null || return
  (( s[1] > _hist_seen_size )) || return
  _hist_seen_size=$s[1]
  fc -RI 2>/dev/null
}

if (( $+widgets[history-substring-search-up] )); then
  _hist_import_up() { _hist_import_maybe; zle history-substring-search-up }
  _hist_import_down() { _hist_import_maybe; zle history-substring-search-down }
  zle -N _hist_import_up
  zle -N _hist_import_down
  bindkey '^[[A' _hist_import_up '^[OA' _hist_import_up
  bindkey '^[[B' _hist_import_down '^[OB' _hist_import_down
fi

if (( $+widgets[fzf-history-widget] )); then
  _hist_import_fzf() { _hist_import_maybe; zle fzf-history-widget }
  zle -N _hist_import_fzf
  bindkey '^R' _hist_import_fzf
fi

autoload -Uz add-zsh-hook
add-zsh-hook precmd _hist_note_size
