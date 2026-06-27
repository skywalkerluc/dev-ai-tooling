#!/usr/bin/env bash
# Warns on potentially dangerous migration or schema operations.
# Agnostic: recognizes common SQL/ORM/migration terms across stacks.
set -euo pipefail

INPUT="${1:-}"
if [[ -z "$INPUT" && -t 0 ]]; then
  INPUT="$(cat || true)"
fi

if [[ -z "$INPUT" ]]; then
  exit 0
fi

DANGER_PATTERNS=(
  'drop[[:space:]]+column'
  'drop[[:space:]]+table'
  'truncate[[:space:]]+table'
  'delete[[:space:]]+from'
  'alter[[:space:]]+table.*drop'
  'remove_column'
  'dropColumn'
  'drop_table'
  'dropTable'
  'down[[:space:]]*\('
  'revert[[:space:]]+migration'
  'rollback[[:space:]]+migration'
  'destructive'
  'schema[[:space:]]+change'
  'migration.*drop'
)

found=0
for pattern in "${DANGER_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qiE "$pattern"; then
    found=1
    break
  fi
done

if [[ "$found" -eq 1 ]]; then
  echo "WARN: Possible destructive migration or schema change detected." >&2
  echo "Review carefully: inspect existing migrations and backup strategy." >&2
  echo "Matched context (truncated):" >&2
  echo "$INPUT" | head -c 500 >&2
  echo >&2
  exit 2
fi

exit 0
