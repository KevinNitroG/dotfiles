#!/usr/bin/env bash

set -eufo pipefail

if ! command -v crontab &>/dev/null; then
  exit
fi

echo "SETTING UP CRONTAB..."
crontab ~/.config/crontab/kevinnitro
