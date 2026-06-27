#!/usr/bin/env bash
set -euo pipefail
PROJECT="${1:-${PWD}}"
if command -v python3 >/dev/null 2>&1; then
  echo "OK: python3 available"
  exit 0
fi
echo "WARN: python3 not found (expected when working on Python projects)"
exit 0
