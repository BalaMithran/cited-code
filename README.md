# cited-code

A Claude Code plugin that turns code references in Claude's responses into
clickable jump-to-code links, instead of a wall of plain-text prose.

```
Not this:
> If `predictors` is empty, `/predict` returns `503`.

This:
> If [predictors](services/serving/app/main.py) is empty, `/predict`
> returns [503](services/serving/app/main.py#L185).
```

Every code term (file, function, variable, config key, error string) that
Claude names in an explanation gets verified against the actual code **that
same turn**, then linked to its real location — cmd+click in the IDE jumps
straight there. Ambiguous or hypothetical references stay plain backticks
rather than risk a wrong link.

## Levels

Configurable like `/caveman`, persisted per-project, hook-enforced so it
survives context compression:

| Level | Behavior |
|-------|----------|
| `lite` | Plain backticks by default; link only on explicit ask or first introduction. |
| `paranoid` (default) | Every resolvable code term linked, first occurrence. |
| `ocd` | Every resolvable code term, every occurrence, maximal density. |
| `yolo` | Off — plain backticks, no verification. |

Switch with `/cited-code lite|paranoid|ocd|yolo`, or say it naturally
("cited-code ocd", "stop cited-code").

## Install

```
/plugin marketplace add BalaMithran/cited-code
/plugin install cited-code
```

## How it works

- `SessionStart` hook announces the active level each session.
- `UserPromptSubmit` hook parses `/cited-code <level>` (or natural-language
  switches), persists it to `<project>/.claude/.cited-code-level`, and
  re-injects a short reminder every turn.
- `skills/cited-code/SKILL.md` is the full spec the hooks summarize —
  read it for the exact linking rules.

No external dependencies — plain bash.
