# Framework: finance tool

For software that calculates, moves or reports money: budgeting, accounting, investment and trading
tools, financial dashboards.

## Agent roster

| Agent | Phases | Role |
|---|---|---|
| `pm` | 1 | Use cases, user types, compliance needs |
| `finance` | 1-3 | Calculation methodology and model design |
| `analyst` | 1-2 | Data sources and reporting needs |
| `architect` | 2 | System design with compliance built in |
| `database` | 2 | Schema with audit trail and data classification |
| `security` | 2-5 | Encryption, access control, reviews |
| `backend` | 3-4 | Calculation engine and API |
| `frontend` | 4 | Reports and dashboards |
| `devops` | 5 | Secure deployment, backups, compliance logging |
| `tester` | every phase | Gate |

## Phases

### Phase 1: Requirements and model design
Goal: financial requirements defined; calculation methodology agreed and written down.
Agents: `pm` > `finance` + `analyst`
Skills: requirements, financial-modelling
Decide: data sources (market data vendor, internal systems); calculation methodology, documented
so an auditor can follow it; which jurisdictions and regulations apply; where data may be stored.
If the tool trades or makes investment decisions, write the strategy specification here, with its
risk limits.
Done when: methodology document reviewed by `finance`; worked examples with expected outputs exist
for every calculation.

### Phase 2: Architecture with compliance
Goal: designed to meet regulatory and security needs from the start.
Agents: `architect` + `database` + `security`
Skills: system-design, database, security, security-audit
Cover: an audit trail that traces every calculation to its inputs; retention periods (often seven
years for financial records; check the jurisdiction); need-to-know access control; encryption at
rest and in transit.
Done when: data classification tags on every financial field; retention and access rules recorded.

### Phase 3: Calculation engine
Goal: core calculations implemented, tested and auditable.
Agents: `backend`, with `finance` reviewing
Skills: code-quality, tdd, testing-strategy, financial-modelling, logging
Done when: every calculation passes its worked examples and property-based tests (for example,
totals equal the sum of parts; currency conversion round-trips within tolerance); `finance` signs
off the outputs.

### Phase 4: Reporting UI and review
Goal: reports and dashboards complete; security review passed.
Agents: `frontend` + `security` > `tester`
Skills: frontend, security-audit
UI rules: every number shows currency, precision and period; negative values are distinguished by
sign or brackets as well as colour; every report exports to CSV and PDF.
Done when: reports reconcile to the engine's outputs; no open critical or high findings.

### Phase 5: Secure deploy
Goal: deployed with a hardened posture for financial data.
Agents: `devops` > `security` > `tester`
Skills: devops, security
Done when: encrypted backups restored in a test; access logs live; rate limits on every financial
endpoint.

## Non-negotiables

- **Decimal arithmetic** for money. Never binary floating point: 0.1 + 0.2 is not 0.3.
- **Immutable audit log** of every financial transaction and calculation.
- **Reconciliation report** for anything that moves or calculates money.
- **Data classification** at schema design, not retrofitted.
- **Sensitive material out of version control.** Real financial data, credentials and notes that
  contain them are ignored by git from the first commit.

## Skill loading

| Phase | Skills |
|---|---|
| 1 | requirements, financial-modelling |
| 2 | system-design, database, security-audit |
| 3 | code-quality, tdd, testing-strategy, financial-modelling, logging |
| 4 | frontend, security-audit |
| 5 | devops, security |
