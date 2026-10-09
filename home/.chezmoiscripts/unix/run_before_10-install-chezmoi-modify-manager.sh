#!/usr/bin/env bash

set -eufo pipefail

bin="$HOME/.local/bin/chezmoi_modify_manager"
if [ -x "$bin" ] && "$bin" --version >/dev/null 2>&1; then
  exit 0
fi

case "$(uname -m)" in
  x86_64) arch="x86_64" ;;
  aarch64 | arm64) arch="aarch64" ;;
  i686 | i386) arch="i686" ;;
  armv7*) arch="armv7" ;;
  *) echo "chezmoi_modify_manager: unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
case "$(uname -s)" in
  Linux) platform="unknown-linux-gnu" ;;
  Darwin) platform="apple-darwin" ;;
  *) echo "chezmoi_modify_manager: unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
if [ "$arch" = "armv7" ]; then
  platform="unknown-linux-gnueabihf"
fi

tag="$(curl -fsSL -o /dev/null -w '%{url_effective}' https://github.com/VorpalBlade/chezmoi_modify_manager/releases/latest)"
tag="${tag##*/}"
url="https://github.com/VorpalBlade/chezmoi_modify_manager/releases/download/${tag}/chezmoi_modify_manager-${tag}-${arch}-${platform}.tar.gz"

mkdir -p "$HOME/.local/bin"
curl -fsSL "$url" | tar -xzf - -C "$HOME/.local/bin"
chmod 0755 "$bin"
"$bin" --version
