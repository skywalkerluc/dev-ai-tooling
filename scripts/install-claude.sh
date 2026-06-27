#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

REPO_ROOT="$(repo_root)"
CLAUDE_HOME="${CLAUDE_HOME:-${HOME}/.claude}"

install_claude() {
  log_info "Installing Claude global symlinks -> ${CLAUDE_HOME}"

  ensure_dir "$CLAUDE_HOME"

  create_symlink "${REPO_ROOT}/claude/CLAUDE.md" "${CLAUDE_HOME}/CLAUDE.md"

  for dir in skills commands agents hooks rules; do
    if [[ -d "${REPO_ROOT}/claude/${dir}" ]]; then
      create_symlink "${REPO_ROOT}/claude/${dir}" "${CLAUDE_HOME}/${dir}"
    fi
  done

  if [[ -f "${REPO_ROOT}/claude/settings.template.json" ]]; then
    if [[ ! -f "${CLAUDE_HOME}/settings.json" ]]; then
      if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would copy settings.template.json -> settings.json (first install only)"
      else
        cp "${REPO_ROOT}/claude/settings.template.json" "${CLAUDE_HOME}/settings.json"
        log_ok "created ${CLAUDE_HOME}/settings.json from template (customize locally)"
      fi
    else
      log_skip "settings.json already exists (not overwritten)"
    fi
  fi

  if [[ -d "${CLAUDE_HOME}/hooks" ]]; then
    find "${CLAUDE_HOME}/hooks" -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
  fi
}

install_claude "$@"
