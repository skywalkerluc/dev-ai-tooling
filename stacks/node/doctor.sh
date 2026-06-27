#!/usr/bin/env bash
set -euo pipefail
PROJECT="${1:-${PWD}}"
if command -v node >/dev/null 2>&1; then
  echo "OK: node available"
  exit 0
fi
echo "WARN: node not found (expected when working on Node / TypeScript projects)"
exit 0
