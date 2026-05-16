#!/usr/bin/env bash
# PreToolUse guard: force "ask" decision on any Edit/Write/MultiEdit targeting CLAUDE.md.
# Implements CLAUDE.md §8 ("no silent CLAUDE.md edits") and §10 (approve-and-log).
set -euo pipefail

input=$(cat)

if grep -qE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*CLAUDE\.md"' <<<"$input"; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"CLAUDE.md edit — §10 requires an approved EDIT PROPOSAL with diff and changelog entry. Confirm to apply."}}
JSON
fi
exit 0
