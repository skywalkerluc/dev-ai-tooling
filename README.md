# dev-ai-tooling

Repositório privado para versionar e instalar um setup pessoal de IA/dev tooling (Claude, Cursor, Codex) em múltiplos computadores.

## Propósito

- **Fonte única** para skills, commands, agents, hooks, rules e templates
- **Setup global** via symlinks (`~/.claude`, `~/.cursor`, `~/.codex`)
- **Setup de projeto** via cópias compositas (`sync-project-tooling.sh`)
- **Agnóstico de stack**: Node, Scala, Python, Go, Java, .NET, Clojure, Terraform e repos mistos

## Instalação

```bash
git clone git@github.com:skywalkerluc/dev-ai-tooling.git ~/dev-ai-tooling
cd ~/dev-ai-tooling
chmod +x install.sh update.sh doctor.sh scripts/*.sh
./install.sh
```

O instalador:

- Cria symlinks globais com backup de arquivos existentes
- Copia templates (`settings.template.json`, `AGENTS.template.md`) apenas na primeira vez
- **Não** instala dependências pesadas

## Atualização

```bash
./update.sh
```

Executa `git pull`, revalida symlinks e roda o doctor.

## Doctor

```bash
./doctor.sh
# ou com contexto de projeto:
./doctor.sh ~/work/my-project
```

Status: `OK`, `WARN`, `SKIP`, `FAIL`. O doctor global não falha só porque uma stack não está instalada na máquina.

## Detectar stack de um projeto

```bash
./scripts/detect-project-stack.sh ~/work/foo
# exemplo: node + terraform (uma por linha)
```

## Sugerir validação (sem executar)

```bash
./scripts/detect-validation-commands.sh ~/work/foo
```

## Sincronizar tooling para um projeto

```bash
# preview
./scripts/sync-project-tooling.sh --project ~/work/foo --tool all --auto-detect --dry-run

# aplicar
./scripts/sync-project-tooling.sh --project ~/work/foo --tool all --auto-detect

# stacks explícitas
./scripts/sync-project-tooling.sh --project ~/work/foo --tool codex --stack scala
```

Arquivos gerados (cópia, não symlink):

- `.claude/CLAUDE.md`, `.claude/hooks/`
- `.cursor/rules/`, `.cursor/hooks/`
- `AGENTS.md`, `AI_WORKFLOW.md`

Backups: `*.backup-YYYYMMDDHHMMSS` antes de sobrescrever.

## O que versionar

- skills, commands, agents, hooks, rules
- templates e scripts
- docs e prompts genéricos
- stack packs em `stacks/`
- `settings.template.json`, `.env.example`

## O que nunca versionar

- tokens, chaves MCP, credenciais
- `settings.json` real, `.env` real
- paths absolutos pessoais (`/Users/...`)
- emails, nomes de clientes sensíveis
- arquivos com secrets (ver `.gitignore`)

## Adicionar uma skill

1. Crie em `claude/skills/<nome>/SKILL.md` (e espelhe em `cursor/skills/` se usar Cursor).
2. Rode `./scripts/check-ai-tooling-parity.sh` para comparar nomes.
3. `./install.sh` atualiza symlinks globais.

Skills específicas de **projeto** ficam no repo do projeto, não aqui.

## Adicionar um stack pack

Veja [docs/stacks.md](docs/stacks.md).

## Configurar em outro computador

1. Clone o repo no mesmo path relativo (ex.: `~/dev-ai-tooling`).
2. `./install.sh`
3. Copie/localize secrets fora do git (`.env`, MCP tokens).
4. `./doctor.sh`

## Projetos com stacks diferentes

Use `--auto-detect` ou `--stack a,b`. Templates base são agnósticos; stack packs adicionam seções parciais.

## Troubleshooting

| Problema | Ação |
|----------|------|
| Symlink aponta para path antigo | `./install.sh` ou `./update.sh` |
| Doctor WARN em hook | `chmod +x claude/hooks/*.sh cursor/hooks/*.sh` |
| Múltiplos lockfiles Node | Escolha o PM do projeto; não assuma automaticamente |
| sync sobrescreveu arquivo | Restaure de `*.backup-*` |
| Paridade Claude/Cursor | `./scripts/check-ai-tooling-parity.sh` |

## Documentação

- [usage-matrix.md](docs/usage-matrix.md)
- [multi-repo-pattern.md](docs/multi-repo-pattern.md)
- [hooks.md](docs/hooks.md)
- [stacks.md](docs/stacks.md)

## Estrutura

```
core/          # prompts e rules agnósticos
claude/        # setup global Claude
cursor/        # setup global Cursor
codex/         # setup global Codex
stacks/        # overlays por stack
scripts/       # instalação, detecção, sync, doctor
templates/     # templates de projeto
docs/          # documentação
```

## Licença

Uso pessoal — ajuste conforme necessário.
