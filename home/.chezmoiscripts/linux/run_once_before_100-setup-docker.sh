#!/usr/bin/env bash

set -eufo pipefail

if ! command -v docker &>/dev/null; then
  exit
fi

echo "SETTING UP DOCKER..."
sudo rm "$HOME/.docker/" -rf || true
sudo groupadd docker || true
sudo usermod -aG docker "$USER"
