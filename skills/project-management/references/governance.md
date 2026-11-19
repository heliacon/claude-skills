# Status, cadence and governance

Read this when writing a status update, setting a stakeholder cadence, choosing a delivery model, defining "done" for a phase or reading delivery health.

## Contents

- RAG status
- Stakeholder cadence
- Delivery model
- Definition of Done
- DORA as a health signal
- Phase hand-off checklist

## RAG status

| Status | Means | Must contain |
|---|---|---|
| Green | On track, no help needed | A one-line confirmation. No ask. |
| Amber | At risk, recoverable | The risk, the recovery plan, any help needed |
| Red | Will miss without intervention | The miss, the ask, options with their trade-offs |

- RAG is on the forecast. Effort and hours are not status.
- A green that goes red is flagged the same day, out of band. Never hold a red for the scheduled slot.
- Give bad news early and specifically: which date, by how much, why and what would recover it.

## Stakeholder cadence

| Stakeholder | Cares about | Cadence |
|---|---|---|
| Sponsor or executive | Dates, cost, top risks, red items | Scheduled summary, plus immediately on red |
| Delivery team | Tasks, blockers, dependencies | Every session or stand-up |
| Dependent teams | Interface contracts, needed-by dates | At hand-off and whenever a date moves |
| End users and affected parties | What changes for them, and when | At milestones and before launch |

The rule under all of it: no surprises. Nobody should first hear of a slip or a scope change in the meeting where it lands.

## Delivery model

Choose by risk profile, not habit.

| | Iterative | Stage-gate |
|---|---|---|
| Fits when | Requirements will change, value ships in pieces, feedback is fast | Scope is fixed or regulated, one irreversible delivery, a hard external gate |
| Progress signal | Working software each iteration | Gate criteria met, artefacts approved |
| Risk exposure | Little and often | Concentrated at the end |

Most real projects are a hybrid: iterative build inside fixed external gates. Say which parts are which, so nobody expects iterative flexibility on a regulated deadline.

## Definition of Done

A phase or story is done only when all of these hold. "Done except tests" is in progress.

**Code**
- [ ] All acceptance criteria verified by running them, not assumed
- [ ] An independent test pass approved it (for example the `tester` agent)
- [ ] No regressions in previously passing tests
- [ ] Build, lint and type check pass with zero errors
- [ ] No TODO, FIXME or commented-out code in the diff

**Review and quality**
- [ ] Reviewed and approved by someone other than the author
- [ ] No function above the project's complexity limit (15 is a common ceiling)
- [ ] Security checks passed: input validation, authorisation, no secrets in logs

**Documentation and observability**
- [ ] New environment variables in `.env.example`
- [ ] Structured logging at decision points and failure paths
- [ ] API changes reflected in the OpenAPI spec or equivalent

**Deployment readiness**
- [ ] Migrations tested up and down
- [ ] Works in a staging environment
- [ ] Performance target not regressed (p99 where measurable)

## DORA as a health signal

| Signal | Poor score means | Action |
|---|---|---|
| Lead time over a week from commit to production | Pipeline bottleneck or large batches | Smaller shippable units |
| Deploys less than weekly | Fear of deploying, manual gates | Automate deploys, use feature flags |
| Change failure rate above 15% | Thin testing, oversized changes | Smaller changes, stronger test gates |
| Time to restore over a day | Poor observability, no runbooks | Alerting, incident runbooks |

These predict incidents before they happen. Track the trend, not one reading.

## Phase hand-off checklist

- [ ] All acceptance criteria met and verified
- [ ] Independent test pass approved
- [ ] Technical debt found during the phase recorded where the next owner will see it
- [ ] Next phase owner briefed on the current state
- [ ] Blockers for the next phase resolved or mitigated
