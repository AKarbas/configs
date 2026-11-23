#!/usr/bin/env bash
# jj workspaces of the current repo that no tmux session sits in, with their @ state.
# Paths follow jwa in scripts/jj-workspaces.zsh.
# Usage: jwidle.sh
set -uo pipefail
main=$(jj root) || exit 1
[[ -f $main/.jj/repo ]] && main=$(cd "$main/.jj" && realpath "$(<repo)/../..")
repo=$(basename "$main")
busy=$(tmux list-panes -a -F '#{pane_current_path}' 2>/dev/null | sort -u)
for ws in $(jj workspace list | cut -d: -f1); do
  root=$main
  dir=${JJ_WORKSPACES_DIR:-$HOME/.jj-workspaces}
  [[ $ws == default ]] || { root=$dir/$repo-$ws; [[ -d $root ]] || root=$dir/$ws; }
  grep -qxF -- "$root" <<<"$busy" && continue
  state=$(jj --ignore-working-copy log -r "$ws@" --no-graph -T 'if(empty, "empty", "HAS DIFF") ++ " " ++ description.first_line()' 2>&1)
  printf '%-12s %s  %s\n' "$ws" "$root" "$state"
done
