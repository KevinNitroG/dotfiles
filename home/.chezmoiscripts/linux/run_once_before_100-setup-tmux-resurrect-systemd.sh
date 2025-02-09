#!/usr/bin/env bash

if ! command -v tmux &>/dev/null || [ ! -f "$HOME/.config/systemd/user/tmux.service" ]; then
  exit
fi

echo 'SETTING UP TMUX RESURRECT SYSTEMD...'
systemctl --user enable tmux.service
