#!/usr/bin/env bash
set -uo pipefail
url="https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMono-NF-CN-unhinted.zip"
sha256="ab88522932cf4015dffeaef6dedc59a22a5fefecdcc6e583d9fcd997da5b7cac"
fontdir="$HOME/.fonts"
[ "$(uname -s)" = "Darwin" ] && fontdir="$HOME/Library/Fonts"
if command -v fc-list >/dev/null 2>&1 && fc-list 2>/dev/null | grep -qi "maple mono nf cn"; then
  exit 0
fi
tmp="$(mktemp -d)" || exit 0
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/maple.zip" 2>/dev/null || exit 0
if command -v sha256sum >/dev/null 2>&1; then
  echo "$sha256  $tmp/maple.zip" | sha256sum -c - >/dev/null 2>&1 || exit 0
elif command -v shasum >/dev/null 2>&1; then
  echo "$sha256  $tmp/maple.zip" | shasum -a 256 -c - >/dev/null 2>&1 || exit 0
fi
mkdir -p "$fontdir"
unzip -o -j "$tmp/maple.zip" "*.ttf" -d "$fontdir" >/dev/null 2>&1 || exit 0
command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$fontdir" >/dev/null 2>&1
exit 0
