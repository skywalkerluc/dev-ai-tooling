#!/usr/bin/env bash
# Prompts for confirmation before git push (hook or wrapper usage).
set -euo pipefail

if [[ "${DEV_AI_TOOLING_ALLOW_PUSH:-}" == "1" ]]; then
  exit 0
fi

if [[ ! -t 0 ]] && [[ ! -t 1 ]]; then
  echo "WARN: git push blocked in non-interactive mode. Set DEV_AI_TOOLING_ALLOW_PUSH=1 to override." >&2
  exit 1
fi

echo "About to run: git push $*" >&2
read -r -p "Confirm git push? [y/N] " answer
case "$answer" in
  y|Y|yes|YES) exit 0 ;;
  *) echo "Push cancelled." >&2; exit 1 ;;
esac
