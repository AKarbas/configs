#!/usr/bin/env bash
# Polls a command and exits the first time its output changes, printing the change.
# Made for an agent's background command: one wake-up per event, nothing while idle.
#
# Usage: waitfor.sh [-i SECONDS] [-u] -- COMMAND [ARGS...]
#   COMMAND prints the watched state, one fact per line. Print only facts that
#   would change what the reader does, so a change is an event.
#   -i  poll interval in seconds (60)
#   -u  exit on the first non-empty output instead of the first change ("until")
#   Each new or changed line prints as "CHANGED: <line>", each vanished line as
#   "GONE: <line>". A run that fails or prints nothing is skipped, so a flaky poll
#   never looks like a change.
#   ONCE=1 prints the current state and exits, to check the command.
set -u

interval=60
until=
while [[ $# -gt 0 ]]; do
  case $1 in
    -i) interval=$2; shift 2 ;;
    -u) until=1; shift ;;
    --) shift; break ;;
    *) break ;;
  esac
done
[[ $# -gt 0 ]] || { echo "usage: $0 [-i SECONDS] [-u] -- COMMAND [ARGS...]" >&2; exit 2; }

prev=$("$@" 2>/dev/null) || prev=""
if [[ -n ${ONCE:-} ]]; then
  printf '%s\n' "$prev"
  exit 0
fi
if [[ -n $until && -n $prev ]]; then
  printf '%s\n' "$prev"
  exit 0
fi

while sleep "$interval"; do
  cur=$("$@" 2>/dev/null) || continue
  if [[ -n $until ]]; then
    [[ -z $cur ]] && continue
    printf '%s\n' "$cur"
    exit 0
  fi
  [[ -z $cur || $cur == "$prev" ]] && continue
  diff <(printf '%s\n' "$prev") <(printf '%s\n' "$cur") | sed -n -e 's/^> /CHANGED: /p' -e 's/^< /GONE: /p'
  exit 0
done
