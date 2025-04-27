#!/usr/bin/env bash

set -eufo pipefail

if [ -d "$HOME/HyDE" ]; then
  exit 0
fi

git clone --depth 1 https://github.com/HyDE-Project/HyDE.git ~/HyDE
~/HyDE/Scripts/Install.sh
