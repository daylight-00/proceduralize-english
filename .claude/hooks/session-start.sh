#!/usr/bin/env bash
# Auto-inject session opening context per CLAUDE.md §4.1.
# stdout from SessionStart hooks is added to the model's context.
set -euo pipefail
cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

echo "## Session opening context (auto-loaded per CLAUDE.md §4.1)"
echo

if [[ -f sessions.md ]]; then
  echo "### Last 3 entries from sessions.md"
  awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].*session/ {c++; if (c>3) exit} {print}' sessions.md
  echo
fi

if [[ -f level.md ]]; then
  echo "### Current CEFR snapshot (level.md)"
  cat level.md
  echo
fi
