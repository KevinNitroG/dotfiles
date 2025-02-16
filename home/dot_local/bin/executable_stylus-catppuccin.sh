#!/usr/bin/env bash

accent_color="${1:-lavender}"
light_flavor="${2:-latte}"
dark_flavor="${3:-mocha}"

URL="https://github.com/catppuccin/userstyles/releases/download/all-userstyles-export/import.json"
FILE_DIR="$HOME/.config/browser-data/stylus"
FILE_PATH="$FILE_DIR/catppuccin.json"

mkdir -p "$FILE_DIR"

if command -v curl &>/dev/null; then
  stylus=$(curl -L "$URL")
elif command -v wget &>/dev/null; then
  stylus=$(wget -q "$URL")
else
  >&2 echo "No curl or wget available!"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  >&2 echo "No jq available!"
  exit 2
fi

echo "$stylus" | jq --arg accent "$accent_color" \
  --arg light "$light_flavor" \
  --arg dark "$dark_flavor" \
  '.[1:].[].usercssData.vars.accentColor.value |= $accent |
                     .[1:].[].usercssData.vars.lightFlavor.value |= $light |
                     .[1:].[].usercssData.vars.darkFlavor.value |= $dark' >"$FILE_PATH"
