#!/usr/bin/env bash

set -eufo pipefail

if ! command -v tlp &>/dev/null; then
  exit
fi

echo 'CONFIGURING TLP...'
sudo rm /etc/tlp.conf || true
sudo ln -s ~/.config/tlp/tlp.conf /etc/tlp.conf
sudo systemctl enable tlp.service
sudo systemctl start tlp.service

if command -v tlpRdw &>/dev/null; then
  sudo systemctl enable NetworkManager-dispatcher.service
fi

sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
