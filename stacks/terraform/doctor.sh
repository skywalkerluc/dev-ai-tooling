#!/usr/bin/env bash
set -euo pipefail
PROJECT="${1:-${PWD}}"
if command -v terraform >/dev/null 2>&1; then
  echo "OK: terraform available"
  exit 0
fi
echo "WARN: terraform not found (expected when working on Terraform projects)"
exit 0
