#!/usr/bin/env bash
set -euo pipefail
PROJECT="${1:-${PWD}}"
if command -v dotnet >/dev/null 2>&1; then
  echo "OK: dotnet available"
  exit 0
fi
echo "WARN: dotnet not found (expected when working on .NET projects)"
exit 0
