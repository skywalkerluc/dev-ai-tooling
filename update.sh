#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== dev-ai-tooling update ==="

if [[ -d "${REPO_ROOT}/.git" ]]; then
  git -C "$REPO_ROOT" pull --ff-only
else
  echo "WARN: not a git repository; skipping git pull" >&2
fi

export DRY_RUN=0
"${REPO_ROOT}/scripts/install-claude.sh"
"${REPO_ROOT}/scripts/install-cursor.sh"
"${REPO_ROOT}/scripts/install-codex.sh"

echo
"${REPO_ROOT}/doctor.sh"
