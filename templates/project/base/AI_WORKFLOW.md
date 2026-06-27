# AI workflow guide

How to choose the right AI tooling primitive for a task in this project.

## When to use what

| Situation | Prefer |
|-----------|--------|
| Open-ended implementation or refactor | Agent |
| Repeatable procedure with fixed steps | Skill |
| One-shot prompt you run often | Command |
| Enforce policy at tool events (commit, push, edits) | Hook |
| External data or actions (issues, logs, browser) | MCP |

## Agents

Use agents for multi-step work that needs exploration, coding, and verification. Good for features, non-trivial bugfixes, and refactors.

## Skills

Use skills when the workflow is documented, reusable, and should be invoked consistently (e.g. PR preparation, migration review, test writing conventions).

## Commands

Use commands for short, repeatable prompts (review this diff, summarize failures, generate checklist).

## Hooks

Use hooks to enforce guardrails: block AI co-authors, warn on dangerous migrations, gate `git push`, or suggest validation after agent runs.

## MCP

Use MCP when the task needs live context from external systems. Prefer project-documented MCP servers; never commit tokens or credentials.

## Multi-repo work

For work spanning multiple repositories:

1. Identify which repo owns each change.
2. Sync project tooling per repo with `sync-project-tooling.sh`.
3. Run validation per repo; do not assume a single global package manager.
4. Keep cross-repo notes in issues or a shared doc, not in global personal config.

## Decision matrix

| Phase | Goal | Tooling |
|-------|------|---------|
| Understand | Map codebase, find owners | Agent + search/LSP |
| Plan | Compare approaches | Agent or command |
| Implement | Minimal correct diff | Agent + project scripts |
| Validate | Run detected commands | `detect-validation-commands.sh` |
| Review | Adversarial pass | Separate agent/command |
| Ship | Commit/PR only when asked | Human confirmation + hooks |

## Investigation vs implementation vs adversarial review

1. **Investigation** — read, trace, reproduce; avoid large edits.
2. **Implementation** — smallest change that satisfies requirements; run minimal validation.
3. **Adversarial review** — assume bugs and missed edge cases; challenge diffs and tests.

Do not skip investigation on medium/large tasks. Do not merge review into implementation without explicit intent.
