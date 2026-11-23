#!/usr/bin/env bash
# Sets the description of a jj change from stdin and keeps its `Pull Request:` trailer.
# Usage: jjdesc.sh CHANGE < body.md
set -euo pipefail
change=$1
desc=$(jj log -r "$change" --no-graph -T description)
trailer=$(grep -m1 '^Pull Request: ' <<<"$desc" || true)
body=$(cat)
if [[ -n $trailer ]] && ! grep -qxF -- "$trailer" <<<"$body"; then
  body+=$'\n\n'$trailer
fi
jj describe -r "$change" --stdin <<<"$body"
echo "${trailer:-(no PR trailer on $change)}"
