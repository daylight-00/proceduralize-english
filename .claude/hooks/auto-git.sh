#!/usr/bin/env bash
# Auto-commit and push KB files on Stop. CLAUDE.md is intentionally excluded —
# rules-file edits go through the §10 propose/approve/changelog protocol.
set -euo pipefail
cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Only proceed inside a git repo.
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

git add sessions.md level.md chunks.md retired_targets.md assimilation_policy.md 2>/dev/null || true

if git diff --cached --quiet; then
  exit 0
fi

git commit -m "session $(date +%F)" >/dev/null

if git push >/dev/null 2>&1; then
  echo "auto-git: pushed session log to origin"
else
  echo "auto-git: committed locally; push failed (check network/remote)" >&2
fi
