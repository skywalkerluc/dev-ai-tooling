#!/usr/bin/env bash
# Shared helpers for dev-ai-tooling scripts.
# shellcheck disable=SC2034

set -euo pipefail

log_info()  { printf '[INFO]  %s\n' "$*"; }
log_warn()  { printf '[WARN]  %s\n' "$*" >&2; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }
log_ok()    { printf '[OK]    %s\n' "$*"; }
log_skip()  { printf '[SKIP]  %s\n' "$*"; }
log_fail()  { printf '[FAIL]  %s\n' "$*" >&2; }

repo_root() {
  local lib_dir
  lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${lib_dir}/../.." && pwd
}

timestamp() {
  date +%Y%m%d%H%M%S
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

safe_find() {
  if [[ -x /usr/bin/find ]]; then
    /usr/bin/find "$@"
  else
    command find "$@"
  fi
}

backup_path_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local backup="${target}.backup-$(timestamp)"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
      log_info "[dry-run] would backup ${target} -> ${backup}"
    else
      cp -a "$target" "$backup"
      log_info "backup created: ${backup}"
    fi
  elif [[ -L "$target" ]]; then
    local backup="${target}.backup-$(timestamp)"
    local link_target
    link_target="$(readlink "$target" 2>/dev/null || true)"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
      log_info "[dry-run] would replace symlink: ${target}${link_target:+ -> ${link_target}}"
    else
      cp -a "$target" "$backup" 2>/dev/null || ln -sf "$link_target" "$backup"
      rm -f "$target"
      log_info "symlink backup note: ${backup} (was -> ${link_target})"
    fi
  fi
}

ensure_dir() {
  local dir="$1"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_info "[dry-run] would mkdir -p ${dir}"
  else
    mkdir -p "$dir"
  fi
}

create_symlink() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    log_fail "source does not exist: ${source}"
    return 1
  fi

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      log_skip "symlink already correct: ${target}"
      return 0
    fi
    backup_path_if_exists "$target"
  elif [[ -e "$target" ]]; then
    backup_path_if_exists "$target"
  fi

  ensure_dir "$(dirname "$target")"

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_info "[dry-run] would ln -sf ${source} ${target}"
  else
    ln -sf "$source" "$target"
    log_ok "symlink: ${target} -> ${source}"
  fi
}

copy_with_backup() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    log_fail "source does not exist: ${source}"
    return 1
  fi

  if [[ -e "$target" ]]; then
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
      log_info "[dry-run] would backup and copy ${source} -> ${target}"
      return 0
    fi
    local backup="${target}.backup-$(timestamp)"
    cp -a "$target" "$backup"
    log_info "backup created: ${backup}"
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_info "[dry-run] would copy ${source} -> ${target}"
    return 0
  fi

  ensure_dir "$(dirname "$target")"
  cp -a "$source" "$target"
  log_ok "copied: ${target}"
}

json_valid() {
  local file="$1"
  if command_exists python3; then
    python3 -m json.tool "$file" >/dev/null 2>&1
  elif command_exists jq; then
    jq empty "$file" >/dev/null 2>&1
  else
    return 0
  fi
}
