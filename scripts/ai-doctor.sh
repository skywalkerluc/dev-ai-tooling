#!/usr/bin/env bash
# Health checks for AI/dev tooling installation.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

REPO_ROOT="$(repo_root)"
PROJECT_DIR="${1:-${PWD}}"

declare -i OK=0 WARN=0 SKIP=0 FAIL=0

status_ok()   { log_ok "$1"; ((OK++)) || true; }
status_warn() { log_warn "$1"; ((WARN++)) || true; }
status_skip() { log_skip "$1"; ((SKIP++)) || true; }
status_fail() { log_fail "$1"; ((FAIL++)) || true; }

check_cmd_optional() {
  local label="$1"
  local cmd="$2"
  if command_exists "$cmd"; then
    status_ok "${label}: available ($(command -v "$cmd"))"
  else
    status_skip "${label}: not installed"
  fi
}

check_cmd_when_stack() {
  local stack="$1"
  local label="$2"
  local cmd="$3"
  local detected="$4"

  if [[ "$detected" != *"$stack"* ]]; then
    status_skip "${label}: stack '${stack}' not detected"
    return
  fi
  if command_exists "$cmd"; then
    status_ok "${label}: available ($(command -v "$cmd"))"
  else
    status_warn "${label}: expected for ${stack} project but '${cmd}' not found"
  fi
}

check_symlink() {
  local path="$1"
  local expected_prefix="$2"
  if [[ ! -e "$path" ]]; then
    status_skip "symlink missing: ${path}"
    return
  fi
  if [[ -L "$path" ]]; then
    local target
    target="$(readlink "$path")"
    if [[ "$target" == "$expected_prefix"* ]] || [[ "$target" == "${REPO_ROOT}"* ]]; then
      status_ok "symlink valid: ${path} -> ${target}"
    else
      status_warn "symlink unexpected target: ${path} -> ${target}"
    fi
  else
    status_warn "not a symlink (local file?): ${path}"
  fi
}

check_json_templates() {
  for tpl in "${REPO_ROOT}/claude/settings.template.json" "${REPO_ROOT}/cursor/settings.template.json"; do
    local name="${tpl#${REPO_ROOT}/}"
    if [[ -f "$tpl" ]]; then
      if json_valid "$tpl"; then
        status_ok "JSON valid: ${name}"
      else
        status_fail "JSON invalid: ${name}"
      fi
    else
      status_warn "missing template: ${name}"
    fi
  done
}

check_hooks_executable() {
  for hooks_dir in "${REPO_ROOT}/claude/hooks" "${REPO_ROOT}/cursor/hooks"; do
    [[ -d "$hooks_dir" ]] || continue
    shopt -s nullglob
    local hook
    for hook in "${hooks_dir}"/*.sh; do
      if [[ -x "$hook" ]]; then
        status_ok "hook executable: ${hook}"
      else
        status_warn "hook not executable: ${hook}"
      fi
    done
    shopt -u nullglob
  done
}

check_secrets() {
  local patterns=(
    'OPENAI_API_KEY'
    'ANTHROPIC_API_KEY'
    'GITHUB_TOKEN'
    'AWS_SECRET_ACCESS_KEY'
    'BEGIN RSA PRIVATE KEY'
    'BEGIN OPENSSH PRIVATE KEY'
    'password='
    'token='
    'secret='
  )
  local found=0
  while IFS= read -r -d '' file; do
    for pat in "${patterns[@]}"; do
      if grep -qE "$pat" "$file" 2>/dev/null; then
        status_warn "possible secret pattern '${pat}' in ${file#${REPO_ROOT}/}"
        found=1
        break
      fi
    done
  done < <(safe_find "$REPO_ROOT" -type f \
    ! -path '*/.git/*' \
    ! -name '*.md' \
    ! -path '*/scripts/ai-doctor.sh' \
    -print0 2>/dev/null)

  if [[ "$found" -eq 0 ]]; then
    status_ok "no obvious secret patterns in tracked-like files"
  fi
}

