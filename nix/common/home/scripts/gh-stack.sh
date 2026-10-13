#!/usr/bin/env bash
# gh-stack [--dry-run] [revset]   one PR per jj commit, based on its parent's PR; reruns update title/body/base in place.
# --dry-run prints every push and gh change instead of making it.
# The revset may be a DAG. Can start on a jj-spr commit, or on commits whose parents have stack PRs.
set -euo pipefail

main() {
  dry_run=0
  if [[ ${1:-} == --dry-run ]]; then
    dry_run=1
    shift
  fi
  range=${1:-'trunk()..@ ~ empty()'}
  prefix="stack/${GH_STACK_USER:-${USER:-$(id -un)}}/"
  main_root=$(main_workspace_root)

  show_range

  local spr_base='' base_change
  base_change=$(change_ids "latest(($range) & remote_bookmarks(glob:\"spr/*\"))")
  if [[ -n "$base_change" ]]; then
    spr_base=$(spr_bookmark_on "$base_change")
    range="($range) & ($base_change+::)"
    echo "base $spr_base (jj-spr, $base_change)"
  fi

  reject_commits "($range) & empty()" "empty commits in range"
  reject_commits "($range) & immutable()" "immutable commits in range"
  reject_commits "($range) & merges()" "merge commits in range"
  reject_commits "($range) & remote_bookmarks(glob:\"spr/*\")" "jj-spr commits above the stack base"

  local -a changes=() branches=() bases=() pushed=() titles=() bodies=()
  plan_branches
  read_descriptions

  local open_prs
  open_prs=$(gh_main pr list --author @me --state open --limit 300 --json headRefName,baseRefName,title,body,url)
  # Bugbot reviews on push and reads the description then.
  update_descriptions
  push_changed_bookmarks
  create_or_rebase_prs
}

show_range() {
  local quoted=${range//\\/\\\\}
  quoted=${quoted//\"/\\\"}
  jj log --no-pager -r "($range) | roots($range)-" -T "if(self.contained_in(\"$quoted\"),
    \"+\" ++ diff.stat().total_added() ++ \" -\" ++ diff.stat().total_removed() ++ \" \" ++ builtin_log_oneline,
    builtin_log_oneline)"
}

plan_branches() {
  local i change parent parent_bookmarks commit bookmarks origin_bookmarks
  local -a parents=() parents_bookmarks=()
  local -A branch_of=()
  while IFS=$'\x1f' read -r -d $'\x1e' change parent parent_bookmarks commit bookmarks origin_bookmarks; do
    changes+=("$change")
    parents+=("$parent")
    parents_bookmarks+=("$parent_bookmarks")
    branches+=("$(stack_branch "$change" "$commit" "$bookmarks")")
    branch_of[$change]=${branches[-1]}
    [[ ",$origin_bookmarks," == *",${branches[-1]},"* ]] && pushed+=(1) || pushed+=(0)
  done < <(jjq log --no-graph --reversed -r "$range" -T '
    change_id.short()
    ++ "\x1f" ++ parents.map(|p| p.change_id().short()).join(",")
    ++ "\x1f" ++ parents.map(|p| p.local_bookmarks().map(|b| b.name()).join(",")).join(",")
    ++ "\x1f" ++ commit_id.short()
    ++ "\x1f" ++ local_bookmarks.map(|b| b.name()).join(",")
    ++ "\x1f" ++ remote_bookmarks.filter(|b| b.remote() == "origin").map(|b| b.name()).join(",")
    ++ "\x1e"')
  for i in "${!changes[@]}"; do
    bases[i]=${branch_of[${parents[i]}]:-$(base_outside_range "${parents[i]}" "${parents_bookmarks[i]}")}
  done
}

stack_branch() {
  local change=$1 commit=$2 bookmark
  local -a names found=()
  IFS=, read -ra names <<<"$3"
  for bookmark in "${names[@]}"; do
    [[ $bookmark == "$prefix"* ]] && found+=("$bookmark")
  done
  case ${#found[@]} in
    0) new_branch "$commit" ;;
    1) echo "${found[0]}" ;;
    *) die "$change has several stack bookmarks: ${found[*]}" ;;
  esac
}

