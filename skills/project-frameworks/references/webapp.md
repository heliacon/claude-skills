# Framework: web application

For products used in a browser.

## Agent roster

| Agent | Phases | Role |
|---|---|---|
| `pm` | 1 | Requirements and acceptance criteria |
| `analyst` | 1 (optional) | Data and reporting needs |
| `ux` | 1-2 | User flows and information architecture |
| `architect` | 2 | System design before implementation |
| `designer` | 2 | Design system and component specs |
| `database` | 2 | Schema, in parallel with the architect |
| `backend` | 3-4 | API and business logic |
| `frontend` | 3-4 | UI, in parallel with backend |
| `security` | 2, 4 | Threat model early, review before launch |
| `devops` | 4-5 | CI/CD and deployment |
| `tester` | every phase | Gate |

## Phases

### Phase 1: Discovery
Goal: requirements and user flows defined and approved.
Agents: `pm` > `analyst` (optional) > `ux`
Skills: requirements, project-management, ux-research, information-architecture
Done when: user stories have acceptance criteria; flows approved; technical requirements written.

### Phase 2: Architecture and design
Goal: technical architecture and visual language settled.
Agents: `architect` + `designer` + `database`, then `security` (threat model)
Skills: system-design, visual-design, database, security-audit
Done when: decision records written; schema drafted; design tokens defined; threat model written;
tester approves.

### Phase 3: Core implementation
Goal: the critical user journeys work end to end.
Agents: `backend` + `frontend`, one vertical slice at a time
Skills: code-quality, tdd, api-design, logging, frontend
Done when: critical stories implemented with passing tests; tester approves.

### Phase 4: Complete and secure
Goal: all stories complete; security review passed.
Agents: `backend` + `frontend` (remaining stories) > `security` > `tester`
Skills: security, security-audit
Done when: all acceptance criteria met; security report has no open critical or high findings;
tester approves.

### Phase 5: Deploy
Goal: running in production with monitoring.
Agents: `devops` > `tester` (smoke tests)
Skills: devops, ci-cd
Done when: deployed; smoke tests green against production; monitoring and alerts live; rollback
tested.

## Non-negotiables

- Auth from an established provider or framework before anything custom.
- Accessibility checked in phase 3, not retrofitted in phase 4.
- Every environment built by the same pipeline; no hand-deployed production.

## Skill loading

| Phase | Skills |
|---|---|
| 1 | requirements, project-management, ux-research |
| 2 | system-design, visual-design, database, security-audit |
| 3 | code-quality, tdd, api-design, logging, frontend |
| 4 | security, security-audit |
| 5 | devops, ci-cd |

## Stack defaults (not prescriptive)

Choose what the team knows. PostgreSQL is a sound default database. Start hosting simple (a managed
platform) and move only when a measured need appears.
