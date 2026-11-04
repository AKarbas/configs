#!/usr/bin/env bash
# Exit 2 when a file in the repo matches a pattern in ~/.config/employer-terms (one extended regex
# per line, case-insensitive). Ignored paths are skipped.
set -uo pipefail
terms=${EMPLOYER_TERMS:-$HOME/.config/employer-terms}
root=${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}
[[ -s $terms ]] || { echo "public-guard: no $terms, nothing checked" >&2; exit 0; }
cd "$root" || exit 1
if command -v rg >/dev/null; then
  hits=$(rg -n -i --hidden --no-require-git --glob '!.git' --glob '!.jj' -f "$terms" .)
else
  hits=$(grep -r -n -i -E --exclude-dir=.git --exclude-dir=.jj --exclude-dir='result*' -f "$terms" .)
fi
[[ -z $hits ]] && exit 0
{ echo "public-guard: employer-specific term in the repo. This repo is public. Remove it (see AGENTS.md):"; cut -c1-140 <<<"$hits"; } >&2
exit 2
