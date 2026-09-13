# fzf-driven file/grep pickers, bound to Ctrl-F / Ctrl-G.

_fzf_open_path() {
  local input_path=$1
  if [ ! -n "$input_path" ]; then
    return 1
  fi
  declare -A cmds=(
    [bat]='bat $input_path'
    [cat]='cat $input_path'
    [cd]='[[ -f "$input_path" ]] && input_path=$(dirname "$input_path"); cd $input_path'
    [nvim]='nvim $input_path'
    [remove]='rm -rf $input_path'
    [echo]='echo $input_path'
  )
  local cmd=$(printf "%s\n" "${(@k)cmds}" | fzf --prompt 'Select command> ')
  eval "${cmds[$cmd]}"
}

_fzf_get_path_using_fd() {
  local input_path=$(
    fd --type file |
    fzf --prompt 'Files> ' \
      --header 'CTRL-S: Switch between Files/Directories' \
    --bind 'ctrl-s:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
        echo "change-prompt(Files> )+reload(fd --type file)" ||
    echo "change-prompt(Directories> )+reload(fd --type directory)"' \
      --preview '[[ $FZF_PROMPT =~ Files ]] && bat --color=always --style=plain {} || tree -C {}'
  )
  echo "$input_path"
}

_fzf_get_path_using_rg() {
  rm -f /tmp/rg-fzf-{r,f}
  local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  local INITIAL_QUERY="${*:-}"
  local input_path=$(
    fzf --ansi --disabled \
      --query="$INITIAL_QUERY" \
      --bind="enter:become(echo {1})" \
      --bind="start:reload:$RG_PREFIX {q}" \
      --bind="change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind='ctrl-s:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
      echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
    echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
      --color='hl:-1:underline,hl+:-1:underline:reverse' \
      --prompt='1. ripgrep> ' \
      --delimiter=':' \
      --header='CTRL-S: Switch between ripgrep/fzf' \
      --preview='bat --color=always {1} --highlight-line {2} --style=plain' \
      --preview-window='up,60%,border-bottom,+{2}+3/3'
  )
  echo "$input_path"
}

fdg() {
  _fzf_open_path "$(_fzf_get_path_using_fd)"
}

rgg() {
  _fzf_open_path "$(_fzf_get_path_using_rg)"
}

zle -N fdg
zle -N rgg

bindkey '^f' fdg
bindkey '^g' rgg
bindkey '^d' fdg
