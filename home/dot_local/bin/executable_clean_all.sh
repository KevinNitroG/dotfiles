#!/bin/bash

has() {
  command -v "$1" >/dev/null
}

if has pacman; then
  printf "\nCLEAN PACMAN...\n"
  sudo pacman -Scc
fi

if has flatpak; then
  printf "\nCLEAN FLATPAK...\n"
  flatpak uninstall --unused
fi
