#!/usr/bin/env bash
# SessionStart hook — injects the rolling project state into context before the
# first user message, so resuming never depends on the agent remembering to look.
# Keep the output SMALL: it is paid on every single session.
set -u
DIR="${CLAUDE_PROJECT_DIR:-.}"
STATE="$DIR/.planning/STATE.md"
TODO="$DIR/.planning/TODO.md"

if [ ! -f "$STATE" ]; then
  echo "Kein .planning/STATE.md vorhanden — beim ersten Stopping Point den session-save Skill fahren, um es anzulegen."
  exit 0
fi

echo "## Projektstand (automatisch injiziert aus .planning/STATE.md)"
echo
cat "$STATE"

if [ -f "$TODO" ]; then
  OPEN=$(grep -c '^\s*- \[ \]' "$TODO" 2>/dev/null || echo 0)
  echo
  echo "Offene TODO-Einträge: $OPEN (Details in .planning/TODO.md — für das volle Bild den session-start Skill fahren)."
fi
