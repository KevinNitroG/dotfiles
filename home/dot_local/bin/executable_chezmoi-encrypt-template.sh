#!/usr/bin/env bash
# Encrypt a file into home/.chezmoitemplates/ for ALL age recipients.
#
# `chezmoi re-add` does not touch .chezmoitemplates/, so those files have to be
# re-encrypted by hand whenever the recipient list changes.
#
# Usage:
#   chezmoi-encrypt-template.sh <plaintext-file> <template-path>
#   chezmoi-encrypt-template.sh ~/.config/rclone/rclone.conf rclone/encrypted_rclone.conf

set -euo pipefail

if [ "$#" -ne 2 ]; then
  sed -n '2,10p' "$0"
  exit 1
fi

src="$1"
dest="$(chezmoi source-path)/.chezmoitemplates/$2"

mapfile -t recipients < <(chezmoi data --format json | jq -r '.ageRecipients[]')

args=()
for r in "${recipients[@]}"; do
  args+=(-r "$r")
done

mkdir -p "$(dirname "$dest")"
age -a "${args[@]}" -o "$dest" "$src"
echo "encrypted $src -> $dest (${#recipients[@]} recipients)"
