# SLOs, error budgets and burn-rate alerts

Read when defining SLOs for a service, writing SLO alerts or deciding whether to slow feature work.

## Terms (keep them distinct)

- **SLI:** the measurement. "Fraction of requests that returned non-5xx within 500ms."
- **SLO:** the internal target for an SLI over a window. "99.9% over 30 days."
- **SLA:** a contract with a consequence. Always looser than the SLO.
- **Error budget:** `(1 - SLO) x window`. 99.9% over 30 days is 43.2 minutes of full outage, or the
  equivalent in partial failure. 99% is 7.2 hours.

## SLO document

Write to `docs/slos.md` before go-live:

```markdown
## SLOs: [service]

| SLI | Good event | Target | Window |
|---|---|---|---|
| Availability | Request returns non-5xx | 99.9% | 30 days, rolling |
| Latency | Request completes under 500ms | 99% | 30 days, rolling |

Budget: 43.2 min/30d (availability), 7.2 h/30d (latency).
Owner: [team]. Review: monthly.
```

Measure at the edge closest to the user (load balancer or client) rather than inside the service, which
cannot see its own outages.

## Error-budget policy

| Budget consumed in window | Action |
|---|---|
| Under 50% | Normal feature work. |
| 50 to 75% | Reliability work runs alongside features. |
| 75 to 100% | Feature freeze. Reliability and fixes only. |
| Exhausted | Review the causes before feature work resumes. |

Agree this policy with whoever sets priorities before it is needed, not during the freeze.

## Burn-rate alerts

Burn rate is how fast the budget is being spent relative to plan. A burn rate of 1 empties the budget
exactly at the end of the window. A burn rate of N empties a 30-day budget in 30/N days:

| Burn rate | Budget gone in (30-day window) | Budget spent in 1 hour |
|---|---|---|
| 1 | 30 days | 0.14% |
| 6 | 5 days | 0.8% |
| 14.4 | about 2 days | 2% |

Default alert rules for a 30-day window (from the Google SRE workbook's multi-window approach):

| Severity | Long window | Short window | Burn rate | Budget spent at trigger |
|---|---|---|---|---|
| Page | 1 hour | 5 minutes | 14.4 | 2% |
| Page | 6 hours | 30 minutes | 6 | 5% |
| Ticket | 3 days | 6 hours | 1 | 10% |

Both windows must exceed the rate. The long window gives significance. The short window makes the alert
stop soon after the problem stops.

```yaml
# Page: 99.9% availability SLO, fast burn. Threshold = 14.4 x 0.001 = 0.0144.
- alert: ErrorBudgetFastBurn
  expr: |
    (
      sum(rate(http_requests_total{status=~"5.."}[1h]))
        / sum(rate(http_requests_total[1h])) > 0.0144
    )
    and
    (
      sum(rate(http_requests_total{status=~"5.."}[5m]))
        / sum(rate(http_requests_total[5m])) > 0.0144
    )
  labels:
    severity: page
  annotations:
    summary: "Spending error budget at 14.4x: 2% gone in the last hour, a full budget lasts about 2 days at this rate"
    runbook_url: "<link>"
```

Check the arithmetic in any alert annotation that states a time to exhaustion. It is easy to be off by a
factor of 24.

Low-traffic services need care: at a few requests per minute one failure is a large ratio. Add a minimum
request count to the expression, or alert on synthetic probes instead.
