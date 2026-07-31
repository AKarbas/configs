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

# The installer only edits shell rc files, so the current shell does not see
# nix yet. Source the profile script to make it usable in this same run.
if ! command -v nix &>/dev/null; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if [[ "$(uname)" == "Darwin" ]]; then
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
  echo "  - Import Raycast settings: open Raycast, run 'Import Settings & Data', select common/home/dotfiles/raycast/export.rayconfig"
  echo "  - Sync Zed config: run 'make zed-push' (zed config is not auto-deployed)"
else
  echo "==> Running make hm (standalone home-manager)"
  make hm
fi
