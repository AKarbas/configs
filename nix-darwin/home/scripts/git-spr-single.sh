#!/bin/bash
# Creds: gh:philz

set -e -u -o pipefail

# Ensure command argument is provided
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <command: diff | land> [commit]"
  exit 1
fi

command=$1

# Check if the command is valid
if [[ "$command" != "diff" && "$command" != "land" ]]; then
  echo "Error: Command must be either 'diff' or 'land'."
  exit 1
fi

# Determine the commit
merge_base=$(git merge-base HEAD origin/main)
if [[ $# -eq 2 ]]; then
  commit_hash=$(git rev-parse "$2")
else
  commit=$(git log --oneline $merge_base..HEAD | fzf --layout=reverse-list --height 80% --prompt "Select commit:" --preview "git show {1}")
  [[ -n "$commit" ]]
  commit_hash=$(echo $commit | awk '{print $1}')
fi

# Choose the correct spr command based on the provided command
if [[ "$command" = "diff" ]]; then
        spr_command="spr $command --update-message"
else
        spr_command="spr $command"
fi

# Perform interactive rebase with the selected or provided commit
GIT_SEQUENCE_EDITOR="perl -i -pe 's/^(pick $commit_hash.*)$/\$1\\nexec $spr_command --cherry-pick /'" git rebase -i $merge_base
