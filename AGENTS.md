# This repo is public

Nothing employer-specific reaches this repo. Not the organization or repo
name, hostnames, cluster, environment or service names, workflow or check
names, branch rules, dashboards, queries, log lines, ticket IDs, colleague
names or logins, internal URLs, or paths into a work checkout.

- A script that needs such a value takes it from an argument, an environment
  variable, or a live lookup (`gh api`, the checkout's `origin`). See
  `nix/common/home/dotfiles/agents/gh-repo.sh`.
- A script that is only useful at an employer and not in general for personal
  boxes OR is their IP does not belong here. Keep it outside the repo. When
  unsure, halt and ask.
- Before you hand over, read your diff as a stranger would.

A hook lints the whole repo against `~/.config/employer-terms` after every
edit and blocks on a match. The list is employer-specific itself, so it
lives outside the repo. `.claude/hooks/public-guard.sh` runs the lint by hand.
