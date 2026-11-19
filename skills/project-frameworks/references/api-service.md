# Framework: API service

For services other software calls: standalone APIs and microservices with no UI of their own.

## Agent roster

| Agent | Phases | Role |
|---|---|---|
| `pm` + `analyst` | 1 | API consumers and use cases |
| `architect` | 1-2 | Service design, contract, data model |
| `database` | 2 | Schema and migration strategy |
| `backend` | 2-4 | Implementation |
| `security` | 2, 4 | Auth design, vulnerability review |
| `devops` | 5 | CI/CD, containers, deployment |
| `tester` | every phase | Gate |

## Phases

### Phase 1: API design
Goal: contract defined; consumers agreed; data model sketched.
Agents: `pm` + `analyst` > `architect`
Skills: requirements, system-design, api-design
Outputs: draft OpenAPI spec; auth strategy (API key, OAuth 2, JWT or mTLS); versioning strategy;
rate limits and quotas; a standard error schema.
Done when: at least one real consumer has reviewed the contract.

### Phase 2: Schema and security baseline
Goal: schema final; auth implemented; secrets managed.
Agents: `database` + `security` > `backend` (scaffolding)
Skills: database, security, security-audit, code-quality
Done when: schema migrated; auth tested end to end, including a rejected request; tester approves.

### Phase 3: Core endpoints
Goal: all endpoints implemented and tested.
Agents: `backend`
Skills: code-quality, tdd, api-design, logging
Standards: input validation, auth check, structured log entry and spec annotation on every
endpoint; cursor pagination on every list endpoint; idempotency keys on mutations that a client may
retry.
Done when: contract tests pass against the spec.

### Phase 4: Observability and security review
Goal: fully instrumented and security approved.
Agents: `security` > `backend` (fixes) > `tester`
Skills: security-audit, logging
Instrumentation: a health endpoint that reports version; metrics; a request ID in every response
header and log line; trace context propagated (OpenTelemetry).
Done when: no open critical or high findings; a request can be followed from its ID through logs
and traces.

### Phase 5: Deploy
Goal: running in production with a pipeline.
Agents: `devops` > `tester`
Skills: devops, ci-cd, infrastructure
Done when: deployed by the pipeline; smoke tests green; alerts live; rollback tested.

## Non-negotiables

- ISO 8601 timestamps in UTC (`2026-03-18T10:00:00Z`).
- One error schema everywhere, for example `{"error": {"code": "...", "message": "...", "details": {}}}`.
- 4xx for client errors. A validation failure is never a 500.
- A changelog; breaking changes need a new version and a deprecation period for the old one.

## Skill loading

| Phase | Skills |
|---|---|
| 1 | requirements, system-design, api-design |
| 2 | database, security, code-quality |
| 3 | code-quality, tdd, api-design, logging |
| 4 | security-audit, logging |
| 5 | devops, ci-cd, infrastructure |
