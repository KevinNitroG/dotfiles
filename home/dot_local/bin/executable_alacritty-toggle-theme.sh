#!/bin/bash

ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"

if grep -q "mocha" "$ALACRITTY_CONFIG"; then
  sed -i "s/mocha/latte/" "$ALACRITTY_CONFIG"
else
  sed -i "s/latte/mocha/" "$ALACRITTY_CONFIG"
fi
