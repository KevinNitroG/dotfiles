#!/usr/bin/env bash

if ! rclone --version &>/dev/null; then
  echo "Rclone isn't installed"
  exit 1
fi

MOUNT_POINT="$HOME/mnt/rclone/"
ARGS=(
  '--buffer-size=512M'
  '--daemon'
  '--ignore-checksum'
  '--metadata'
  '--no-modtime'
  '--transfers=8'
  '--vfs-cache-max-age=72h'
  '--vfs-cache-mode=full'
)

drive=$(rclone listremotes | fzf --border-label 'Select a remote to mount')

mkdir -p "$MOUNT_POINT"

rclone mount "$drive" "$MOUNT_POINT" "${ARGS[@]}"
