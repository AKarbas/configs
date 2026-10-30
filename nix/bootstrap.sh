#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

FLOX_CACHE_CONF=(
  --extra-conf "extra-substituters = https://cache.flox.dev"
  --extra-conf "extra-trusted-public-keys = flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
)

main() {
  install_nix
  load_nix_into_shell

  if is_darwin; then
    bootstrap_darwin
  else
    echo "==> Running make hm (standalone home-manager)"
    make hm
  fi
}

is_darwin() {
  [[ "$(uname)" == "Darwin" ]]
}

install_nix() {
  echo "==> Installing Nix (Determinate Systems installer)"
  if command -v nix &>/dev/null; then
    echo "    Nix already installed, skipping"
    return
  fi
  local install_args=(install)
  if is_darwin; then
    install_args=(install macos --case-sensitive --extra-conf "use-case-hack = false")
  fi
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
    sh -s -- "${install_args[@]}" "${FLOX_CACHE_CONF[@]}"
}

load_nix_into_shell() {
  if ! command -v nix &>/dev/null; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

bootstrap_darwin() {
  echo "==> Installing Homebrew"
  if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "    Homebrew already installed, skipping"
  fi

  # Build while the installer's nix.custom.conf (flox cache) is still in place.
  echo "==> Running make darwin-build"
  make darwin-build
  if [[ -f /etc/nix/nix.custom.conf && ! -L /etc/nix/nix.custom.conf ]]; then
    sudo mv /etc/nix/nix.custom.conf{,.before-nix-darwin}
  fi

  echo "==> Running make darwin"
  make darwin

  echo ""
  echo "==> Done! Manual steps remaining:"
  echo "  - Import Raycast settings: open Raycast, run 'Import Settings & Data', select common/home/dotfiles/raycast/export.rayconfig"
  echo "  - Sync Zed config: run 'make zed-push' (zed config is not auto-deployed)"
}

main "$@"
