#!/usr/bin/env bash
# Resumes a Rex pane's Claude conversation after Rex restores the pane, such as after a reboot.
# Usage:
#   rexresume.sh hook    Claude SessionStart and SessionEnd hook: saves the pane's conversation ID.
#   rexresume.sh resume  from the shell rc: resumes the saved conversation.
set -uo pipefail

[[ -n ${REX_BLOCK:-} ]] || exit 0
saved="${XDG_STATE_HOME:-$HOME/.local/state}/rexresume/${REX_BLOCK#block:}"

main() {
  case ${1:-} in
    hook) hook ;;
    resume) resume ;;
    *) echo "usage: rexresume.sh hook|resume" >&2; exit 2 ;;
  esac
}

hook() {
  local event session reason
  is_pane_claude "${CLAUDE_PID:-}" || return 0
  IFS=$'\t' read -r event session reason < <(jq -r '[.hook_event_name, .session_id, .reason // ""] | @tsv')
  case $event in
    SessionStart)
      mkdir -p "${saved%/*}"
      printf '%s\n' "$session" > "$saved"
      ;;
    SessionEnd)
      # "other" means Claude was killed, such as by a reboot.
      [[ $reason != other && -f $saved && $(<"$saved") == "$session" ]] && rm -f "$saved"
      ;;
  esac
  return 0
}

is_pane_claude() {
  local pgid tpgid
  read -r pgid tpgid < <(ps -o pgid=,tpgid= -p "$1") && [[ $pgid == "$tpgid" ]]
}

resume() {
  [[ -f $saved ]] || return 0
  local session
  session=$(<"$saved") && rm -f "$saved"
  exec claude --resume "$session"
}

main "$@"
