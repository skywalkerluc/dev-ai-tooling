# Multi-repo pattern

Use this repo as the **single source of truth** for personal global tooling. Use **per-project copies** for repo-specific agents, skills, hooks, and context.

## Global personal setup

```bash
git clone git@github.com:YOUR_USER/dev-ai-tooling.git ~/dev-ai-tooling
cd ~/dev-ai-tooling
./install.sh
```

Global install creates symlinks:

- `~/.claude/*` → `~/dev-ai-tooling/claude/*`
- `~/.cursor/*` → `~/dev-ai-tooling/cursor/*`
- `~/.codex/*` → `~/dev-ai-tooling/codex/*` (where applicable)

## Per-project setup

Do **not** symlink global configs into a project repo. Generate copies:

```bash
~/dev-ai-tooling/scripts/sync-project-tooling.sh \
  --project ~/work/my-service \
  --tool all \
  --auto-detect
```

Commit project-local files that belong to the team:

- `.claude/CLAUDE.md` (composed)
- `.claude/hooks/` (if team agrees)
- `.cursor/rules/` (if team agrees)
- `AGENTS.md`, `AI_WORKFLOW.md` (optional)

Keep secrets and machine-specific paths out of git.

## Multiple checkouts

Each machine:

1. Clone `dev-ai-tooling` to a stable path (e.g. `~/dev-ai-tooling`).
2. Run `./install.sh` (idempotent).
3. Customize `~/.claude/settings.json` locally (never commit).

If repo path differs per machine, symlinks update automatically after `install.sh`.

## Cross-repo features

For work spanning services:

1. Run stack detection in each repo.
2. Sync tooling per repo.
3. Track integration contracts in issues/docs, not in global CLAUDE.md.