new_branch() {
  local branch="${prefix}$1" taken
  taken=$(change_ids "present(bookmarks(exact:\"$branch\")) | present(remote_bookmarks(exact:\"$branch\"))")
  [[ -z "$taken" ]] || die "$branch already on $taken"
  echo "$branch"
}

base_outside_range() {
  local parent=$1 bookmark
  local -a names found=()
  if [[ -n "$spr_base" ]]; then
    echo "$spr_base"
    return
  fi
  IFS=, read -ra names <<<"$2"
  for bookmark in "${names[@]}"; do
    [[ $bookmark == "$prefix"* ]] && found+=("$bookmark")
  done
  case ${#found[@]} in
    0) echo main ;;
    1) echo "${found[0]}" ;;
    *) die "$parent has several stack bookmarks: ${found[*]}" ;;
  esac
}

read_descriptions() {
  local description body
  while IFS= read -r -d '' description; do
    titles+=("${description%%$'\n'*}")
    body=${description#*$'\n'}
    [[ $description == *$'\n'* ]] || body=''
    body=${body#"${body%%[!$'\n']*}"}
    bodies+=("${body%"${body##*[!$'\n']}"}")
  done < <(jjq log --no-graph --reversed -r "$range" -T 'description ++ "\0"')
}

update_descriptions() {
  local i pr
  local -a pids=()
  for i in "${!changes[@]}"; do
    pr=$(pr_for "${branches[i]}")
    [[ -n "$pr" ]] || continue
    [[ "$(jq -r .title <<<"$pr")" == "${titles[i]}" && "$(own_body "$pr")" == "${bodies[i]}" ]] && continue
    echo "describe $(jq -r .url <<<"$pr")"
    run gh_main pr edit "${branches[i]}" --title "${titles[i]}" --body "${bodies[i]}" >/dev/null &
    pids+=($!)
  done
  wait_all "${pids[@]}"
}

push_changed_bookmarks() {
  local i
  local -a args=()
  for i in "${!changes[@]}"; do
    ((pushed[i])) && continue
    run jj --quiet bookmark set "${branches[i]}" -r "${changes[i]}" --allow-backwards
    args+=(--bookmark "${branches[i]}")
  done
  ((${#args[@]} > 0)) || return 0
  run jj git push "${args[@]}"
  # gh pr create --fill reads the new branches through git in the main checkout.
  run jj --quiet -R "$main_root" git export
}

create_or_rebase_prs() {
  local i pr
  local -a pids=()
  for i in "${!changes[@]}"; do
    pr=$(pr_for "${branches[i]}")
    if [[ -z "$pr" ]]; then
      run gh_main pr create --head "${branches[i]}" --base "${bases[i]}" --fill
    elif [[ "$(jq -r .baseRefName <<<"$pr")" != "${bases[i]}" ]]; then
      echo "rebase $(jq -r .url <<<"$pr") <- ${bases[i]}"
      run gh_main pr edit "${branches[i]}" --base "${bases[i]}" >/dev/null &
      pids+=($!)
    else
      echo "ok     $(jq -r .url <<<"$pr") <- ${bases[i]}"
    fi
  done
  wait_all "${pids[@]}"
}

own_body() {
  jq -r .body <<<"$1" |
    sed -e '/^<!-- CURSOR_SUMMARY -->$/,/^<!-- \/CURSOR_SUMMARY -->$/d' \
      -e '/^<!-- frontend-preview:start -->$/,/^<!-- frontend-preview:end -->$/d' |
    sed '/./,$!d'
}

pr_for() {
  jq -c --arg branch "$1" '.[] | select(.headRefName == $branch)' <<<"$open_prs"
}

run() {
  if ((dry_run == 0)); then
    "$@"
    return
  fi
  local arg
  local -a shown=()
  for arg in "$@"; do
    arg=${arg//$'\n'/ }
    shown+=("${arg:0:60}")
  done
  echo "dry-run: ${shown[*]}" >&2
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
  jjq log --no-graph --reversed -r "$1" -T 'change_id.short() ++ "\n"'
}

spr_bookmark_on() {
  jjq log --no-graph -r "$1" -T 'remote_bookmarks.map(|b| b.name() ++ "\n").join("")' \
    | grep '^spr/' | sort -u | head -1
}

# The first jj log snapshots the working copy; the reads after it reuse that snapshot.
jjq() {
  jj --ignore-working-copy "$@"
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
