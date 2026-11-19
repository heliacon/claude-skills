# Craft

40 skills and 17 agents for Claude Code that cover building a software product end to end: planning,
engineering, testing, security, operations, design, product and growth.

Each skill is written for a strong practitioner. It leaves out what Claude already does well and keeps what
it tends to get wrong: the gotchas, the checks that prove work is done and the rationalisations to refuse.

## Install

```
/plugin marketplace add heliacon/claude-skills
/plugin install craft@heliacon
```

Skills load by themselves when a request matches their description. You can also run one directly, for
example `/craft:milestone-gate` or `/craft:product-exploration an app that ...`. Agents are available as
`craft:<agent>`, for example `@agent-craft:security`.

The skills use only the portable Agent Skills frontmatter (`name`, `description`, `license`), so each folder
under `skills/` can also be uploaded to claude.ai on its own.

## Skills

| Area | Skills |
|---|---|
| Plan and product | `workflow` · `product-exploration` · `product-management` · `requirements` · `project-management` · `project-frameworks` · `docs` |
| Engineering | `code-quality` · `api-design` · `backend-patterns` · `system-design` · `database` · `logging` · `frontend` · `mobile` · `swift` · `rust` · `go` · `git` |
| Testing and quality | `tdd` · `testing-strategy` · `quality-assurance` · `uat` · `milestone-gate` |
| Security and operations | `security` · `security-audit` · `ci-cd` · `devops` · `infrastructure` |
| Design | `ux-research` · `information-architecture` · `visual-design` · `designer` · `artist` · `copywriter` |
| Growth and data | `marketing` · `seo-aeo-geo` · `data-analysis` · `financial-modelling` · `game-design` |

Skills that sit close together name each other in their descriptions, so the right one loads. For example
`tdd` is for writing a test first, `testing-strategy` for whether a suite can fail, `quality-assurance` for
the release process and `uat` for business sign-off.

## Agents

| Agent | Role | Preloads |
|---|---|---|
| `orchestrator` | Classifies a task, picks agents and sequences phases | `project-frameworks` |
| `pm` | Requirements, scope and roadmap | `requirements` · `product-management` · `project-management` |
| `analyst` | Data analysis and reporting | `data-analysis` · `requirements` |
| `architect` | System design and decision records | `system-design` · `security` · `workflow` |
| `backend` | Server-side implementation | `backend-patterns` · `api-design` · `tdd` · `security` |
| `frontend` | Client-side implementation | `frontend` · `tdd` |
| `database` | Schema, migrations and queries | `database` · `security` |
| `devops` | Pipelines, deploys and observability | `devops` · `ci-cd` · `logging` |
| `sysadmin` | Hosts, networks and hardening | `infrastructure` · `security` |
| `security` | Read-only security review | `security-audit` · `security` |
| `tester` | Read-only validation after each phase | `testing-strategy` · `tdd` · `quality-assurance` |
| `ux` | Research and information architecture | `ux-research` · `information-architecture` |
| `designer` | Visual system and page design | `visual-design` · `designer` |
| `marketing` | Positioning and go to market | `marketing` |
| `seo` | Search and answer-engine audits (read-only) | `seo-aeo-geo` · `data-analysis` |
| `finance` | Models, unit economics and pricing | `financial-modelling` |
| `teacher` | Retrospectives and the lessons loop | `workflow` |

The `orchestrator` can only return a plan when it runs as a subagent, because subagents cannot start other
agents. To have it run the phases, start a session with it: `claude --agent craft:orchestrator`.

## Conventions the skills assume

Some skills keep working notes in the repository, so they survive between sessions: a plan in
`tasks/todo.md`, lessons in `tasks/lessons.md` and a handoff in `HANDOFF.md`. Rename them in your own copy if
your project uses something else.

## Evals

`evals/` holds trigger cases: each checks that a request fires the right skill and not its nearest sibling,
plus a control that fires none. Run them with:

```
claude plugin eval ./ --tag trigger
```

## Contributing

Issues and pull requests are welcome. Keep a skill's `SKILL.md` under 500 lines with the most important rules
first, move depth to `references/` and run `scripts/check.sh` before opening a pull request.

## Licence

MIT. See `LICENSE`. The techniques that informed these skills are credited in `ACKNOWLEDGEMENTS.md`.
