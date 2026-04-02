#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Nix (Determinate Systems installer)"
if ! command -v nix &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install \
    --extra-conf "extra-trusted-substituters = https://cache.flox.dev" \
    --extra-conf "extra-substituters = https://cache.flox.dev" \
    --extra-conf "extra-trusted-public-keys = flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
else
  echo "    Nix already installed, skipping"
fi

echo "==> Installing Homebrew"
if ! command -v brew &>/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "    Homebrew already installed, skipping"
fi

echo "==> Running make darwin"
make darwin

echo ""
echo "==> Done! Manual steps remaining:"
echo "  - Configure iGlance menu bar items manually"
echo "  - Import Raycast settings: open Raycast, run 'Import Settings & Data', select common/home/dotfiles/raycast/export.rayconfig"
