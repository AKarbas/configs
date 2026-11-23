#!/usr/bin/env bash
# jj workspaces of the current repo that no tmux or Rex pane sits in, with their @ state.
# Paths follow jwa in scripts/jj-workspaces.zsh.
# Usage: jwidle.sh
set -uo pipefail

# Panes on other hosts report paths on those hosts, so only this host's panes count.
rex_pane_cwds() {
  local host s b
  host=$(rex whoami --autostart=false --json 2>/dev/null | jq -r .host_id) || return 0
  for s in $(rex ls --autostart=false --json | jq -r '.sessions[].session_id'); do
    for b in $(rex block ls --autostart=false -s "$s" --json | jq -r --arg h "$host" '.blocks[] | select(.host_id == $h) | .block_id'); do
      rex block call --autostart=false -b "$b" process 2>/dev/null | jq -r '.foreground.cwd // empty'
    done
  done
}

main=$(jj root) || exit 1
[[ -f $main/.jj/repo ]] && main=$(cd "$main/.jj" && realpath "$(<repo)/../..")
repo=$(basename "$main")
busy=$({ tmux list-panes -a -F '#{pane_current_path}' 2>/dev/null; rex_pane_cwds; } | sort -u)
for ws in $(jj workspace list | cut -d: -f1); do
  root=$main
  dir=${JJ_WORKSPACES_DIR:-$HOME/.jj-workspaces}
  [[ $ws == default ]] || { root=$dir/$repo-$ws; [[ -d $root ]] || root=$dir/$ws; }
  grep -qxF -- "$root" <<<"$busy" && continue
  state=$(jj --ignore-working-copy log -r "$ws@" --no-graph -T 'if(empty, "empty", "HAS DIFF") ++ " " ++ description.first_line()' 2>&1)
  printf '%-12s %s  %s\n' "$ws" "$root" "$state"
done
