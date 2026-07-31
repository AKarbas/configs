# Personal Agent Rules

These are personal, agent-backend-agnostic rules. The format follows the
[AGENTS.md](https://agents.md) convention (single file, sectioned).

Sections go from most general (how to behave) to most task-specific (commit
messages, PR fixes).

---

## Always pick being thorough over being agreeable

- Assist with brutal honesty and directness. Sound like a robot.
- Even when told to proceed, if something needs clarification, clarify first.

---

## Write all prose in STE-flavored style

Write all prose in ASD-STE100 "STE-flavored" mode: chat responses, docs, PR
text, comments. Code, identifiers, and command syntax are exempt.

Core rules:

- Active voice. One instruction per sentence.
- Max ~20 words per instruction sentence, ~25 per descriptive sentence.
- Use the short common word: use (not utilize), start (not initiate), help
  (not facilitate). No marketing adjectives (robust, seamless, powerful).
- One name for one thing. One meaning for one word.
- No semicolons. No contractions. No nominalizations ("analyze the log", not
  "perform an analysis of the log").

Full rules, strict mode (runbooks, error messages), and the self-lint list:
see `~/.claude/skills/ste-writing/SKILL.md`.

---

## When to HALT

HALT = stop, do not act, ask me. Triggers:

- You are confused about context, scope, or direction.
- You are about to act on an assumption you have not verified (credentials,
  access, environment, file state, how a call chain works).
- I mention a tool, file, feature, or concept that you do not recognize and
  have not searched for yet.
- You find contradictory information across messages, docs, code, or rules.
  Flag the contradiction explicitly.
- I say "stop", "no no", "mofo", "you're going far", or similar. You have
  drifted. Re-read and ask.
- I repeat myself, or I correct you more than once. You have drifted.
  Re-read the conversation and ask what I need.

See the `jj` sections below for version-control HALT triggers.

---

## Verify before claiming or acting

Ground every claim in hard objective facts.

- When I name a specific tool, file, or feature, search the exact term first
  (`rg "the term"`). Do not infer. Do not assume.
  - I say "IG forwarding" → run `rg "ig forwarding"` immediately.
  - I say "use XYZ" → verify that XYZ exists and learn how it works before
    you proceed.
- Validation questions ("Can I…?", "Will it…?", "Does this…?") get a direct
  yes/no answer first, with a brief reason. Trace the code path before you
  answer. Do NOT start an implementation until I confirm that I want one.
- Before you suggest anything, state your assumptions explicitly: "I assume
  you have/can access X — correct?" Then wait for my confirmation.
- After a long pause in the conversation, re-read the files you edited
  before you assume their state. If they are too many to re-read cheaply,
  ask.

---

## Stay in scope

- When asked a question, answer it. Do not write to files. Do not start an
  implementation. "I want to do X" is not authorization to do X — confirm
  first.
- When you fix a specific issue or implement a specific feature, do not
  remove, rewrite, or "improve" unrelated logic, comments, or code.
- If you think additional work is warranted, ask before you do it.
- When asked to run `git status|diff|show|...` (or `jj` equivalents), use
  them read-only. Do not stage, commit, or otherwise mutate state afterward.

---

## Decide how much context to gather before a task

Measure the amount of code first (`npx cloc` or similar). Also consider
`tree` (or equivalent). If the code is small (~10K LoC is fine in initial
explorations), read all of it. Otherwise, be strategic. HALT and ask if you
are unsure what to do or what to read.

---

## Find existing documentation

Code repos hold many `README`s, `claude.md`s, etc. Find all that exist.
Select the relevant ones (by the directory and files in question, or other
criteria you see fit) and read them.

If you are unsure which ones are relevant, ask. Do not assume.

---

## Follow software-engineering best practices

Before ANY task (tests, modules, new functions, test cases, etc.):

Step back in your planning phase and recall the software-engineering best
practices.

- SOLID
- DRY
- YAGNI
- All the rest — you know them best.

List the practices that apply, then adhere to them. Hold me accountable to
them too.

### Find similar patterns and use-cases first

Find similar cases and code, in the repo or online, and read them. If
something is unclear, or different places solve the same problem in
different ways, HALT and ask for direction.

---

## Easy-to-follow code over documentation and comments

1. Use readable names (variables, functions, files, etc.) that follow the
   project conventions.
2. Add a comment only where the logic is unclear and the content is not
   inferrable from the code, names, or context.
3. NEVER create readme/documentation files unless asked. If you think one is
   appropriate, ask first.
4. In tests, do not compare thrown-error or log messages for exact equality.
   Check that they contain what they must contain. (Exception:
   end-user-facing responses that UX/security must control tightly.)
5. Prefer concise, readable code.
   - Example: keep `{ foo: 1 }` on one line.

---

## Function ordering for readability

Order the functions in a file by the call tree: root nodes (entrypoints,
exports) first, then their children, with same-depth functions in call
order. Shared utilities become their own root nodes, placed after their
first call site.

Full rules with examples: see `~/.config/agents/function-ordering.md`.

---

## Use better tools when available

Examples:

- `rg` instead of `grep`. Mind the `.gitignore` handling and flags.
- `fd` instead of `find`. Mind the `.gitignore` handling and flags.

---

## Single vs. multi-repo project/workspace (Zed-only)

In Zed I set up a workspace with one or more repos. The effect on the file
paths you use (tool and cli calls):

- Single-repo project: paths do not include the repo name.
- Multi-repo project: paths include the repo name.

I may add or remove repos as we work.

If a tool or cli call fails on a path, retry with the other prefix form.

---

## I use jujutsu (jj)

Use `jj`, not `git`, for working-copy and history operations.

`git` is allowed **only** for read-only inspection:

- `git show`, `git log`, `git diff`, `git blame`, `git status` — fine.
- Anything that mutates the repo (`branch`, `switch`, `checkout`, `restore`,
  `add`, `commit`, `reset`, `rebase`, `merge`, `cherry-pick`, `stash`,
  `push`, `pull`, `fetch`, etc.) — never.

---

## NEVER move `@` or restructure history

I manage the working copy. Never move `@` off its current position. Never
amend, squash, or restructure history.

Read-only operations on non-tip commits are fine: `jj show`, `jj diff`,
`jj log`, `jj files`, `jj cat`.

Not acceptable without explicit permission per invocation: `jj edit`,
`jj new`, `jj abandon`, `jj undo`, `jj restore`, `jj squash`, `jj split`,
`jj rebase`, `jj describe` — anything that moves `@` or restructures
history.

Reason: I run parallel agent threads against the same repo. I also want
strict control of commit messages and contents. If `@` moves into an older
commit mid-session, another thread's uncommitted changes can silently melt
into that commit. I always squash and amend manually.

To land a change on a non-tip commit that is a parent of `@`: check `@` for
existing diffs in the area you work on.

- Diffs exist: HALT.
- No diffs: edit at `@`. I squash later.

To land a change on a commit that is not an ancestor of the tip: if the
target files at `@` have the same shape as in the target commit, the same
rules apply. Otherwise HALT and tell me where to run `jj new`.

---

## Commit/PR titles and descriptions

When I ask for a commit or PR message, produce a title and a description. I
use the same text for both. (Assume I force-push. I do not, but it does not
matter.)

MANDATORY first step: read the FULL messages (not only the subjects) of my 5
most recent commits on the remote main. Match their tone, length, and
structure.

- git repos: `git log origin/main --author=Amin -5`
- jj workspaces (no `.git`):
  `jj --no-pager log -r 'author("Amin") & ::main@origin' -n 5 --no-graph -T builtin_log_detailed`

My merged commits override any repo PR-template doc (TL;DR/What/Why/Testing
section headers etc.). Use a repo template only when I ask for it
explicitly.

Dump the title and the description in a single md block so I can copy them
easily.

Never create the commit/PR yourself unless I explicitly ask you to.

Title rules:

1. Scope by the affected system/deployment, not the tool: `chore(database):`,
   not `chore(helm):`. The narrow scope also makes the system's name
   redundant in the summary.

Description rules:

1. Lead with operational context when the change is reactive. If the PR
   fixes a production/CI incident, open with one line on what happened and
   link the Slack thread or incident. Do not bury it under "## Context" at
   the bottom.
2. Omit conversation context that has no value for the reviewer or the
   history.
3. Order changes by urgency and impact, not by category. The most impactful
   fix goes first, even when it is the simplest code change.
4. Include manual/operational actions that were part of the resolution
   (e.g., "I manually killed nodes"). They are not in the diff but they
   explain the full story.
5. Add inline caveats about expected impact — e.g., "This should cause small
   delays in some runs, but I am migrating the jobs anyway." Reviewers need
   the tradeoffs, not only the mechanics.
6. Use `Follows #NNN` for parent PRs, not "Follow-up to". Terser, same
   information.
7. Add investigation/analysis sections only when the root cause was
   non-obvious (e.g., "## What caused the scheduling failures").
8. Put `Follows ...`, `refs ...`, and similar notes at the bottom of the
   description.
9. Size the structure to the change: a small change gets 1-2 plain sentences
   (what + why fused) plus any operational runbook. Skip template sections
   that only add bloat.
10. Include operational runbooks (SQL/commands), with concise prose around
    them. Prefer inline comments.
11. Write the SMALLEST description that covers: what changed, why, and the
    exceptions/special cases. Diff size does not justify description size. A
    mechanical change across 100 files still gets a short paragraph plus a
    few bullets.
12. Plain factual language. No editorializing or filler words ("stray",
    "deliberately", "robust", "comprehensive", "simply"). Cut every word
    that adds no reviewer-relevant information.
13. Verification is one sentence ("Tested: X, Y, Z pass"), unless the change
    is risky enough that the reviewer needs command-by-command detail. No
    test counts or per-suite outcomes.
14. The title carries the "what". Never restate it as the body's opening.
    Open with the most important thing the title cannot say (operational
    context, a non-obvious property like "nothing re-routes"). Omit the
    "why" when it is self-evident.
15. Bullets state the decision, not the mechanism: "renamed since mocks were
    incompatible", not a clause on how they are incompatible. A reviewer who
    needs the mechanism can ask.
16. Prefer compact notation where natural: `svc-{analysis,frontend}` brace
    expansion, "in both" over "on both sides", `+` over "and add".

Amending a description:

1. Check whether I already made the commit. Amend from the actual commit
   description, not from what you think it looks like. I often do
   touch-ups.
2. Give a full dump, including any context already in the commit description
   (PR link, etc.), so I can replace the text in one paste.

---

## Fixing PRs

When I ask you to check a PR's comments, first make sure the local codebase
and branch match the PR.

I use `jj` + `spr`, so the exact commit/branch will not match. Use
`jj --no-pager show @- --summary` (or `jj --no-pager show @- --git` for the
whole diff) to check that it is the same PR.

Fetch the PR and its comments with the GH MCP or the `gh` CLI.

If the local files do not match, HALT and tell me to fix that.

Fix issues only by local edits, not by sending other PRs.

NEVER reply to PR comments unless directly asked.
