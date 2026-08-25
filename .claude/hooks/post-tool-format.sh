#!/usr/bin/env bash
# PostToolUse hook — formats the file that Edit/Write just touched, if the stack has a
# formatter this script knows and it is installed. Optional building block: NOT wired
# in the template's settings.json; new-project enables it per stack (skill step 5).
# Never blocks the agent: every path exits 0, formatter output is discarded.
set -u
INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
FILE=${FILE//\\\\//}          # JSON-escaped Windows backslashes -> forward slashes
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

case "$FILE" in
  *.py)
    command -v uv >/dev/null 2>&1 && uv run --quiet ruff format "$FILE" >/dev/null 2>&1 ;;
  *.R|*.r)
    command -v Rscript >/dev/null 2>&1 && Rscript -e "styler::style_file('$FILE')" >/dev/null 2>&1 ;;
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css)
    [ -x node_modules/.bin/prettier ] && node_modules/.bin/prettier --write "$FILE" >/dev/null 2>&1 ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE" >/dev/null 2>&1 ;;
  *.rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE" >/dev/null 2>&1 ;;
esac
exit 0
