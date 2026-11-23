#!/usr/bin/env bash
# Polls a command and exits the first time its output changes, printing the change.
# Usage: waitfor.sh [-i SECONDS] [-u] [-A] [-s FILE] -- COMMAND [ARGS...]
#   COMMAND prints one fact per line.
#   -i  poll interval in seconds (60)
#   -u  exit on the first non-empty output instead of the first change ("until")
#   -A  a line that appeared or changed is an event, a line that vanished is not. So COMMAND
#       can drop a fact while it is unsettled, like a running CI. A line that was gone for one
#       poll and came back is a flap, not an event.
#   -s  state file. Each poll saves its output there and the previous output in FILE.2, so a
#       restart continues from where the last run stopped.
#   Each new or changed line prints as "CHANGED: <line>", each vanished line as "GONE: <line>".
#   A poll that fails or prints nothing is skipped, so a flaky poll never looks like a change.
#   ONCE=1 prints what one poll sees and exits, to check COMMAND.
set -u

interval=60
until=
additions=
statefile=
while [[ $# -gt 0 ]]; do
  case $1 in
    -i) interval=$2; shift 2 ;;
    -u) until=1; shift ;;
    -A) additions=1; shift ;;
    -s) statefile=$2; shift 2 ;;
    --) shift; break ;;
    *) break ;;
  esac
done
[[ $# -gt 0 ]] || { echo "usage: $0 [-i SECONDS] [-u] [-A] [-s FILE] -- COMMAND [ARGS...]" >&2; exit 2; }

poll() { "$@" 2>/dev/null; }
next_state() { until cur=$(poll "$@") && [[ -n $cur ]]; do sleep "$interval"; done; }

if [[ -n ${ONCE:-} ]]; then
  poll "$@"
  exit 0
fi
if [[ -n $until ]]; then
  next_state "$@"
  printf '%s\n' "$cur"
  exit 0
fi

prev2=
if [[ -n $statefile && -s $statefile ]]; then
  prev=$(<"$statefile")
  [[ -s $statefile.2 ]] && prev2=$(<"$statefile.2")
else
  next_state "$@"
  prev=$cur
  [[ -n $statefile ]] && printf '%s\n' "$prev" >"$statefile"
  sleep "$interval"
fi

remember() {
  [[ -n $statefile ]] || return 0
  printf '%s\n' "$prev" >"$statefile.2"
  printf '%s\n' "$cur" >"$statefile"
}

report() {
  local out
  out=$(diff <(printf '%s\n' "$prev") <(printf '%s\n' "$cur") | sed -n -e 's/^> /CHANGED: /p' -e 's/^< /GONE: /p')
  if [[ -n $additions ]]; then
    out=$(grep '^CHANGED: ' <<<"$out" | while IFS= read -r line; do
      grep -qxF -- "${line#CHANGED: }" <<<"$prev2" || printf '%s\n' "$line"
    done)
  fi
  [[ -n $out ]] && printf '%s\n' "$out"
}

while :; do
  next_state "$@"
  remember
  report && exit 0
  prev2=$prev
  prev=$cur
  sleep "$interval"
done
