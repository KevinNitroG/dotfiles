#!/usr/bin/env bash

if [[ "$SHELL" =~ .*zsh$ ]]; then
  exit 0
fi

zsh_path="$(command -v zsh)"

if [[ -z "$zsh_path" ]]; then
  echo 'zsh is not installed; leaving the login shell alone'
  exit 0
fi

if ! chsh -s "$zsh_path"; then
  echo "could not change the login shell (no password prompt available?)"
  echo "  run it yourself later: chsh -s $zsh_path"
fi

exit 0
