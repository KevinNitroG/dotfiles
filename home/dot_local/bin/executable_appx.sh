#!/bin/bash

FZF_DEFAULT_OPTS+="
--bind ctrl-a:toggle-all
--header-first
--preview-label INFO
--preview-window right,70%
"

show_help() {
  cat <<EOF
Description: Install, update, uninstall apps.

Require: fzf
Author: Kevin Nitro (KevinNitroG), Claude, Copilot

Usage: ${0} [OPTION]...
Options:
  -i, --install           Install apps
  -u, --update            Update apps
  -U, --uninstall         Uninstall apps
  -UU, --uninstall-clean  Uninstall apps and clean dependencies (But watch out!)
  -f, --fetch             Fetch updates for package repositories (priority)
  -p, --package-manager   Specify package manager
                            [pacman|yay|apt|dnf|snap|flatpak]
  -h, --help              Display this help

Examples:
  ${0} -i
  ${0} -u -f
  ${0} -U
EOF
}

_has() {
  command -v "$1" >/dev/null 2>&1
}

_get_distro() {
  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "$ID"
  elif [ -f /etc/lsb-release ]; then
    # shellcheck disable=SC1091
    . /etc/lsb-release
    echo "$DISTRIB_ID"
  else
    echo "Unknown"
  fi
}

_get_package_manager() {
  local distro
  distro=$(_get_distro)
  case "$distro" in
  'arch')
    if _has yay; then
      package_manager="yay"
    else
      package_manager="pacman"
    fi
    ;;
  'ubuntu' | 'debian')
    package_manager="apt"
    ;;
  'fedora' | 'centos' | 'rhel')
    package_manager="dnf"
    ;;
  *)
    echo "Error: Unsupported distribution: \"$distro\". Please specify a package manager with -p or --package-manager" >&2
    exit 1
    ;;
  esac
  echo "$package_manager"
}

_pacman_manage() {
  local action=$1
  case "$action" in
  'install')
    pacman -Slq | fzf --multi --header 'INSTALL APPS' --preview 'pacman -Sii {1}' | xargs -ro sudo pacman -S --needed
    ;;
  'update')
    pacman -Quq | fzf --multi --header 'UPDATE APPS' --preview 'pacman -Sii {1}' | xargs -ro sudo pacman -S --needed
    ;;
  'uninstall')
    pacman -Qq | fzf --multi --header 'UNINSTALL APPS' --preview 'pacman -Qii {1}' | xargs -ro sudo pacman -Rs --confirm
    ;;
  'uninstall-clean')
    pacman -Qq | fzf --multi --header 'UNINSTALL APPS' --preview 'pacman -Qii {1}' | xargs -ro yay -Rssucn --confirm
    ;;
  'fetch')
    sudo pacman -Sy
    ;;
  esac
}

_yay_manage() {
  local action=$1
  case "$action" in
  'install')
    yay -Slq | sort -u | fzf --multi --header 'INSTALL APPS' --preview 'yay -Sii {1}' | xargs -ro yay -S --needed
    ;;
  'update')
    yay -Quq | fzf --multi --header 'UPDATE APPS' --preview 'yay -Sii {1}' | xargs -ro yay -S --needed
    ;;
  'uninstall')
    yay -Qq | fzf --multi --header 'UNINSTALL APPS' --preview 'yay -Qii {1}' | xargs -ro yay -Rs --confirm
    ;;
  'uninstall-clean')
    yay -Qq | fzf --multi --header 'UNINSTALL APPS' --preview 'yay -Qii {1}' | xargs -ro yay -Rssucn --confirm
    ;;
  'fetch')
    yay -Sy
    ;;
  esac
}

# WARNING: WIP
_apt_manage() {
  local action=$1
  case "$action" in
  'install')
    apt list | fzf --multi --header 'INSTALL APPS' --preview 'apt show {1}' | xargs -ro sudo apt install
    ;;
  'update')
    apt list --upgradable | fzf --multi --header 'UPDATE APPS' --preview 'apt show {1}' | xargs -ro sudo apt upgrade
    ;;
  'uninstall')
    apt list --installed | fzf --multi --header 'UNINSTALL APPS' --preview 'apt show {1}' | xargs -ro sudo apt remove
    ;;
  'uninstall-clean')
    apt list --installed | fzf --multi --header 'UNINSTALL APPS' --preview 'apt show {1}' | xargs -ro sudo apt remove && sudo apt --purge autoremove
    ;;
  'fetch')
    sudo apt update
    ;;
  esac
}

