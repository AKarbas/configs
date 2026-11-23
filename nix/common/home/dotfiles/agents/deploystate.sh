#!/usr/bin/env bash
# Newest completed run of each workflow, one line each, for `waitfor.sh -A`: a dispatch wakes nobody,
# a finished run does. Newest by creation, so a re-run of an old build cannot win.
# Usage: deploystate.sh WORKFLOW.yml...   (repo: gh-repo.sh)
set -uo pipefail
. "$(dirname "$0")/gh-repo.sh"
for wf in "$@"; do
  gh run list -R "$repo" --workflow "$wf" --status completed --limit 10 \
    --json databaseId,conclusion,displayTitle,createdAt \
    | jq -r --arg wf "${wf%.yml}" 'sort_by(.createdAt) | last | "\($wf) \(.displayTitle) \(.conclusion) run=\(.databaseId)"' || exit 1
done
