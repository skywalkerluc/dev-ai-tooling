#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DRY_RUN="${DRY_RUN:-0}"

echo "=== dev-ai-tooling install ==="
echo "Repo: ${REPO_ROOT}"
echo

chmod +x "${REPO_ROOT}/scripts/"*.sh 2>/dev/null || true
chmod +x "${REPO_ROOT}/"*.sh 2>/dev/null || true
find "${REPO_ROOT}/claude/hooks" "${REPO_ROOT}/cursor/hooks" -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
find "${REPO_ROOT}/stacks" -name '*.sh' -exec chmod +x {} + 2>/dev/null || true

"${REPO_ROOT}/scripts/install-claude.sh"
echo
"${REPO_ROOT}/scripts/install-cursor.sh"
echo
"${REPO_ROOT}/scripts/install-codex.sh"

echo
echo "=== Next steps ==="
cat <<EOF
1. Customize local configs (never commit these):
   - ~/.claude/settings.json
   - ~/.codex/AGENTS.md (if you copied from template)

2. Run health check:
   ./doctor.sh

3. Sync tooling into a project:
   ./scripts/sync-project-tooling.sh --project /path/to/project --tool all --auto-detect --dry-run
   ./scripts/sync-project-tooling.sh --project /path/to/project --tool all --auto-detect

4. Detect stack and validation for a project:
   ./scripts/detect-project-stack.sh /path/to/project
   ./scripts/detect-validation-commands.sh /path/to/project

Note: This installer uses symlinks for global setup and does not install heavy dependencies.
EOF