# WARNING: WIP
_dnf_manage() {
  local action=$1
  case "$action" in
  'install')
    dnf list available | fzf --multi --header 'INSTALL APPS' --preview 'dnf info {1}' | xargs -ro sudo dnf install
    ;;
  'update')
    dnf list upgrades | fzf --multi --header 'UPDATE APPS' --preview 'dnf info {1}' | xargs -ro sudo dnf upgrade
    ;;
  'uninstall')
    dnf list installed | fzf --multi --header 'UNINSTALL APPS' --preview 'dnf info {1}' | xargs -ro sudo dnf remove
    ;;
  'uninstall-clean')
    dnf list installed | fzf --multi --header 'UNINSTALL APPS' --preview 'dnf info {1}' | xargs -ro sudo dnf remove && sudo dnf autoremove
    ;;
  'fetch')
    sudo dnf check-update
    ;;
  esac
}

# WARNING: WIP
_snap_mange() {
  local action=$1
  case "$action" in
  'install')
    snap find | fzf --multi --header 'INSTALL APPS' --preview 'snap info {1}' | xargs -ro sudo snap install
    ;;
  'update')
    snap list | tail -n +2 | fzf --multi --header 'UPDATE APPS' --preview 'snap info {1}' | xargs -ro sudo snap refresh
    ;;
  'uninstall' | 'uninstall-clean')
    snap list | tail -n +2 | fzf --multi --header 'UNINSTALL APPS' --preview 'snap info {1}' | xargs -ro sudo snap remove
    ;;
  'fetch')
    sudo snap refresh --list
    ;;
  esac
}

_flatpak_manage() {
  local action=$1
  case "$action" in
  'install')
    flatpak remote-ls --app --columns application | tail -n +1 | fzf --multi --header 'INSTALL APPS' | xargs -ro flatpak install
    ;;
  'update')
    flatpak list --columns application | tail -n +1 | fzf --multi --header 'UPDATE APPS' --preview 'flatpak info {1}' | xargs -ro flatpak update
    ;;
  'uninstall' | 'uninstall-clean')
    flatpak list --columns application | tail -n +1 | fzf --multi --header 'UNINSTALL APPS' --preview 'flatpak info {1}' | xargs -ro flatpak uninstall
    ;;
  'fetch')
    flatpak update --appstream
    ;;
  esac
}

_manage() {
  local package_manager=$1
  local action=$2
  case "$package_manager" in
  'pacman')
    _pacman_manage "$action"
    ;;
  'yay')
    _yay_manage "$action"
    ;;
  'apt')
    _apt_manage "$action"
    ;;
  'dnf')
    _dnf_manage "$action"
    ;;
  'snap')
    _snap_mange "$action"
    ;;
  'flatpak')
    _flatpak_manage "$action"
    ;;
  *)
    echo "Unsupported package manager: $package_manager" >&2
    exit 1
    ;;
  esac
}

main() {
  local actions=()
  local package_manager=""
  local need_fetch=false
  while [[ $# -gt 0 ]]; do
    case $1 in
    -i | --install)
      actions+=('install')
      shift
      ;;
    -u | --update)
      actions+=('update')
      shift
      ;;
    -U | --uninstall)
      actions+=('uninstall')
      shift
      ;;
    -UU | --uninstall-clean)
      actions+=('uninstall-clean')
      shift
      ;;
    -f | --fetch)
      need_fetch=true
      shift
      ;;
    -p | --package-manager)
      if [[ -n "$2" ]]; then
        package_manager=$2
        shift 2
      else
        echo 'Error: Package manager not specified after -p or --package-manager' >&2
        exit 1
      fi
      ;;
    -h | --help)
      show_help
      exit 0
      ;;
    *)
      echo "Error: Unknown option \"$1\"" >&2
      show_help
      exit 1
      ;;
    esac
  done

  if [ ${#actions[@]} -eq 0 ]; then
    show_help
    exit 0
  fi

  if ! _has fzf; then
    echo 'Error: fzf is not installed. Please install fzf to use this script.' >&2
    exit 1
  fi

  if [ -z "$package_manager" ]; then
    package_manager=$(_get_package_manager)
  fi

  if [ "$need_fetch" = true ]; then
    _manage "$package_manager" 'fetch'
  fi

  for action in "${actions[@]}"; do
    _manage "$package_manager" "$action"
  done
}

main "$@"
