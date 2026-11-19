# Framework: CLI tool

For commands run in a terminal. Also the closest fit for a library (drop the CLI UX standards).

## Agent roster

| Agent | Phases | Role |
|---|---|---|
| `pm` | 1 | Commands, flags and user journeys |
| `architect` | 1-2 | Command structure, config, plugin model |
| `backend` | 2-3 | Implementation |
| `security` | 3 | Credentials, secrets, permissions |
| `devops` | 3-4 | Cross-platform builds and publishing |
| `tester` | every phase | Gate |

## Phases

### Phase 1: Design
Goal: command interface and user journeys defined.
Agents: `pm` > `architect`
Skills: requirements, system-design
Decide: command hierarchy (`tool command subcommand --flags`); config sources and their precedence
(flags over environment over config file over defaults); output formats; authentication if any;
plugin system or not.
Done when: the help text for every command is written before any code; journeys reviewed.

### Phase 2: Core implementation
Goal: happy-path commands work and are tested.
Agents: `backend` > `tester`
Skills: code-quality, tdd, logging
Done when: core commands pass tests including exit codes and stdout/stderr separation.

### Phase 3: Complete, secure and polished
Goal: all commands complete; useful errors; security reviewed.
Agents: `backend` > `security` > `tester`
Skills: security, logging
Done when: every error message says what went wrong and how to fix it; security checklist below
passes.

### Phase 4: Distribution
Goal: cross-platform binaries or packages published.
Agents: `devops` > `tester`
Skills: devops, ci-cd
Done when: install works from the published package on each supported OS, tested on a clean
machine.

## Non-negotiables

**Behaviour**
- Exit codes: 0 success, 1 general error, 2 misuse (bad flags or arguments).
- Results to stdout; errors, warnings and progress to stderr, so output can be piped.
- `--json` on every command that produces output; `--quiet` to suppress non-essential output.
- `--help` on every command and subcommand; `--version` at the top level.
- Honour `NO_COLOR`, and drop colour when stdout is not a terminal.
- Progress shown for operations over about a second.
- Destructive operations confirm, with `--yes` or `--force` to skip in scripts.

**Security**
- Never accept secrets as flags: they land in shell history and process lists. Use environment
  variables, a prompt or a credentials file.
- Never print credentials in logs or errors.
- Config files holding secrets are created with 0600 permissions; warn if they are readable by others.

## Skill loading

| Phase | Skills |
|---|---|
| 1 | requirements, system-design |
| 2 | code-quality, tdd, logging |
| 3 | security, logging |
| 4 | devops, ci-cd |
