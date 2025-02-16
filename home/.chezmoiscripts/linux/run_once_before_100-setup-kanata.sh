#!/usr/bin/env bash

set -eufo pipefail

if ! command -v crontab &>/dev/null; then
  exit
fi

echo "SETTING UP KANATA..."
sudo groupadd uinput || true
sudo usermod -aG input "$USER" || true
sudo usermod -aG uinput "$USER" || true
RULE='KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"'
FILE='/etc/udev/rules.d/99-input.rules'
if ! grep -Fxq "$RULE" "$FILE"; then
  echo "$RULE" | sudo tee -a "$FILE"
fi
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo modprobe uinput || echo 'please run "sudo modprobe uinput" for the first time run kanata'
systemctl --user enable kanata.service || echo 'Cannot enable kanata service. Try to enable manually :)'
