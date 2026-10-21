#!/bin/bash
set -euo pipefail

# Usage: ./bootstrap.sh [--rebuild [--dry-run]]
#   --rebuild  macOS: reinstall /nix case-sensitive; --dry-run prints the steps.

cd "$(dirname "$0")"

FLOX_CACHE_CONF=(
  --extra-conf "extra-substituters = https://cache.flox.dev"
  --extra-conf "extra-trusted-public-keys = flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
)
FLAKEHUB_TOKEN_BACKUP="$HOME/.flakehub-token.before-rebuild"

main() {
  local rebuild="" dry_run=""
  for arg in "$@"; do
    case "$arg" in
      --rebuild) rebuild=1 ;;
      --dry-run) dry_run=1 ;;
      *)
        echo "Unknown argument: $arg" >&2
        exit 2
        ;;
    esac
  done
  if [[ -n $dry_run && -z $rebuild ]]; then
    echo "--dry-run only applies to --rebuild" >&2
    exit 2
  fi

  if [[ -n $rebuild ]]; then
    rebuild_nix_store "$dry_run"
  fi

  install_nix
  load_nix_into_shell
  restore_flakehub_token

  if is_darwin; then
    bootstrap_darwin
  else
    echo "==> Running make hm (standalone home-manager)"
    make hm
  fi
}

rebuild_nix_store() {
  local dry_run=$1
  if ! is_darwin; then
    echo "--rebuild is macOS-only" >&2
    exit 2
  fi
  # The clean shell require_no_ancestor_uses_nix asks for has no nix or /usr/sbin on PATH.
  export PATH="/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  if [[ ! -e /nix/receipt.json ]]; then
    echo "==> No Nix install found, so nothing to delete"
    return
  fi
  if nix_store_is_case_sensitive; then
    echo "==> /nix is already case-sensitive, so there is nothing to rebuild"
    exit 0
  fi

  require_no_ancestor_uses_nix
  echo "==> Checking that this machine's config builds and the installer is reachable"
  make darwin-build
  curl --proto '=https' --tlsv1.2 -sSfIL https://install.determinate.systems/nix >/dev/null

  print_rebuild_plan
  list_processes_using_nix
  if [[ -n $dry_run ]]; then
    exit 0
  fi
  confirm_hostname

  save_flakehub_token
  echo "==> Removing nix-darwin"
  sudo /run/current-system/sw/bin/darwin-uninstaller </dev/null
  echo "==> Removing Nix and the /nix volume"
  sudo /nix/nix-installer uninstall --no-confirm
  hash -r
}

require_no_ancestor_uses_nix() {
  local nix_pids pid=$$
  nix_pids=" $({ sudo lsof -t -n /nix 2>/dev/null || true; } | tr '\n' ' ') "
  while [[ $pid -gt 1 ]]; do
    if [[ $nix_pids == *" $pid "* ]]; then
      echo "$(ps -o comm= -p "$pid") (PID $pid) runs this script and uses /nix, so it would die mid-rebuild." >&2
      echo "Run it from a new terminal window, after: exec env -i HOME=\"\$HOME\" TERM=\"\$TERM\" /bin/bash --noprofile --norc" >&2
      exit 1
    fi
    pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
  done
}

print_rebuild_plan() {
  cat <<EOF
==> --rebuild fixes Linux builds on this Mac, which fail on packages with file
    names that differ only in case (e.g. the NixOS ISO). It will:
    1. Save the FlakeHub login to $FLAKEHUB_TOKEN_BACKUP
    2. Remove nix-darwin (restores the /etc files it replaced)
    3. Remove Nix and delete /nix: all store paths, system generations and dev
       shells. Everything re-downloads, so the machine is out of use for a while.
    4. Install Nix on a case-sensitive volume
    5. Restore the FlakeHub login and the native Linux builder
    6. Build and switch to this machine's config
    Flox environments re-download on their next activation.
    If it stops after step 3, run ./bootstrap.sh (without --rebuild) to finish.
EOF
}

list_processes_using_nix() {
  local pids processes
  pids=$({ lsof -t -n -a -u "$(id -un)" /nix 2>/dev/null || true; } | sort -u | paste -sd, -)
  if [[ -z $pids ]]; then
    return
  fi
  processes=$(ps -o pid=,comm= -p "$pids" | grep -v -e /Finder -e /UserEventAgent || true)
  if [[ -n $processes ]]; then
    echo "==> These processes use /nix and crash when it is deleted. Quit them first:"
    echo "$processes"
  fi
}

confirm_hostname() {
  local host answer
  host=$(scutil --get LocalHostName)
  read -r -p "Type this machine's name ($host) to delete /nix and rebuild: " answer
  if [[ $answer != "$host" ]]; then
    echo "Aborted. Nothing changed."
    exit 1
  fi
}

save_flakehub_token() {
  if [[ -s /nix/var/determinate/token ]]; then
    echo "==> Saving the FlakeHub login to $FLAKEHUB_TOKEN_BACKUP"
    sudo install -m 600 -o "$(id -un)" /nix/var/determinate/token "$FLAKEHUB_TOKEN_BACKUP"
  fi
}

is_darwin() {
  [[ "$(uname)" == "Darwin" ]]
}

nix_store_is_case_sensitive() {
  /usr/sbin/diskutil info /nix | grep -q 'Case-sensitive'
}

install_nix() {
  echo "==> Installing Nix (Determinate Systems installer)"
  if command -v nix &>/dev/null; then
    echo "    Nix already installed, skipping"
    warn_if_nix_store_case_insensitive
    return
  fi
  local install_args=(install)
  if is_darwin; then
    install_args=(install macos --case-sensitive --extra-conf "use-case-hack = false")
  fi
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
    sh -s -- "${install_args[@]}" "${FLOX_CACHE_CONF[@]}"
}

warn_if_nix_store_case_insensitive() {
  if is_darwin && ! nix_store_is_case_sensitive; then
    echo "    WARNING: /nix is case-insensitive, so some Linux builds fail. See ./bootstrap.sh --rebuild --dry-run" >&2
  fi
}

load_nix_into_shell() {
  if ! command -v nix &>/dev/null; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

restore_flakehub_token() {
  if [[ ! -f $FLAKEHUB_TOKEN_BACKUP ]]; then
    return
  fi
  echo "==> Restoring the FlakeHub login and the native Linux builder"
  if /usr/local/bin/determinate-nixd auth login token --token-file "$FLAKEHUB_TOKEN_BACKUP" &&
    sudo /usr/local/bin/determinate-nixd init; then
    rm "$FLAKEHUB_TOKEN_BACKUP"
  else
    echo "    Failed. Kept $FLAKEHUB_TOKEN_BACKUP; run 'determinate-nixd auth login', then 'sudo determinate-nixd init'." >&2
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
