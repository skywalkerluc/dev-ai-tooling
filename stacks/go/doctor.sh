#!/usr/bin/env bash
set -euo pipefail
PROJECT="${1:-${PWD}}"
if command -v go >/dev/null 2>&1; then
  echo "OK: go available"
  exit 0
fi
echo "WARN: go not found (expected when working on Go projects)"
exit 0
