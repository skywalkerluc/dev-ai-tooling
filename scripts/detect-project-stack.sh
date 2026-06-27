#!/usr/bin/env bash
# Detect project stacks from filesystem markers.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat <<'EOF'
Usage: detect-project-stack.sh <project-path>

Prints detected stacks (one per line), sorted and deduplicated.
Exits 0 when at least one stack is found, 1 when none, 2 on invalid path.
EOF
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

PROJECT="$(cd "$1" 2>/dev/null && pwd)" || {
  echo "ERROR: invalid project path: $1" >&2
  exit 2
}

declare -a STACKS=()

add_stack() {
  local stack="$1"
  local existing
  if ((${#STACKS[@]} > 0)); then
    for existing in "${STACKS[@]}"; do
      [[ "$existing" == "$stack" ]] && return
    done
  fi
  STACKS+=("$stack")
}

# Node / TypeScript ecosystem
if [[ -f "${PROJECT}/package.json" ]]; then
  add_stack "node"
fi

# Scala
if [[ -f "${PROJECT}/build.sbt" ]] \
  || [[ -f "${PROJECT}/project/build.properties" ]] \
  || [[ -f "${PROJECT}/.scala-version" ]]; then
  add_stack "scala"
fi

# Python
if [[ -f "${PROJECT}/pyproject.toml" ]] \
  || [[ -f "${PROJECT}/requirements.txt" ]] \
  || [[ -f "${PROJECT}/poetry.lock" ]] \
  || [[ -f "${PROJECT}/uv.lock" ]] \
  || [[ -f "${PROJECT}/Pipfile" ]]; then
  add_stack "python"
fi

# Go
if [[ -f "${PROJECT}/go.mod" ]]; then
  add_stack "go"
fi

# Java
if [[ -f "${PROJECT}/pom.xml" ]] \
  || [[ -f "${PROJECT}/build.gradle" ]] \
  || [[ -f "${PROJECT}/build.gradle.kts" ]] \
  || [[ -f "${PROJECT}/gradlew" ]]; then
  add_stack "java"
fi

# .NET
shopt -s nullglob
dotnet_files=("${PROJECT}"/*.csproj "${PROJECT}"/*.sln)
if ((${#dotnet_files[@]} > 0)); then
  add_stack "dotnet"
elif [[ -n "$(safe_find "$PROJECT" -maxdepth 3 \( -name '*.csproj' -o -name '*.sln' \) -print -quit 2>/dev/null | head -1)" ]]; then
  add_stack "dotnet"
fi

# Clojure
if [[ -f "${PROJECT}/deps.edn" ]] \
  || [[ -f "${PROJECT}/project.clj" ]] \
  || [[ -f "${PROJECT}/shadow-cljs.edn" ]]; then
  add_stack "clojure"
fi

# Terraform
tf_files=("${PROJECT}"/*.tf)
if [[ -f "${PROJECT}/.terraform.lock.hcl" ]] || ((${#tf_files[@]} > 0)); then
  add_stack "terraform"
elif [[ -n "$(safe_find "$PROJECT" -maxdepth 4 -name '*.tf' -print -quit 2>/dev/null | head -1)" ]]; then
  add_stack "terraform"
fi

shopt -u nullglob

# Conflict warnings (stderr)
node_locks=0
for lock in pnpm-lock.yaml yarn.lock package-lock.json bun.lockb; do
  [[ -f "${PROJECT}/${lock}" ]] && ((node_locks++)) || true
done
if ((node_locks > 1)); then
  echo "WARN: multiple Node lockfiles detected; do not assume package manager automatically." >&2
fi

if ((${#STACKS[@]} == 0)); then
  echo "WARN: no stacks detected in ${PROJECT}" >&2
  exit 1
fi

IFS=$'\n' sorted=($(printf '%s\n' "${STACKS[@]}" | sort))
unset IFS
printf '%s\n' "${sorted[@]}"
