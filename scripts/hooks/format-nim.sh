#!/usr/bin/env bash
# PostToolUse hook: format edited Nim files with nph.
# Reads the hook JSON payload on stdin and formats any *.nim path it mentions.
set -euo pipefail

payload="$(cat || true)"

# Extract candidate file paths ending in .nim from the payload (best-effort, no jq dependency).
paths="$(printf '%s' "$payload" | grep -oE '[A-Za-z0-9_./-]+\.nim' | sort -u || true)"

if ! command -v nph >/dev/null 2>&1; then
  exit 0  # nph not installed locally; do not block.
fi

for p in $paths; do
  [[ -f "$p" ]] && nph "$p" >/dev/null 2>&1 || true
done

exit 0
