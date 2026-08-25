<p align="center">
  <img src="https://em-content.zobj.net/source/apple/391/link_1f517.png" width="100" />
</p>

<h1 align="center">cited-code</h1>

<p align="center">
  <strong>Claude already knows the file. now you can click there too.</strong><br>
  Every code reference in an answer becomes a real link — checked against your repo the same turn, not vibes.
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

Claude explains a bug across four files, and you're left copy-pasting `services/serving/app/main.py:234` into cmd+P by hand, like it's 2019. A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that fixes that: every file, function, variable, route, and config key Claude names in an answer becomes a link straight to where it actually lives — cmd+click and you're at the line, not squinting at a path buried in a paragraph.

## Before / After

<table>
<tr>
<th width="50%">🗣️ Plain answer</th>
<th width="50%">🔗 cited-code (paranoid)</th>
</tr>
<tr>
<td valign="top">

> If CLAUDE_PROJECT_DIR is unset, state defaults to paranoid. Level is read in cited-code-activate.sh, switching happens in cited-code-tracker.sh.

</td>
<td valign="top">

> If [CLAUDE_PROJECT_DIR](hooks/cited-code-activate.sh#L7) is unset, state defaults to `paranoid`. Level is read in [cited-code-activate.sh](hooks/cited-code-activate.sh), switching happens in [cited-code-tracker.sh](hooks/cited-code-tracker.sh).

</td>
</tr>
</table>

The right column isn't a mockup — those links are real and clickable on this exact page, pointed at this repo's own code. Cmd/Ctrl+click one, on GitHub or inside Claude Code's IDE integration, and it jumps straight to that line. The demo proves itself; it doesn't ask you to trust a screenshot.

## Install

```
/plugin marketplace add BalaMithran/cited-code
/plugin install cited-code
```

That's the whole install. Two hook scripts, plain bash, nothing to `npm install` and nothing that phones home. Works the moment you open Claude Code in any repo.

**Trigger:** on by default at `paranoid` from the first message. Switch anytime with `/cited-code yolo|lite|paranoid|ocd`, or just say it — "cited-code ocd", "stop cited-code" both work, no slash required.

## Levels

Named for how paranoid Claude should be about proving a claim, not how much it talks.

| Level | Behavior |
|---|---|
| `yolo` | Off. Plain backticks, no verification, no links — the "I trust you" setting. |
| `lite` | Plain backticks by default. Links only on explicit ask, or once per file/function the first time it's introduced. |
| `paranoid` *(default)* | Every resolvable code term linked, first occurrence. Trust nothing that wasn't checked this turn. |
| `ocd` | Every occurrence linked, not just the first — status lines, directory refs, route/config strings included. Nothing left uncited. |

Levels persist per-project (`<project>/.claude/.cited-code-level`, gitignored — a per-dev call, not a team setting) until you change them.

The rule that doesn't move across levels: a link only gets made if its target was checked with a real tool call **this turn**, not remembered from three messages ago. `paranoid` and `ocd` link more often than `lite`; none of them link carelessly — a wrong link erodes trust faster than no link at all.

## How It Works

Two hooks, the same shape every persistent Claude Code mode uses:

1. **`SessionStart`** — [cited-code-activate.sh](hooks/cited-code-activate.sh) reads `<project>/.claude/.cited-code-level` (defaulting to `paranoid` if it isn't there yet) and prints the active ruleset into context once per session.
2. **`UserPromptSubmit`** — [cited-code-tracker.sh](hooks/cited-code-tracker.sh) runs before every message: watches for a level switch, persists it, and re-injects a one-line reminder through `hookSpecificOutput.additionalContext`, the standard Claude Code hook contract. That reinjection is the part that matters — without it, a long session's context gets compressed and the instruction quietly falls out of attention. It's why this holds at message fifty, not just message one.
3. **[skills/cited-code/SKILL.md](skills/cited-code/SKILL.md)** carries the actual linking rules — what counts as verified, what stays plain, how ambiguity gets handled. The hooks just summarize it.

No servers, no account, no telemetry. It reads and writes one text file inside your own project's `.claude/` directory. That's the entire footprint.

## Roadmap

- [ ] Measured before/after on real usage — time-to-locate a referenced symbol, not a token count. Token count isn't the metric this tool is chasing.
- [ ] Statusline badge showing the active level.
- [ ] Cross-editor support beyond Claude Code.

Open an issue either way `ocd` lands for you — genuinely useful or genuinely annoying, both are signal worth having.

## Links

- [skills/cited-code/SKILL.md](skills/cited-code/SKILL.md) — full linking spec
- [Issues](https://github.com/BalaMithran/cited-code/issues) — bugs, feature requests, "this is annoying at ocd"

## License

MIT
