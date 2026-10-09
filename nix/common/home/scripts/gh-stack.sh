#!/usr/bin/env bash
# gh-stack [revset]   one PR per jj commit; reruns update title/body/base in place.
# Can start the stack on a jj-spr commit, or on a commit whose parent has a stack PR.
set -euo pipefail

main() {
  range=${1:-'trunk()..@ ~ empty()'}
  prefix="stack/${GH_STACK_USER:-${USER:-$(id -un)}}/"
  main_root=$(main_workspace_root)

  local prev_branch=main base_change
  base_change=$(change_ids "latest(($range) & remote_bookmarks(glob:\"spr/*\"))")
  if [[ -n "$base_change" ]]; then
    prev_branch=$(spr_bookmark_on "$base_change")
    range="($range) & ($base_change+::)"
    echo "base $prev_branch (jj-spr, $base_change)"
  else
    base_change=$(stack_bookmarks_on "roots($range)-")
    [[ $(grep -c . <<<"$base_change") -le 1 ]] || die "range has several stacked parents:"$'\n'"$base_change"
    if [[ -n "$base_change" ]]; then
      prev_branch=$base_change
      echo "base $prev_branch (stacked parent)"
    fi
  fi

  jj log --no-pager --no-graph -r "$range" -T '"+" ++ diff.stat().total_added() ++ " -" ++ diff.stat().total_removed() ++ " " ++ builtin_log_oneline'
  reject_commits "($range) & empty()" "empty commits in range"
  reject_commits "($range) & immutable()" "immutable commits in range"
  reject_commits "($range) & remote_bookmarks(glob:\"spr/*\")" "jj-spr commits above the stack base"

  local -a changes branches bases
  local i
  mapfile -t changes < <(change_ids "$range")
  for i in "${!changes[@]}"; do
    branches[i]=$(branch_for "${changes[i]}")
    bases[i]=$prev_branch
    prev_branch=${branches[i]}
  done

  local open_prs
  open_prs=$(gh_main pr list --author @me --state open --limit 300 --json headRefName,baseRefName,title,body,url)
  # Bugbot reviews on push and reads the description then.
  update_descriptions
  push_changed_bookmarks
  create_or_rebase_prs
}

update_descriptions() {
  local i pr title body
  local -a pids=()
  for i in "${!changes[@]}"; do
    pr=$(pr_for "${branches[i]}")
    [[ -n "$pr" ]] || continue
    title=$(title_of "${changes[i]}")
    body=$(body_of "${changes[i]}")
    [[ "$(jq -r .title <<<"$pr")" == "$title" && "$(own_body "$pr")" == "$body" ]] && continue
    echo "describe $(jq -r .url <<<"$pr")"
    gh_main pr edit "${branches[i]}" --title "$title" --body "$body" >/dev/null &
    pids+=($!)
  done
  wait_all "${pids[@]}"
}

push_changed_bookmarks() {
  local i
  local -a args=()
  for i in "${!changes[@]}"; do
    jj bookmark set "${branches[i]}" -r "${changes[i]}" --allow-backwards
    pushed "${branches[i]}" || args+=(--bookmark "${branches[i]}")
  done
  ((${#args[@]} > 0)) || return 0
  jj git push --allow-new "${args[@]}"
  # gh pr create --fill reads the new branches through git in the main checkout.
  jj -R "$main_root" git export
}

create_or_rebase_prs() {
  local i pr
  local -a pids=()
  for i in "${!changes[@]}"; do
    pr=$(pr_for "${branches[i]}")
    if [[ -z "$pr" ]]; then
      gh_main pr create --head "${branches[i]}" --base "${bases[i]}" --fill
    elif [[ "$(jq -r .baseRefName <<<"$pr")" != "${bases[i]}" ]]; then
      echo "rebase $(jq -r .url <<<"$pr") <- ${bases[i]}"
      gh_main pr edit "${branches[i]}" --base "${bases[i]}" >/dev/null &
      pids+=($!)
    else
      echo "ok     $(jq -r .url <<<"$pr") <- ${bases[i]}"
    fi
  done
  wait_all "${pids[@]}"
}

own_body() {
  jq -r .body <<<"$1" | sed '/^<!-- CURSOR_SUMMARY -->/,$d' | sed '/./,$!d'
}

pr_for() {
  jq -c --arg branch "$1" '.[] | select(.headRefName == $branch)' <<<"$open_prs"
}

pushed() {
  [[ -n $(change_ids "present(bookmarks(exact:\"$1\")) & present(remote_bookmarks(exact:\"$1\"))") ]]
}

wait_all() {
  local pid failed=0
  for pid in "$@"; do wait "$pid" || failed=1; done
  ((failed == 0)) || die "a gh call failed"
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
  local change=$1 commit_id branch taken
  commit_id=$(jj log --no-graph -r "$change" -T 'commit_id.short()')
  branch="${prefix}${commit_id}"
  taken=$(change_ids "present(bookmarks(exact:\"$branch\")) | present(remote_bookmarks(exact:\"$branch\"))")
  [[ -z "$taken" ]] || die "$branch already on $taken"
  echo "$branch"
}

spr_bookmark_on() {
  jj log --no-graph -r "$1" -T 'remote_bookmarks.map(|b| b.name() ++ "\n").join("")' \
    | grep '^spr/' | sort -u | head -1
}

title_of() {
  jj log --no-graph -r "$1" -T 'description.first_line()'
}

body_of() {
  jj log --no-graph -r "$1" -T 'description' | tail -n +2 | sed '/./,$!d'
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
