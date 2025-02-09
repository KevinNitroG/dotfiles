#!/usr/bin/env bash

set -eufo pipefail

if ! command -v rclone &>/dev/null; then
  exit
fi

echo "SETUP MOUNTING RCLONE DRIVE..."
mkdir -p "$HOME/mount/rclone-drives" || true
systemctl --user start rclone-drives
systemctl --user enable rclone-drives
