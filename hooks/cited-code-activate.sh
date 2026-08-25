#!/bin/bash
# cited-code — SessionStart hook. Announces the active citation-density level.
# State is per-project: <project>/.claude/.cited-code-level (gitignore it —
# it's a per-dev preference, not a team setting).
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_FILE="$PROJECT_DIR/.claude/.cited-code-level"

LEVEL="paranoid"
if [ -f "$STATE_FILE" ]; then
  READ="$(tr -d '[:space:]' < "$STATE_FILE")"
  case "$READ" in lite|paranoid|ocd|yolo) LEVEL="$READ" ;; esac
fi

if [ "$LEVEL" = "yolo" ]; then
  echo -n "cited-code: yolo (off)"
  exit 0
fi

case "$LEVEL" in
  lite)
    RULE="Default to plain \`backticks\`. Add a real markdown link only when explicitly asked, or once per file/function the first time it's introduced in the answer — not every occurrence."
    ;;
  paranoid)
    RULE="Every resolvable code term (file, function, var, config key, route, line ref) in the answer becomes a markdown link to its real location, verified via a tool call run THIS turn. Ambiguous (multiple matches) or hypothetical (doesn't exist yet) code stays plain \`backticks\` — never guess."
    ;;
  ocd)
    RULE="Same verification rule as paranoid, but link every occurrence of a resolvable term, not just the first — including status/summary lines, directory refs, and route/config strings. Maximal density."
    ;;
esac

echo "CITED-CODE MODE ACTIVE — level: $LEVEL

$RULE

Switch: /cited-code lite|paranoid|ocd|yolo. Persists (per-project) until changed or the state file is deleted."