check_duplicate_skills() {
  local claude_skills="${HOME}/.claude/skills"
  local cursor_skills="${HOME}/.cursor/skills"
  if [[ -d "$claude_skills" && -d "$cursor_skills" ]]; then
    local dup
    dup="$(comm -12 <(find "$claude_skills" -mindepth 1 -maxdepth 1 -exec basename {} \; 2>/dev/null | sort) \
                  <(find "$cursor_skills" -mindepth 1 -maxdepth 1 -exec basename {} \; 2>/dev/null | sort) || true)"
    if [[ -n "$dup" ]]; then
      status_warn "duplicate skill names in Claude and Cursor: $(echo "$dup" | tr '\n' ' ')"
    else
      status_ok "no duplicate top-level skill names between Claude and Cursor"
    fi
  else
    status_skip "skills directories not both present for duplicate check"
  fi
}

check_commands_exist() {
  for cmd_dir in "${REPO_ROOT}/claude/commands" "${REPO_ROOT}/cursor/commands"; do
    [[ -d "$cmd_dir" ]] || continue
    shopt -s nullglob
    local cmd
    for cmd in "${cmd_dir}"/*; do
      [[ -e "$cmd" ]] || continue
      status_ok "command file exists: ${cmd#${REPO_ROOT}/}"
    done
    shopt -u nullglob
  done
}

detected_stacks=""
if [[ -d "$PROJECT_DIR" ]]; then
  detected_stacks="$("${REPO_ROOT}/scripts/detect-project-stack.sh" "$PROJECT_DIR" 2>/dev/null | paste -sd, - || true)"
fi

log_info "AI tooling doctor (repo: ${REPO_ROOT})"
log_info "Project context: ${PROJECT_DIR}"
[[ -n "$detected_stacks" ]] && log_info "Detected stacks: ${detected_stacks}"

echo
echo "=== Tools ==="
check_cmd_optional "claude CLI" claude
check_cmd_optional "codex CLI" codex
check_cmd_optional "cursor CLI" cursor

echo
echo "=== Global runtime (informational) ==="
check_cmd_optional "node" node
check_cmd_optional "pnpm" pnpm
check_cmd_optional "typescript-language-server" typescript-language-server
check_cmd_optional "terraform-ls" terraform-ls

echo
echo "=== Stack tools (when detected) ==="
check_cmd_when_stack "scala" "sbt" sbt "$detected_stacks"
check_cmd_when_stack "python" "python3" python3 "$detected_stacks"
check_cmd_when_stack "go" "go" go "$detected_stacks"
check_cmd_when_stack "java" "java" java "$detected_stacks"
check_cmd_when_stack "dotnet" "dotnet" dotnet "$detected_stacks"
check_cmd_when_stack "terraform" "terraform" terraform "$detected_stacks"

echo
echo "=== Symlinks ==="
check_symlink "${HOME}/.claude/CLAUDE.md" "${REPO_ROOT}"
for dir in skills commands agents hooks rules; do
  check_symlink "${HOME}/.claude/${dir}" "${REPO_ROOT}"
  check_symlink "${HOME}/.cursor/${dir}" "${REPO_ROOT}"
done
check_symlink "${HOME}/.codex/prompts" "${REPO_ROOT}"
check_symlink "${HOME}/.codex/review-prompts" "${REPO_ROOT}"
check_symlink "${HOME}/.codex/core" "${REPO_ROOT}"

echo
echo "=== Repo integrity ==="
check_json_templates
check_hooks_executable
check_commands_exist
check_duplicate_skills
check_secrets

PARITY="${REPO_ROOT}/scripts/check-ai-tooling-parity.sh"
if [[ -x "$PARITY" ]]; then
  echo
  echo "=== Parity ==="
  "$PARITY" || status_warn "parity check reported differences"
fi

echo
echo "=== Summary ==="
printf 'OK=%s WARN=%s SKIP=%s FAIL=%s\n' "$OK" "$WARN" "$SKIP" "$FAIL"

if ((FAIL > 0)); then
  exit 1
fi
exit 0
