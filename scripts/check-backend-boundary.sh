#!/usr/bin/env bash
# Enforces pillar 2 (backend agnosticism): only src/tatui/backend/ may write to the
# terminal or emit escape sequences. Fails if terminal-output patterns appear elsewhere.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

# Patterns that indicate direct terminal output / raw escape emission.
pattern='stdout\.write|write\(stdout|writeStyled|\\e\[|\\x1b\[|\\027\['

# Search all Nim sources except the allowed backend directory.
violations="$(grep -REn "$pattern" src --include='*.nim' \
  | grep -v '^src/tatui/backend/' || true)"

if [[ -n "$violations" ]]; then
  echo "Backend boundary violation: terminal output outside src/tatui/backend/:"
  echo "$violations"
  exit 1
fi

echo "Backend boundary OK."
