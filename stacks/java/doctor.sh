#!/usr/bin/env bash
set -euo pipefail
PROJECT="${1:-${PWD}}"
if command -v java >/dev/null 2>&1; then
  echo "OK: java available"
  exit 0
fi
echo "WARN: java not found (expected when working on Java projects)"
exit 0
