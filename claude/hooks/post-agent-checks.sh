#!/usr/bin/env bash
# Placeholder post-agent hook: suggests project validation commands.
# Does not assume a specific stack or package manager.
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -P "${SCRIPT_DIR}/../.." && pwd -P)"
DETECT_SCRIPT="${REPO_ROOT}/scripts/detect-validation-commands.sh"

PROJECT_DIR="${DEV_AI_TOOLING_PROJECT_DIR:-${PWD}}"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "SKIP: project directory not found: ${PROJECT_DIR}" >&2
  exit 0
fi

if [[ ! -x "$DETECT_SCRIPT" ]]; then
  echo "SKIP: detect-validation-commands.sh not found or not executable" >&2
  exit 0
fi

echo "=== Suggested validation for ${PROJECT_DIR} ==="
"$DETECT_SCRIPT" "$PROJECT_DIR" || true

if [[ "${DEV_AI_TOOLING_RUN_VALIDATION:-}" == "1" ]]; then
  echo "DEV_AI_TOOLING_RUN_VALIDATION=1 is set but auto-run is disabled by default."
  echo "Run suggested commands manually or extend this hook for your project."
fi

exit 0
