#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

REPO_ROOT="$(repo_root)"
CURSOR_HOME="${CURSOR_HOME:-${HOME}/.cursor}"

install_cursor() {
  log_info "Installing Cursor global symlinks -> ${CURSOR_HOME}"

  ensure_dir "$CURSOR_HOME"

  for dir in rules commands agents skills hooks; do
    if [[ -d "${REPO_ROOT}/cursor/${dir}" ]]; then
      create_symlink "${REPO_ROOT}/cursor/${dir}" "${CURSOR_HOME}/${dir}"
    fi
  done

  if [[ -f "${REPO_ROOT}/cursor/settings.template.json" ]]; then
    if [[ ! -f "${CURSOR_HOME}/settings.json" ]]; then
      if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would copy settings.template.json -> settings.json (first install only)"
      else
        cp "${REPO_ROOT}/cursor/settings.template.json" "${CURSOR_HOME}/settings.json"
        log_ok "created ${CURSOR_HOME}/settings.json from template (customize locally)"
      fi
    else
      log_skip "settings.json already exists (not overwritten)"
    fi
  fi

  if [[ -d "${CURSOR_HOME}/hooks" ]]; then
    find "${CURSOR_HOME}/hooks" -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
  fi
}

install_cursor "$@"
