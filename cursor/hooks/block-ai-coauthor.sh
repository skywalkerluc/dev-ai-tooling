#!/usr/bin/env bash
# Cursor equivalent: blocks AI co-author trailers in commit messages.
REAL_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec "${REAL_DIR}/../../claude/hooks/block-ai-coauthor.sh" "$@"
