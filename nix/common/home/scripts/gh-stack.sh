#!/usr/bin/env bash
# GitHub PR stack, one per jj commit. Titles, bodies and bases update in place.
# Works in jj workspaces. gh-stack [revset]. default: trunk()..@ ~ empty().
set -euo pipefail

range=${1:-'trunk()..@ ~ empty()'}
user=${GH_STACK_USER:-${USER:-$(id -un)}}

ws_root=$(jj root)
if [[ -f "$ws_root/.jj/repo" ]]; then
  main_root=$(dirname "$(dirname "$(cat "$ws_root/.jj/repo")")")
else
  main_root=$ws_root
fi
gh_main() { (cd "$main_root" && gh "$@"); }

prev_branch=main
for change in $(jj log -r "$range" --no-graph --reversed -T 'change_id.short() ++ "\n"'); do
  branch="stack/${user}/${change}"
  title=$(jj log -r "$change" --no-graph -T 'description.first_line()')
  body=$(jj log -r "$change" --no-graph -T 'description' | tail -n +2 | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

  jj bookmark set "$branch" -r "$change" --allow-backwards
  jj git push --bookmark "$branch" --allow-new

  if base=$(gh_main pr view "$branch" --json baseRefName --jq .baseRefName 2>/dev/null); then
    args=(--title "$title" --body "$body")
    [[ "$base" == "$prev_branch" ]] || args+=(--base "$prev_branch")
    gh_main pr edit "$branch" "${args[@]}"
    echo "updated $(gh_main pr view "$branch" --json url --jq .url) <- $prev_branch"
  else
    gh_main pr create --head "$branch" --base "$prev_branch" --fill
  fi

  prev_branch=$branch
done
