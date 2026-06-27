# Project Claude instructions

Base instructions for this repository. Stack-specific sections may be appended by `sync-project-tooling.sh`.

## Core behavior

- Prefer investigating before editing on medium or large tasks.
- Keep diffs small; follow existing project patterns.
- Detect package manager, build tool, and commands from the project.
- Do not assume npm, yarn, pnpm, or bun by default.
- Run the smallest relevant validation before finishing.

## Git

- Do not create commits unless explicitly requested.
- Do not push without explicit confirmation.
- Never add AI co-author trailers.

## Completion

Report files changed, validation run, and remaining risks.
