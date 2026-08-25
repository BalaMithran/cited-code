---
name: cited-code
description: Turn code references in a response (file names, function/variable names, config keys, error strings) into clickable jump-to-code links instead of a wall of plain-text prose. Use whenever an answer explains code, a bug, or a flow and cites real symbols/files from the current repo — code review summaries, "how does X work" explanations, bug walkthroughs, architecture recaps.
---

# Cited code

Every code term named in an explanation (function, file, variable, config key,
error string) becomes a link that jumps straight to its real location —
instead of forcing the reader to grep for it themselves.

Persisted, level-based, hook-enforced. A SessionStart hook announces the
active level every session; a UserPromptSubmit hook re-injects a short
reminder every turn (so it survives context compression and doesn't drift
back to plain prose mid-session) and handles switching. See
`hooks/cited-code-activate.sh` and `hooks/cited-code-tracker.sh` — this file
is the full spec they summarize.

## Levels

| Level | Behavior |
|-------|----------|
| **yolo** | Skip this skill entirely, plain backticks only, don't bother verifying. |
| **lite** | Plain `` `backticks` `` by default. Link only on explicit ask, or once per file/function the first time it's introduced. |
| **paranoid** (default) | Every resolvable code term gets linked, first occurrence is enough. Trust nothing you haven't verified this turn. |
| **ocd** | Every resolvable code term, every occurrence — including status/summary lines, directory refs, route/config strings. Maximal density, nothing left uncited. |

Switch with `/cited-code yolo|lite|paranoid|ocd`, or naturally ("cited-code
ocd", "stop cited-code"). Persists per-project (via
`<project>/.claude/.cited-code-level`, gitignore it — per-dev, not a team
setting) until changed or the state file is deleted.

## Rule

Before linking a term, verify its current location THIS turn — via a tool
call already run in this turn (Read/Grep/Bash output), not memory from
earlier in the conversation or a prior session. Code moves; a stale link is
worse than no link. This holds at every level — levels change *how much*
gets linked, never *how carefully*.

- **Verified + unique match** → link it: `` [term](relative/path#L<line>) ``
  (repo-root-relative path, so it works from the IDE's workspace root).
- **File-level reference, no specific line** → link without `#L`:
  `` [file.py](path/to/file.py) ``.
- **Ambiguous** (symbol defined/used in multiple places, no single answer) →
  leave as plain `` `code text` ``, don't guess which one.
- **Doesn't exist yet** (planned/hypothetical code, a future file, a branch
  name) → plain `` `code text` ``, never link.

At **paranoid** and **ocd**, apply this to the whole answer, not just an
isolated "see file.py:42" line at the end — every code-shaped term in a
paragraph, numbered list, or status/summary message gets the same treatment
if it resolves to one place.

## Why this works

Claude Code's VSCode/IDE integration renders markdown links as clickable
jumps to that file/line in the editor. In a plain terminal session the links
render as inert text — still useful as copy-pasteable paths, but not
clickable. No extra tool calls needed beyond ones already used to find the
answer; this only changes how already-verified locations get formatted.

## Example

Not this:

> If `predictors` is empty, `/predict` returns `503`. Otherwise it calls
> `build_feature_row`, then `predict_proba`.

This:

> If [predictors](services/serving/app/main.py) is empty, `/predict` returns
> [503](services/serving/app/main.py#L185). Otherwise it calls
> [build_feature_row](services/serving/app/main.py#L140), then
> [predict_proba](services/serving/app/main.py#L249).
