#!/usr/bin/env bash
# Blocks until a settled fact of the PRs changes, prints it, exits.
# Usage: prwatch.sh [-i SECONDS] [PR...]   (default: my open PRs)
set -u
interval=120
[[ ${1:-} == -i ]] && { interval=$2; shift 2; }
dir=${XDG_CACHE_HOME:-$HOME/.cache}/prwatch
mkdir -p "$dir"
here=$(dirname "$0")
exec "$here/waitfor.sh" -i "$interval" -A -s "$dir/${REX_BLOCK:-${CLAUDE_CODE_SESSION_ID:-default}}-$(IFS=-; echo "${*:-all}")" -- "$here/prstate.sh" -w "$@"
