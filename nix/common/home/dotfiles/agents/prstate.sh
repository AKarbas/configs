#!/usr/bin/env bash
# State of PRs, one line per PR as key=value, for prwatch.sh and for status statements.
# Usage: prstate.sh [-v|-w] [PR...]   (default: my open PRs. repo: gh-repo.sh)
#   rules=    the base branch's rulesets: approvals:N, codeowner, threads, dismiss-on-push, mq
#   review=   reviewDecision, or recomputing (null after a push or during a review), not_required, draft
#   approvals= login@sha of each current approval
#   open_threads= unresolved threads, pending reviews excluded
#   ci=       required checks only, latest run per check. running while one is missing or unfinished.
#   needs=    what blocks the merge, from rules=: draft, conflicts, approval, threads:N, checks:<names>, nothing
#   Exits 3 while mergeability is UNKNOWN, so waitfor.sh skips that poll.
#   -v  also prints review notes, each unresolved thread's first comment, and comments.
#   -w  settled facts only, one per line, for waitfor.sh -A: drops merge_state, needs, review=recomputing,
#       ci=running, mq=no and draft=no. mergeable only when CONFLICTING (last settled value while UNKNOWN).
set -uo pipefail
verbose=; watch=
case ${1:-} in -v) verbose=1; shift ;; -w) watch=1; shift ;; esac
. "$(dirname "$0")/gh-repo.sh"
[[ $# -gt 0 ]] || set -- $(gh pr list -R "$repo" --author @me --state open --limit 50 --json number --jq '.[].number' | sort -n)
[[ $# -gt 0 ]] || exit 1
prs=
for n in "$@"; do prs+=" p$n: pullRequest(number: $n) { ...F }"; done
query="query { repository(owner: \"${repo%/*}\", name: \"${repo#*/}\") {$prs } }
fragment F on PullRequest { number state isDraft baseRefName headRefOid mergeable mergeStateStatus reviewDecision
  mergeQueueEntry { position }
  latestOpinionatedReviews(first: 20) { nodes { author { login } state commit { abbreviatedOid } } }
  reviewThreads(first: 100) { nodes { isResolved isOutdated
    comments(first: 1) { nodes { author { login } path body pullRequestReview { state } } } } }
  reviews(last: 30) { nodes { author { login __typename } state body submittedAt } }
  comments(last: 30) { nodes { author { login } body createdAt } }
  commits(last: 1) { nodes { commit { statusCheckRollup { contexts(first: 100) { nodes {
    ... on CheckRun { name conclusion status startedAt } ... on StatusContext { context state createdAt } } } } } } } }"
json=$(gh api graphql -f query="$query") || exit 1
rules='{}'
for base in $(jq -r '.data.repository[].baseRefName' <<<"$json" | sort -u); do
  rule=$(gh api "repos/$repo/rules/branches/$base" --jq '
    ([.[] | select(.type == "pull_request") | .parameters] | first) as $pr |
    {checks: [.[] | select(.type == "required_status_checks") | .parameters.required_status_checks[].context],
     review: ($pr != null), codeowner: ($pr.require_code_owner_review // false),
     threads: ($pr.required_review_thread_resolution // false),
     list: ([(if $pr then "approvals:\($pr.required_approving_review_count)" else empty end),
             (if $pr.require_code_owner_review then "codeowner" else empty end),
             (if $pr.required_review_thread_resolution then "threads" else empty end),
             (if $pr.dismiss_stale_reviews_on_push then "dismiss-on-push" else empty end),
             (if any(.[]; .type == "merge_queue") then "mq" else empty end)] | join(",") | if . == "" then "none" else . end)}') || exit 1
  rules=$(jq --arg base "$base" --argjson rule "$rule" '.[$base] = $rule' <<<"$rules")
done
out=$(jq -r --arg verbose "$verbose" --arg watch "$watch" --argjson rules "$rules" '
  def failed: (.conclusion // .state) | IN("FAILURE","ERROR","TIMED_OUT","ACTION_REQUIRED","STARTUP_FAILURE");
  def running: (.status // "COMPLETED") != "COMPLETED" or (.state | IN("PENDING","EXPECTED"));
  def text: gsub("<!--[^>]*-->"; "");
  .data.repository[] | .number as $n |
  ([.commits.nodes[0].commit.statusCheckRollup.contexts.nodes // [] | .[] | . + {name: (.name // .context)}]
    | group_by(.name) | map(sort_by(.startedAt // .createdAt) | last)) as $latest |
  [$rules[.baseRefName].checks[] as $name | ($latest[] | select(.name == $name))
    // (if .state == "OPEN" then {name: $name, status: "MISSING"} else empty end)] as $checks |
  ([$checks[] | select(running or failed) | .name]) as $not_green |
  (if any($checks[]; running) then "running"
   elif any($checks[]; failed) then "failed:" + ([$checks[] | select(failed) | .name] | join(","))
   else "green" end) as $ci |
  ([.reviewThreads.nodes[] | select((.isResolved | not) and .comments.nodes[0].pullRequestReview.state != "PENDING")]) as $open |
  ([.latestOpinionatedReviews.nodes[] | select(.state == "APPROVED") | "\(.author.login)@\(.commit.abbreviatedOid)"]) as $approvals |
  ([.reviews.nodes[] | select(.author.__typename != "Bot" and .body != "")]) as $notes |
  ([.comments.nodes[] | select(.author.login != "github-actions")]) as $comments |
  $rules[.baseRefName] as $rule |
  (if .reviewDecision != null then .reviewDecision
   elif .isDraft then "draft"
   elif $rule.review | not then "not_required"
   else "recomputing" end) as $review |
  (if .state != "OPEN" then "none" else
    ([(if .isDraft then "draft" else empty end),
      (if .mergeable == "CONFLICTING" then "conflicts" else empty end),
      (if $review | IN("APPROVED", "not_required", "draft") then empty
       elif $review == "recomputing" then "approval(recomputing)"
       elif $review == "CHANGES_REQUESTED" then "approval(changes requested)"
       elif ($approvals | length) > 0 and $rule.codeowner then "approval(code owner)" else "approval" end),
      (if ($open | length) > 0 and $rule.threads then "threads:\($open | length)" else empty end),
      (if ($not_green | length) > 0 then "checks:" + ($not_green | join(",")) else empty end)]
     | if length == 0 then "nothing" else join(";") end) end) as $needs |
  [["state", .state], ["draft", (if .isDraft then "yes" else "no" end)], ["head", .headRefOid[0:7]], ["rules", $rule.list],
   ["mergeable", .mergeable], ["merge_state", .mergeStateStatus], ["review", $review], ["approvals", (if ($approvals | length) > 0 then $approvals | join(",") else "none" end)],
   ["mq", (if .mergeQueueEntry then "queued" else "no" end)],
   ["open_threads", ($open | length)], ["review_notes", ($notes | length)],
   ["bot_reviews", ([.reviews.nodes[] | select(.author.__typename == "Bot")] | length)],
   ["comments", ($comments | length)], ["ci", $ci], ["needs", $needs]] as $facts |
  if $watch != "" then
    $facts[] | select(.[0] | IN("merge_state", "needs") | not)
    | select(. != ["review", "recomputing"] and . != ["ci", "running"] and . != ["mq", "no"] and . != ["draft", "no"]) | "PR \($n) \(.[0])=\(.[1])"
  else
    "PR \($n) " + ($facts | map("\(.[0])=\(.[1])") | join(" "))
    + (if $verbose == "" then "" else
        ([$notes[] | "\n  REVIEW \(.author.login) \(.state) \(.submittedAt[0:16]):\n" + (.body | text | split("\n") | map(select(length > 0) | "    " + .) | join("\n"))] | join(""))
        + ([$open[] | "\n  THREAD \(.comments.nodes[0].author.login) \(.comments.nodes[0].path)\(if .isOutdated then " [outdated]" else "" end): " + (.comments.nodes[0].body | text | gsub("\n+"; " ") | .[0:300])] | join(""))
        + ([$comments[] | "\n  COMMENT \(.author.login) \(.createdAt[0:16]): " + (.body | gsub("\n+"; " ") | .[0:300])] | join(""))
      end)
  end' <<<"$json") || exit 1
if [[ -z $watch ]]; then
  printf '%s\n' "$out"
  grep -q ' mergeable=UNKNOWN ' <<<"$out" && exit 3
  exit 0
fi
cache=${XDG_CACHE_HOME:-$HOME/.cache}/prstate-mergeable
awk -v cache="$cache" '
  BEGIN { while ((getline line < cache) > 0) { split(line, f, " "); last[f[1]] = f[2] }; close(cache) }
  $3 ~ /^mergeable=/ {
    v = substr($3, 11)
    if (v == "UNKNOWN") v = last[$2]; else last[$2] = v
    if (v == "CONFLICTING") print "PR", $2, "mergeable=CONFLICTING"
    next
  }
  { print }
  END { for (pr in last) print pr, last[pr] > cache }' <<<"$out"
