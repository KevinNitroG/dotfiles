#!/usr/bin/env bash

if ! command -v spotify &>/dev/null; then
  exit
fi

echo 'PATCHING SPOTIFY USING SPOTX...'
bash <(curl -sSL https://spotx-official.github.io/run.sh) --blockupdates || true
