#!/usr/bin/env bash
# gh-stack [revset]   one PR per jj commit; reruns update title/body/base in place.
set -euo pipefail

main() {
  range=${1:-'trunk()..@ ~ empty()'}
  prefix="stack/${GH_STACK_USER:-${USER:-$(id -un)}}/"
  main_root=$(main_workspace_root)

  jj log --no-pager --no-graph -r "$range" -T '"+" ++ diff.stat().total_added() ++ " -" ++ diff.stat().total_removed() ++ " " ++ builtin_log_oneline'
  reject_commits "($range) & empty()" "empty commits in range"
  reject_commits "($range) & immutable()" "immutable commits in range"

  local prev_branch=main change branch
  for change in $(change_ids "$range"); do
    branch=$(branch_for "$change")
    push_bookmark "$branch" "$change"
    upsert_pr "$branch" "$change" "$prev_branch"
    prev_branch=$branch
  done
}

main_workspace_root() {
  local ws_root; ws_root=$(jj root)
  if [[ -f "$ws_root/.jj/repo" ]]; then
    dirname "$(dirname "$(cat "$ws_root/.jj/repo")")"
  else
    echo "$ws_root"
  fi
}

reject_commits() {
  local revset=$1 reason=$2 found
  found=$(change_ids "$revset")
  [[ -z "$found" ]] || die "$reason:"$'\n'"$found"
}

change_ids() {
  jj log --no-graph --reversed -r "$1" -T 'change_id.short() ++ "\n"'
}

branch_for() {
  local change=$1 existing
  existing=$(stack_bookmarks_on "$change")
  case $(grep -c . <<<"$existing") in
    0) new_branch "$change" ;;
    1) echo "$existing" ;;
    *) die "$change has several stack bookmarks:"$'\n'"$existing" ;;
  esac
}

stack_bookmarks_on() {
  jj log --no-graph -r "$1" -T 'bookmarks.map(|b| b.name() ++ "\n").join("")' \
    | { grep "^${prefix}" || true; } | sort -u
}

new_branch() {
  local change=$1 slug branch taken
  slug=$(title_of "$change" | tr -c 'a-zA-Z0-9' '-' | tr -s '-' | tr 'A-Z' 'a-z' | cut -c1-60 | sed 's/-$//')
  branch="${prefix}${slug}"
  taken=$(change_ids "present(bookmarks(exact:\"$branch\")) | present(remote_bookmarks(exact:\"$branch\"))")
  [[ -z "$taken" ]] || die "$branch already on $taken; retitle $change"
  echo "$branch"
}

push_bookmark() {
  local branch=$1 change=$2
  jj bookmark set "$branch" -r "$change" --allow-backwards
  jj git push --bookmark "$branch" --allow-new
}

upsert_pr() {
  local branch=$1 change=$2 base=$3 state
  state=$(gh_main pr view "$branch" --json state --jq .state 2>/dev/null || true)
  if [[ "$state" == OPEN ]]; then
    gh_main pr edit "$branch" --title "$(title_of "$change")" --body "$(body_of "$change")" --base "$base" >/dev/null
    echo "updated $(gh_main pr view "$branch" --json url --jq .url) <- $base"
  else
    gh_main pr create --head "$branch" --base "$base" --fill
  fi
}

title_of() {
  jj log --no-graph -r "$1" -T 'description.first_line()'
}

body_of() {
  jj log --no-graph -r "$1" -T 'description' | tail -n +2 | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}'
}

gh_main() {
  (cd "$main_root" && gh "$@")
}

die() {
  echo "gh-stack: $*" >&2
  exit 1
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
