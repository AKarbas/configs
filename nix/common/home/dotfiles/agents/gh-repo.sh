# Sets $repo to owner/name from $GH_REPO, else from the checkout's origin.
repo=${GH_REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null \
  || jj git remote list 2>/dev/null | awk '$1 == "origin" { print $2 }' | sed -E 's#.*[:/]([^/]+/[^/]+)$#\1#; s#\.git$##')}
[[ -n $repo ]] || { echo "$0: not in a checkout and GH_REPO unset" >&2; exit 1; }
