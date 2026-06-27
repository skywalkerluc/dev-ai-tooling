#!/usr/bin/env bash
set -euo pipefail
PROJECT="${1:-${PWD}}"
if command -v clojure >/dev/null 2>&1; then
  echo "OK: clojure available"
  exit 0
fi
echo "WARN: clojure not found (expected when working on Clojure projects)"
exit 0
