#!/usr/bin/env bash
set -euo pipefail
PROJECT="${1:-${PWD}}"
if command -v sbt >/dev/null 2>&1; then
  echo "OK: sbt available"
  exit 0
fi
echo "WARN: sbt not found (expected when working on Scala projects)"
exit 0
