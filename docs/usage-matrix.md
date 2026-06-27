# Usage matrix

Quick reference for global vs project-local AI tooling.

| Artifact | Global (symlink) | Project (copy) | Notes |
|----------|------------------|----------------|-------|
| CLAUDE.md | `~/.claude/CLAUDE.md` | `.claude/CLAUDE.md` | Project file composes base + stacks |
| Skills | `~/.claude/skills` | `.claude/skills/` (manual) | Project skills stay in repo |
| Commands | `~/.claude/commands` | optional | Parity with Cursor recommended |
| Hooks | `~/.claude/hooks` | `.claude/hooks/` | Copied by sync script |
| Cursor rules | `~/.cursor/rules` | `.cursor/rules/` | Copied by sync script |
| AGENTS.md (Codex) | `~/.codex/AGENTS.md` | `./AGENTS.md` | Template + stack packs |
| AI_WORKFLOW.md | — | `./AI_WORKFLOW.md` | Project onboarding doc |

## Commands

| Task | Command |
|------|---------|
| Install global | `./install.sh` |
| Update | `./update.sh` |
| Health check | `./doctor.sh` |
| Detect stack | `./scripts/detect-project-stack.sh <project>` |
| Suggest validation | `./scripts/detect-validation-commands.sh <project>` |
| Sync project | `./scripts/sync-project-tooling.sh --project <path> --tool all --auto-detect` |

## Tool selection

| Flag | Effect |
|------|--------|
| `--tool claude` | Sync Claude project files only |
| `--tool cursor` | Sync Cursor project files only |
| `--tool codex` | Sync AGENTS.md + AI_WORKFLOW.md |
| `--tool all` | All of the above |
| `--auto-detect` | Detect stacks from filesystem |
| `--stack node,terraform` | Force stack packs |
| `--dry-run` | Print actions without writing |
