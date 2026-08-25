<p align="center">
  <img src="https://em-content.zobj.net/source/apple/391/link_1f517.png" width="100" />
</p>

<h1 align="center">cited-code</h1>

<p align="center">
  <strong>stop making devs grep for the file you just described</strong>
</p>

<p align="center">
  <a href="https://github.com/BalaMithran/cited-code/stargazers"><img src="https://img.shields.io/github/stars/BalaMithran/cited-code?style=flat&color=yellow" alt="Stars"></a>
  <a href="https://github.com/BalaMithran/cited-code/commits/main"><img src="https://img.shields.io/github/last-commit/BalaMithran/cited-code?style=flat" alt="Last Commit"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/BalaMithran/cited-code?style=flat" alt="License"></a>
</p>

<p align="center">
  <a href="#before--after">Before/After</a> •
  <a href="#install">Install</a> •
  <a href="#levels">Levels</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#status">Status</a>
</p>

---

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that turns code references in Claude's answers into clickable jump-to-code links, verified against the real repo the same turn — instead of a paragraph you have to manually grep against.

## Before / After

Every link below is real and clickable on this page, right now — pointed at this repo's own code, so the demo proves itself instead of asking you to trust a screenshot.

**Not this:**

> If CLAUDE_PROJECT_DIR is unset, state defaults to paranoid. Level is read in cited-code-activate.sh, switching happens in cited-code-tracker.sh.

**This:**

> If [CLAUDE_PROJECT_DIR](hooks/cited-code-activate.sh#L7) is unset, state defaults to `paranoid`. Level is read in [cited-code-activate.sh](hooks/cited-code-activate.sh), switching happens in [cited-code-tracker.sh](hooks/cited-code-tracker.sh).

Cmd/Ctrl+click either link on GitHub, or inside Claude Code's IDE integration, and it jumps straight to that line. No copy-pasting a path into cmd+P.

## Install

```
/plugin marketplace add BalaMithran/cited-code
/plugin install cited-code
```

Works in any repo. No dependencies beyond bash — nothing to `npm install`.

**Trigger:** on by default at `paranoid`. Switch with `/cited-code lite|paranoid|ocd|yolo`, or say it naturally ("cited-code ocd", "stop cited-code").

## Levels

| Level | Behavior |
|---|---|
| `lite` | Plain backticks by default. Links only on explicit ask, or once per file/function first introduced. |
| `paranoid` *(default)* | Every resolvable code term linked, first occurrence. Trust nothing you haven't verified this turn. |
| `ocd` | Every occurrence linked — status lines, directory refs, route/config strings included. Maximal density. |
| `yolo` | Off. Plain backticks, no verification, no links. |

Levels persist per-project (`<project>/.claude/.cited-code-level`, gitignored — a per-dev preference, not a team setting) until changed.

The one rule that never changes across levels: a link only gets made if its target was verified with a real tool call **this turn**. Ambiguous or hypothetical code stays plain backticks — a stale link is worse than no link.

## How It Works

1. `hooks/cited-code-activate.sh` runs on `SessionStart`, reads the level, announces the active ruleset.
2. `hooks/cited-code-tracker.sh` runs on every `UserPromptSubmit` — parses `/cited-code <level>` switches, persists the choice, and re-injects a short reminder every turn so the behavior survives context compression instead of drifting back to plain prose mid-session.
3. `skills/cited-code/SKILL.md` is the full spec both hooks summarize.

Same hook shape as [caveman](https://github.com/JuliusBrussee/caveman) — `SessionStart` + `UserPromptSubmit`, state file, `hookSpecificOutput.additionalContext` — just applied to code citations instead of response brevity. If you already run caveman, this is a compatible sibling, not a competitor.

## Status

Early — built and hand-tested in one session, not yet running across a real team or benchmarked for actual dev time saved. No fabricated numbers here on purpose: if you try it and it's genuinely useful (or genuinely annoying at `ocd`), open an issue and say so.

## Links

- [skills/cited-code/SKILL.md](skills/cited-code/SKILL.md) — full linking spec
- [Issues](https://github.com/BalaMithran/cited-code/issues) — bugs, feature requests, "this is annoying at ocd"

## License

MIT
