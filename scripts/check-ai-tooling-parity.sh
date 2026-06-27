#!/usr/bin/env bash
# Compare Claude and Cursor tooling for naming parity.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

REPO_ROOT="$(repo_root)"

compare_dirs() {
  local label="$1"
  local left="$2"
  local right="$3"

  if [[ ! -d "$left" && ! -d "$right" ]]; then
    log_skip "${label}: both directories missing"
    return 0
  fi
  if [[ ! -d "$left" ]]; then
    log_warn "${label}: missing ${left#${REPO_ROOT}/}"
    return 0
  fi
  if [[ ! -d "$right" ]]; then
    log_warn "${label}: missing ${right#${REPO_ROOT}/}"
    return 0
  fi

  local only_left only_right
  only_left="$(comm -23 <(find "$left" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort) \
                        <(find "$right" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort) || true)"
  only_right="$(comm -13 <(find "$left" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort) \
                         <(find "$right" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort) || true)"

  if [[ -n "$only_left" ]]; then
    log_warn "${label}: only in claude: $(echo "$only_left" | tr '\n' ' ')"
  fi
  if [[ -n "$only_right" ]]; then
    log_warn "${label}: only in cursor: $(echo "$only_right" | tr '\n' ' ')"
  fi
  if [[ -z "$only_left" && -z "$only_right" ]]; then
    log_ok "${label}: names match"
  fi
}

check_hooks_referenced() {
  for hooks_dir in "${REPO_ROOT}/claude/hooks" "${REPO_ROOT}/cursor/hooks"; do
    [[ -d "$hooks_dir" ]] || continue
    shopt -s nullglob
    local hook
    for hook in "${hooks_dir}"/*.sh; do
      if [[ -x "$hook" ]]; then
        log_ok "hook exists and executable: ${hook#${REPO_ROOT}/}"
      else
        log_warn "hook missing or not executable: ${hook#${REPO_ROOT}/}"
      fi
    done
    shopt -u nullglob
  done
}

log_info "Checking Claude/Cursor parity"

compare_dirs "agents" "${REPO_ROOT}/claude/agents" "${REPO_ROOT}/cursor/agents"
compare_dirs "skills" "${REPO_ROOT}/claude/skills" "${REPO_ROOT}/cursor/skills"
compare_dirs "commands" "${REPO_ROOT}/claude/commands" "${REPO_ROOT}/cursor/commands"

echo
check_hooks_referenced

exit 0
