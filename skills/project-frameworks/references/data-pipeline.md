# Framework: data pipeline

For ETL and ELT pipelines, warehouses and analytics infrastructure.

## Agent roster

| Agent | Phases | Role |
|---|---|---|
| `analyst` | 1, 4 | Sources, metrics and reporting needs; metric definitions |
| `pm` | 1 | Stakeholder requirements and SLAs |
| `architect` | 2 | Pipeline architecture, warehouse, orchestration |
| `database` | 2, 5 | Source analysis, warehouse schema, transformations |
| `backend` | 3-4 | Ingestion and transformation code |
| `security` | 5 | PII handling and access control |
| `devops` | 6 | Orchestration deployment and monitoring |
| `tester` | every phase | Gate |

## Phases

### Phase 1: Discovery and requirements
Goal: sources understood; reporting needs defined; SLAs agreed.
Agents: `analyst` > `pm`
Skills: requirements, database, data-analysis
Questions: which decisions should this pipeline enable? Which sources (databases, APIs, files,
streams)? What freshness (real time, hourly, daily)? What volume (rows and GB per day)? Who
consumes the output (analysts, dashboards, other systems)?
Done when: SLAs and consumers written down; each metric has a draft definition.

### Phase 2: Architecture and schema
Goal: architecture decided; warehouse schema designed; orchestrator chosen.
Agents: `architect` + `database`
Skills: system-design, database
Decide: ELT by default with a modern warehouse; an orchestrator; a warehouse sized for volume and
cost; layered models (raw, cleaned, business-ready, often called bronze, silver and gold). Classify
PII columns now.
Done when: decision records written; PII classification on every source column.

### Phase 3: Ingestion (raw layer)
Goal: every source lands in the raw layer reliably.
Agents: `backend`
Skills: code-quality, logging, database
Requirements: idempotent loads (safe to re-run); schema evolution handled (a new column does not
break the run); alerts on failure; dead-letter storage for rejected records; row counts logged at
each stage.
Done when: a re-run of the same window produces no duplicates (tested).

### Phase 4: Transformations
Goal: clean, tested, documented datasets ready for consumers.
Agents: `backend` + `analyst` (metric definitions)
Skills: code-quality, tdd, database, data-analysis
Standards: every model has a description, column docs and at least not-null and unique tests on its
key; metric definitions live in version-controlled code (a semantic layer or SQL), not
spreadsheets; data quality tests run on every execution.
Done when: each business-ready metric reconciles to an independent source on a sample period.

### Phase 5: PII, security and access
Goal: PII handled and access controlled.
Agents: `security` + `database`
Skills: security, security-audit
Cover: PII masked or hashed by the cleaned layer; role-based access (analysts, ML, downstream
systems); lineage good enough to find and erase one person's data on request.
Done when: an erasure request is traced and executed in a test.

### Phase 6: Orchestration and monitoring
Goal: runs on schedule with alerting.
Agents: `devops` > `tester`
Skills: devops, logging
Monitoring: row-count anomalies (for example alert when a load is under 50% or over 200% of the
seven-day average); freshness alerts against the SLA; warehouse cost tracking.
Done when: each alert has fired once in a test and reached a person.

## Non-negotiables

- **Idempotency**: every step is safe to re-run.
- **Lineage**: every business-ready metric traces to its raw source.
- **PII classification** at schema design, not retrofitted.
- **Tests in CI**: transformation tests run on every change.

## Skill loading

| Phase | Skills |
|---|---|
| 1 | requirements, database, data-analysis |
| 2 | system-design, database |
| 3-4 | code-quality, tdd, logging, database |
| 5 | security, security-audit |
| 6 | devops, logging |
