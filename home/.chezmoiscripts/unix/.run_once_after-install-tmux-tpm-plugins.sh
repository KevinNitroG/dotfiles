#!/usr/bin/env bash

export TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins/"

if [ ! -d "$TMUX_PLUGIN_MANAGER_PATH" ]; then
  echo "TMUX plugin manager not found; skipping plugin install"
  exit 0
else
  echo "TMUX plugin manager found; proceeding with plugin install"
fi

~/.config/tmux/plugins/tpm/scripts/install_plugins.sh
