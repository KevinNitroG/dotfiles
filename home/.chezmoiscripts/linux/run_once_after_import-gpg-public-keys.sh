#!/usr/bin/env bash

if ! command -v gpg &>/dev/null; then
  exit
fi
curl 'https://github.com/web-flow.gpg' | gpg --import
