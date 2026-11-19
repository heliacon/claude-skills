# Performance baseline template

Read this when an external-facing endpoint or job has no recorded performance target. Add an entry to
`docs/performance-targets.md` (or the project's equivalent). A missing entry is an advisory note, not a
blocker, unless the area is Critical tier.

```markdown
## [Endpoint or feature]

| Metric | Target | Measured (date) |
|---|---|---|
| p50 latency | < 100ms | |
| p99 latency | < 500ms | |
| Error rate (steady state) | < 0.1% | |
| Throughput (peak) | X req/s | |

Measured with: [k6, Locust, wrk or similar], against [environment], with [data volume].
Last measured: [date]
```

Rules:
- Measure useful output, not work done. For example, 100 requests a second at 5% success delivers less
  than 20 a second at 50%.
- State the environment and data volume. A number from an empty database is not a baseline.
- Record p99 as well as p50. A median hides the tail that users complain about.
