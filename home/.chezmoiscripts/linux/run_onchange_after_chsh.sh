#!/usr/bin/env bash

if [[ "$SHELL" =~ .*zsh$ ]]; then
  exit 0
fi

chsh -s "$(which zsh)"
