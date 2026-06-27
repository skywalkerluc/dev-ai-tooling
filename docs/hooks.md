# Hooks

Generic hooks live in `claude/hooks/` with Cursor wrappers in `cursor/hooks/`.

## Included hooks

| Hook | Purpose |
|------|---------|
| `block-ai-coauthor.sh` | Blocks commit messages with AI `Co-authored-by` trailers |
| `gate-git-push.sh` | Prompts before `git push` (set `DEV_AI_TOOLING_ALLOW_PUSH=1` to bypass) |
| `warn-migration-danger.sh` | Warns on destructive migration/SQL patterns |
| `post-agent-checks.sh` | Prints suggested validation via `detect-validation-commands.sh` |

## Wiring

Configure hooks in your tool's settings (Claude Code / Cursor). Example Claude hook entry (adjust to your layout):

```json
{
  "hooks": {
    "PreToolUse": [],
    "PostToolUse": []
  }
}
```

Refer to each tool's documentation for exact hook event names and stdin format.

## Project hooks

`sync-project-tooling.sh` copies hooks into `.claude/hooks/` and `.cursor/hooks/` for team repos. Customize per project after sync.

## Environment variables

| Variable | Effect |
|----------|--------|
| `DEV_AI_TOOLING_ALLOW_PUSH=1` | Skip push confirmation gate |
| `DEV_AI_TOOLING_PROJECT_DIR` | Project path for post-agent checks |
| `DEV_AI_TOOLING_RUN_VALIDATION=1` | Reserved; auto-run disabled by default |
