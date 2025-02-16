#!/bin/bash

WALLPAPER_PATH="$HOME/assets/images/wallpaper/arch-catppuccin-FHD.png"
IS_PNG=$([[ "${WALLPAPER_PATH##*.}" -eq 'png' ]])
CACHE_DIR=${XDG_CACHE_HOME:-~/.cache}

cp -rf "$HOME/.config/sddm/themes/catppuccin-mocha" "$CACHE_DIR/catppuccin-mocha"

sed -i 's/CustomBackground="false"/CustomBackground="true"/' "$CACHE_DIR/catppuccin-mocha/theme.conf"

if [[ "${WALLPAPER_PATH##*.}" == 'png' ]]; then
  sed -i 's/Background="backgrounds\/wall.jpg"/Background="backgrounds\/wall.png"/' "$CACHE_DIR/catppuccin-mocha/theme.conf"
fi

cp "$WALLPAPER_PATH" "$CACHE_DIR/catppuccin-mocha/backgrounds/wall.png"

sudo rm '/usr/share/sddm/themes/catppuccin-mocha/' -rf || true
# sudo ln -s "$HOME/.config/sddm/themes/catppuccin-mocha" '/usr/share/sddm/themes/catppuccin-mocha' # Cannot symlink
sudo cp -rf "$CACHE_DIR/catppuccin-mocha" '/usr/share/sddm/themes/'

rm "$CACHE_DIR/catppuccin-mocha/" -rf

echo "
Edit '/etc/sddm.conf/'

[Theme]
Current=catppuccin-mocha
"
