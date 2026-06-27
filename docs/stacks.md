# Stack packs

Optional overlays under `stacks/<name>/` extend base templates with stack-specific guidance.

## Supported stacks

| Stack | Detection markers |
|-------|-------------------|
| `node` | `package.json`, lockfiles |
| `scala` | `build.sbt`, `project/build.properties`, `.scala-version` |
| `python` | `pyproject.toml`, `requirements.txt`, `poetry.lock`, `uv.lock`, `Pipfile` |
| `go` | `go.mod` |
| `java` | `pom.xml`, `build.gradle`, `gradlew` |
| `dotnet` | `*.csproj`, `*.sln` |
| `clojure` | `deps.edn`, `project.clj`, `shadow-cljs.edn` |
| `terraform` | `*.tf`, `.terraform.lock.hcl` |

## Pack contents

Each stack directory may contain:

- `AGENTS.md` — partial Codex instructions
- `CLAUDE.md` — partial Claude instructions
- `validation.sh` — delegates to `detect-validation-commands.sh`
- `doctor.sh` — lightweight stack tool check
- `prompts/` — stack-specific prompts

## Adding a new stack

1. Create `stacks/<name>/` with the files above.
2. Add detection logic to `scripts/detect-project-stack.sh`.
3. Add validation suggestions to `scripts/detect-validation-commands.sh`.
4. Add `templates/project/<name>/` if you need project template fragments.
5. Run `./doctor.sh` and test detection on a sample repo.

## Conflicts

When multiple lockfiles or conflicting markers appear, scripts **warn** and avoid assuming a single package manager or build tool.
