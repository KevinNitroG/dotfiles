#!/bin/env zsh

if [ -f "$HOME/.zshenv" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.zshenv"
fi

if [ -z "$DUCKDNS_TOKEN" ]; then
  echo "\$DUCKDNS_TOKEN is not set"
  exit 1
fi

if [ -z "$DUCKDNS_DOMAIN" ]; then
  echo "\$DUCKDNS_DOMAIN is not set"
  exit 1
fi

curl -m 10 "https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}"
