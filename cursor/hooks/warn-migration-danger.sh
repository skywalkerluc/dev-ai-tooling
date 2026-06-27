#!/usr/bin/env bash
REAL_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec "${REAL_DIR}/../../claude/hooks/warn-migration-danger.sh" "$@"
