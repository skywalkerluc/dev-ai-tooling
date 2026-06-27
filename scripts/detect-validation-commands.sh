#!/usr/bin/env bash
# Suggest validation commands for a project (does not execute them).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DETECT_STACK="${SCRIPT_DIR}/detect-project-stack.sh"

usage() {
  cat <<'EOF'
Usage: detect-validation-commands.sh <project-path>

Prints detected stacks and suggested validation commands.
Does not run any commands.
EOF
}

json_has_script() {
  local script_name="$1"
  local pkg="${PROJECT}/package.json"
  [[ -f "$pkg" ]] || return 1
  if command -v python3 >/dev/null 2>&1; then
    [[ "$(python3 - "$script_name" "$pkg" <<'PY'
import json, sys
name, path = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = json.load(f)
scripts = data.get("scripts") or {}
print("yes" if name in scripts else "no")
PY
)" == "yes" ]]
  else
    grep -q "\"${script_name}\"" "$pkg" 2>/dev/null
  fi
}

suggest_node() {
  local pm=""
  if [[ -f "${PROJECT}/pnpm-lock.yaml" ]]; then pm="pnpm"
  elif [[ -f "${PROJECT}/yarn.lock" ]]; then pm="yarn"
  elif [[ -f "${PROJECT}/bun.lockb" ]]; then pm="bun"
  elif [[ -f "${PROJECT}/package-lock.json" ]]; then pm="npm"
  elif [[ -f "${PROJECT}/package.json" ]]; then
    echo "WARN: package.json found but no lockfile; cannot infer package manager." >&2
    return
  fi

  case "$pm" in
    pnpm)
      echo "pnpm install"
      echo "pnpm test"
      json_has_script typecheck && echo "pnpm typecheck"
      json_has_script lint && echo "pnpm lint"
      ;;
    yarn)
      echo "yarn install"
      echo "yarn test"
      json_has_script typecheck && echo "yarn typecheck"
      json_has_script lint && echo "yarn lint"
      ;;
    npm)
      echo "npm ci"
      echo "npm test"
      json_has_script typecheck && echo "npm run typecheck"
      json_has_script lint && echo "npm run lint"
      ;;
    bun)
      echo "bun install"
      json_has_script test && echo "bun test"
      json_has_script lint && echo "bun run lint"
      ;;
  esac
}

suggest_scala() {
  echo "sbt test"
  if [[ -f "${PROJECT}/.scalafmt.conf" ]] || [[ -f "${PROJECT}/project/plugins.sbt" ]]; then
    echo "sbt scalafmtCheckAll"
  fi
}

suggest_python() {
  if [[ -f "${PROJECT}/pyproject.toml" ]] || [[ -f "${PROJECT}/poetry.lock" ]]; then
    if grep -q '\[tool\.poetry\]' "${PROJECT}/pyproject.toml" 2>/dev/null || [[ -f "${PROJECT}/poetry.lock" ]]; then
      echo "poetry run pytest"
    fi
  fi
  if [[ -f "${PROJECT}/uv.lock" ]]; then
    echo "uv run pytest"
  fi
  if [[ -f "${PROJECT}/pytest.ini" ]] || [[ -f "${PROJECT}/pyproject.toml" ]] || [[ -d "${PROJECT}/tests" ]]; then
    echo "pytest"
  fi
  if [[ -f "${PROJECT}/pyproject.toml" ]] && grep -q '\[tool\.ruff\]' "${PROJECT}/pyproject.toml" 2>/dev/null; then
    echo "ruff check"
  fi
  if [[ -f "${PROJECT}/pyproject.toml" ]] && grep -q '\[tool\.mypy\]' "${PROJECT}/pyproject.toml" 2>/dev/null; then
    echo "mypy"
  fi
}

suggest_go() {
  echo "go test ./..."
  echo "go vet ./..."
}

suggest_java() {
  if [[ -f "${PROJECT}/pom.xml" ]]; then
    if [[ -x "${PROJECT}/mvnw" ]]; then echo "./mvnw test"
    else echo "mvn test"; fi
  fi
  if [[ -f "${PROJECT}/build.gradle" ]] || [[ -f "${PROJECT}/build.gradle.kts" ]] || [[ -f "${PROJECT}/gradlew" ]]; then
    if [[ -x "${PROJECT}/gradlew" ]]; then echo "./gradlew test"
    else echo "gradle test"; fi
  fi
}

suggest_dotnet() {
  echo "dotnet test"
}

suggest_clojure() {
  if [[ -f "${PROJECT}/deps.edn" ]]; then
    if grep -q ':aliases' "${PROJECT}/deps.edn" 2>/dev/null; then
      echo "clojure -M:test"
    fi
  fi
  if [[ -f "${PROJECT}/project.clj" ]]; then
    echo "lein test"
  fi
}

suggest_terraform() {
  echo "terraform fmt -check"
  echo "terraform validate"
}

run_suggest_for_stack() {
  case "$1" in
    node) suggest_node ;;
    scala) suggest_scala ;;
    python) suggest_python ;;
    go) suggest_go ;;
    java) suggest_java ;;
    dotnet) suggest_dotnet ;;
    clojure) suggest_clojure ;;
    terraform) suggest_terraform ;;
  esac
}

command_already_suggested() {
  local cmd="$1"
  local existing
  if ((${#PRINTED[@]} > 0)); then
    for existing in "${PRINTED[@]}"; do
      [[ "$existing" == "$cmd" ]] && return 0
    done
  fi
  return 1
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

PROJECT="$(cd "$1" 2>/dev/null && pwd)" || {
  echo "ERROR: invalid project path: $1" >&2
  exit 2
}

stacks=()
while IFS= read -r line; do
  [[ -n "$line" ]] && stacks+=("$line")
done < <("$DETECT_STACK" "$PROJECT" 2>/dev/null || true)

if ((${#stacks[@]} == 0)); then
  echo "Detected stacks: (none)"
  echo
  echo "Suggested validation:"
  echo "(no stack markers found)"
  exit 1
fi

echo "Detected stacks: $(IFS=,; echo "${stacks[*]}")"
echo
echo "Suggested validation:"

PRINTED=()
for stack in "${stacks[@]}"; do
  while IFS= read -r cmd; do
    [[ -z "$cmd" ]] && continue
    if command_already_suggested "$cmd"; then
      continue
    fi
    PRINTED+=("$cmd")
    echo "$cmd"
  done < <(run_suggest_for_stack "$stack")
done
