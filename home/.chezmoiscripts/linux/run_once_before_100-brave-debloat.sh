#!/usr/bin/env bash

if ! command -v brave &>/dev/null; then
  exit 0
fi

sudo curl 'https://raw.githubusercontent.com/MulesGaming/brave-debullshitinator/refs/heads/main/policies.json' --remote-name --create-dirs --output-dir '/etc/brave/policies/managed'
