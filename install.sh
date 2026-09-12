#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIR="$DOTFILES_DIR/configs"
PACKAGE_DIR="$DOTFILES_DIR/packages"

echo "==> Dotfiles: $DOTFILES_DIR"

# -------------------------
# Install pacman packages
# -------------------------

install_package_file() {
  local file="$1"

  [[ -f "$file" ]] || return

  mapfile -t packages < <(
    grep -vE '^\s*(#|$)' "$file"
  )

  if ((${#packages[@]} > 0)); then
    sudo pacman -S --needed "${packages[@]}"
  fi
}

echo "==> Installing base packages"
install_package_file "$PACKAGE_DIR/pacman.txt"

echo "==> Installing Neovim dependencies"
install_package_file "$PACKAGE_DIR/nvim.txt"

# -------------------------
# Stow configs
# -------------------------

echo "==> Installing configs"

cd "$CONFIG_DIR"

for package in */; do
  package="${package%/}"

  echo "  -> $package"

  stow \
    --restow \
    --target="$HOME" \
    "$package"
done

echo
echo "==> Done"
