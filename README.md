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
  <a href="#roadmap">Roadmap</a>
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

**Trigger:** on by default at `paranoid`. Switch with `/cited-code yolo|lite|paranoid|ocd`, or say it naturally ("cited-code ocd", "stop cited-code").

## Levels

| Level | Behavior |
|---|---|
| `yolo` | Off. Plain backticks, no verification, no links. |
| `lite` | Plain backticks by default. Links only on explicit ask, or once per file/function first introduced. |
| `paranoid` *(default)* | Every resolvable code term linked, first occurrence. Trust nothing you haven't verified this turn. |
| `ocd` | Every occurrence linked — status lines, directory refs, route/config strings included. Maximal density. |

Levels persist per-project (`<project>/.claude/.cited-code-level`, gitignored — a per-dev preference, not a team setting) until changed.

The one rule that never changes across levels: a link only gets made if its target was verified with a real tool call **this turn**. Ambiguous or hypothetical code stays plain backticks — a stale link is worse than no link.

## How It Works

1. `hooks/cited-code-activate.sh` runs on `SessionStart`, reads the level, announces the active ruleset.
2. `hooks/cited-code-tracker.sh` runs on every `UserPromptSubmit` — parses `/cited-code <level>` switches, persists the choice, and re-injects a short reminder every turn so the behavior survives context compression instead of drifting back to plain prose mid-session.
3. `skills/cited-code/SKILL.md` is the full spec both hooks summarize.

## Roadmap

- [ ] Measured before/after on real usage (time-to-locate a referenced symbol, not a token count — that's not this tool's metric to chase)
- [ ] Statusline badge showing the active level
- [ ] Cross-editor support beyond Claude Code

Open an issue if `ocd` is genuinely annoying in practice, or genuinely great — both are useful signal.

## Links

- [skills/cited-code/SKILL.md](skills/cited-code/SKILL.md) — full linking spec
- [Issues](https://github.com/BalaMithran/cited-code/issues) — bugs, feature requests, "this is annoying at ocd"

## License

MIT
