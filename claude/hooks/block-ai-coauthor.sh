#!/usr/bin/env bash
# Blocks git commit messages that include AI co-author trailers.
set -euo pipefail

BLOCK_PATTERNS=(
  'Co-authored-by:.*[Cc]ursor'
  'Co-authored-by:.*[Aa][Ii]'
  'Co-authored-by:.*[Cc]odex'
  'Co-authored-by:.*[Gg]PT'
  'Co-authored-by:.*[Cc]laude'
  'Co-authored-by:.*agent@'
  'Co-authored-by:.*cursoragent@'
)

read -r message || message=""

for pattern in "${BLOCK_PATTERNS[@]}"; do
  if echo "$message" | grep -qiE "$pattern"; then
    echo "Blocked: commit message contains AI co-author trailer matching: ${pattern}" >&2
    echo "Remove Co-authored-by lines for AI assistants before committing." >&2
    exit 1
  fi
done

exit 0
