#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

REPO_ROOT="$(repo_root)"
CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"

install_codex() {
  log_info "Installing Codex global config -> ${CODEX_HOME}"

  ensure_dir "$CODEX_HOME"

  if [[ -f "${REPO_ROOT}/codex/AGENTS.template.md" ]]; then
    if [[ ! -f "${CODEX_HOME}/AGENTS.md" ]]; then
      if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_info "[dry-run] would copy AGENTS.template.md -> AGENTS.md"
      else
        cp "${REPO_ROOT}/codex/AGENTS.template.md" "${CODEX_HOME}/AGENTS.md"
        log_ok "created ${CODEX_HOME}/AGENTS.md from template"
      fi
    else
      log_skip "AGENTS.md already exists (not overwritten)"
    fi
  fi

  for dir in prompts review-prompts; do
    if [[ -d "${REPO_ROOT}/codex/${dir}" ]]; then
      create_symlink "${REPO_ROOT}/codex/${dir}" "${CODEX_HOME}/${dir}"
    fi
  done

  if [[ -d "${REPO_ROOT}/core" ]]; then
    create_symlink "${REPO_ROOT}/core" "${CODEX_HOME}/core"
  fi
}

install_codex "$@"
