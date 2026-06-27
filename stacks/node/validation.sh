#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PROJECT="${1:-${PWD}}"
exec "${REPO_ROOT}/scripts/detect-validation-commands.sh" "$PROJECT"
