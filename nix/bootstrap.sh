#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

FLOX_CACHE_SETTINGS=(
  "extra-substituters = https://cache.flox.dev"
  "extra-trusted-public-keys = flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
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

install_nix() {
  if command -v nix &>/dev/null; then
    echo "==> Nix already installed, skipping"
  elif is_darwin; then
    install_nix_multi_user install macos --case-sensitive --extra-conf "use-case-hack = false"
  elif has_systemd; then
    install_nix_multi_user install
  else
    install_nix_single_user
  fi
}

install_nix_multi_user() {
  echo "==> Installing Nix (Determinate Systems installer)"
  local setting extra_conf=()
  for setting in "${FLOX_CACHE_SETTINGS[@]}"; do
    extra_conf+=(--extra-conf "$setting")
  done
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
    sh -s -- "$@" "${extra_conf[@]}"
}

has_systemd() {
  [[ -d /run/systemd/system ]]
}

# Without systemd, the multi-user daemon cannot run. The user owns the store
# instead.
install_nix_single_user() {
  echo "==> Installing Nix single-user (no systemd)"
  mkdir -p ~/.config/nix
  printf '%s\n' "experimental-features = nix-command flakes" "${FLOX_CACHE_SETTINGS[@]}" \
    >>~/.config/nix/nix.conf
  curl --proto '=https' --tlsv1.2 -sSf -L https://nixos.org/nix/install |
    sh -s -- --no-daemon --no-channel-add
}

is_darwin() {
  [[ "$(uname)" == "Darwin" ]]
}

load_nix_into_shell() {
  if command -v nix &>/dev/null; then
    return
  elif [[ -e ~/.nix-profile/etc/profile.d/nix.sh ]]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
  else
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
