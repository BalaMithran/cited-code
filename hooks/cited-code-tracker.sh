#!/bin/bash
# cited-code — UserPromptSubmit hook. Handles /cited-code <level> switches and
# re-injects a short reminder every turn (context compression/other plugins
# can bump this out of attention otherwise).
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_FILE="$PROJECT_DIR/.claude/.cited-code-level"

INPUT="$(cat)"
LOWER="$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')"

CURRENT="paranoid"
if [ -f "$STATE_FILE" ]; then
  READ="$(tr -d '[:space:]' < "$STATE_FILE")"
  case "$READ" in yolo|lite|paranoid|ocd) CURRENT="$READ" ;; esac
fi

NEW=""
if [[ "$LOWER" =~ /cited-code[[:space:]]+(yolo|lite|paranoid|ocd) ]]; then
  NEW="${BASH_REMATCH[1]}"
elif [[ "$LOWER" == *"cited-code"* ]]; then
  if [[ "$LOWER" =~ (stop|disable|turn off|deactivate)[^\"]*cited-code|cited-code[^\"]*(stop|disable|off) ]]; then
    NEW="yolo"
  elif [[ "$LOWER" =~ cited-code[^\"]*(yolo|lite|paranoid|ocd) ]]; then
    NEW="${BASH_REMATCH[1]}"
  fi
fi

if [ -n "$NEW" ]; then
  mkdir -p "$(dirname "$STATE_FILE")"
  printf '%s' "$NEW" > "$STATE_FILE"
  CURRENT="$NEW"
fi

if [ "$CURRENT" = "yolo" ]; then
  exit 0
fi

case "$CURRENT" in
  lite) MSG="CITED-CODE ACTIVE (lite). Plain backticks by default; link only on explicit ask or one anchor per file/function first introduced.";;
  paranoid) MSG="CITED-CODE ACTIVE (paranoid). Every resolvable code term becomes a markdown link verified via a tool call run this turn; ambiguous or hypothetical stays plain.";;
  ocd) MSG="CITED-CODE ACTIVE (ocd). Link every resolvable code term at every occurrence, incl. status lines and dir/route/config refs; still verified this turn only.";;
esac

printf '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "%s"}}' "$MSG"
