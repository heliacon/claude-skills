---
name: devops
description: Use when deploying or releasing a service, choosing canary, blue/green or rolling rollout, planning a rollback, writing a Dockerfile, adding health checks, monitoring, alerts or SLOs, rotating secrets, handling an incident or writing a postmortem. Not for pipeline YAML (use `ci-cd`) or provisioning servers and cloud resources (use `infrastructure`).
license: MIT
---

# DevOps (ship and run)

This skill covers getting a built artefact to users safely and keeping it healthy: deployment, rollout,
rollback, containers, observability, SLOs, secret rotation and incidents. The pipeline that produces the
artefact is the `ci-cd` skill. The servers, networks and cloud resources it runs on are the
`infrastructure` skill.

## The rules that matter most

1. **No deploy without a rehearsed way back.** Name the rollback before you ship, and make sure it has
   been run at least once in staging. "Ship another fix" is not a rollback.
2. **A deploy is done when the new build is proven live and healthy.** Not when the command exits.
3. **Wait for the new build, not for a heartbeat.** A loop that waits for HTTP 200 exits at once against
   the OLD build, which was already serving 200. Poll for something only the new build emits: a version
   string, a build id in a header, a new route. If a post-deploy check disagrees with the source you just
   verified, suspect the probe (stale cache, edge node still on the old version) before the deploy:
   re-fetch with a cache-buster and compare.
4. **Compare against a baseline captured before the deploy.** Error rate and latency "look fine" means
   nothing without the numbers from before.
5. **Schema changes outlive rollbacks.** Rolling back the code does not roll back a migration. Every
   migration must work with both the old and the new release (see "Migrations and rollback").
6. **Alert on symptoms users feel, and make every alert actionable.** A page nobody acts on trains people
   to ignore pages.

## Deployment

**Order:** artefact from CI, deploy to staging automatically on merge, smoke test staging, deploy to
production on a tag or manual approval, smoke test production, watch the health gates.

**Default strategy for production: canary.** Shift traffic in steps (for example 1%, 10%, 50%, 100%)
with automated promotion on error rate and latency. Use rolling updates when canary routing is not
available. Choose differently only for a reason:

| Strategy | Use when | Way back |
|---|---|---|
| Canary | Production with enough traffic to judge a slice | Shift traffic back |
| Rolling | Stateless service, no canary routing | Redeploy the previous image |
| Blue/green | Need an instant cutover, can afford double capacity | Flip the load balancer back |
| Feature flag | Code ships dark, release is a config change | Turn the flag off |
| Recreate | Development or staging, downtime acceptable | Redeploy |

**Health gates.** Before calling a deploy complete, for 5 to 10 minutes after each step:
- The new build is serving (version discriminator, rule 3).
- Error rate no higher than the pre-deploy baseline plus 0.5 to 1 percentage point.
- p99 latency no more than 20% above baseline.
- No crash loops, OOM kills or restart storms.

Roll back automatically if a gate fails. Deploy when people are around to respond, never into a weekend
with no one watching.

## Migrations and rollback

Use expand and contract:
1. **Expand:** add new columns or tables in a release that still works without them. Make new columns
   nullable or defaulted.
2. **Migrate:** deploy code that writes both shapes and reads the new one, then backfill.
3. **Contract:** remove the old shape in a later release, once no running version reads it.

Never rename or drop a column in the same release that stops using it. If you do, rolling back the code
leaves the old code facing a schema it does not understand. The `database` skill covers migration
mechanics.

## Containers

```dockerfile
# Pin the digest, not only the tag
FROM python:3.12-slim@sha256:<digest>
RUN groupadd -r app && useradd -r -g app app
WORKDIR /app
# Dependencies first, for layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=app:app . .
USER app
EXPOSE 8080
# The module exits non-zero when unhealthy
HEALTHCHECK --interval=30s --timeout=3s CMD ["python", "-m", "app.healthcheck"]
CMD ["python", "app.py"]
```

A Dockerfile `#` starts a comment only at the beginning of a line. A trailing comment after an
instruction is passed to it as arguments and breaks the build.

- Run as a non-root user. Use a slim or distroless base. Multi-stage builds for compiled languages, so
  compilers do not ship.
- No secrets in the image or in build arguments. They persist in layers. Inject at runtime.
- The health check must use a tool that exists in the image. Slim images often have no `curl`, so a
  `curl -f` health check reports a healthy container as unhealthy for ever. Kubernetes ignores the
  Dockerfile `HEALTHCHECK` and uses its own probes, so define those too.
- Add a `.dockerignore` that excludes `.git`, `.env`, local databases and `node_modules`.
- Separate liveness (process is alive) from readiness (can serve traffic: dependencies reachable,
  warm-up done). Route traffic only to ready instances.

## Observability

- **Metrics:** the four golden signals per service: latency, traffic, errors, saturation.
- **Logs:** structured JSON with timestamp (ISO 8601), level, service, trace id and message. Never
  personal data or credentials. The `logging` skill covers detail.
- **Traces:** OpenTelemetry at service boundaries. Sample a fraction of normal requests and keep all
  errors.
- **Alerts:** on symptoms (error rate, latency, saturation that predicts an outage), not causes such as
  CPU percentage. Each alert links to its runbook.

## SLOs and error budgets

Define SLOs before a service takes production traffic. Read `references/slos.md` for the definitions,
the error-budget policy and burn-rate alert rules. The common mistake: a 14.4x burn rate on a 30-day
budget empties it in about two days, not two hours. Page on fast burn over a short window, ticket on slow
burn over a long one.

## Incidents

Read `references/incidents.md` when an incident is open, when writing a runbook or when writing a
postmortem. It holds severity levels, the triage steps, the status update format and the postmortem
template. Every production service has a runbook before go-live.

## Secrets at runtime

Secrets come from a secrets manager at runtime (Vault, a cloud secret manager or the orchestrator's
secret store backed by one). Never in source, images, CI YAML or plaintext config. Read
`references/secret-rotation.md` when rotating a secret, on a schedule or after a suspected compromise.

## GitOps

When the environment is managed declaratively, Git holds the desired state and an agent in the cluster
(Argo CD or FluxCD) pulls and applies it. No `kubectl apply` from a laptop. All changes arrive by pull
request, hotfixes included. Drift between live state and Git raises an alert.

## Delivery metrics

Track the four DORA keys from deploy and incident records: deployment frequency, lead time from commit to
production, change failure rate (deploys that needed a rollback or fix), and time to restore after a
failed deploy. Compare against the bands in the current DORA report rather than fixed numbers, and treat
a sustained low score as a system problem, not a one-off.

## Gotchas

- **Liveness probe as a deploy check.** Proves something is up, not that it is the new build.
- **Rollback with a migration applied.** The old code meets the new schema. Use expand and contract.
- **Canary never promotes.** A 1% slice of low traffic produces too few requests to judge. Set a minimum
  request count per step, or use a larger slice or a longer window.
- **Canary compared with itself.** Compare the canary against the stable fleet over the same window, not
  against yesterday.
- **Staging that is not like production.** Different config, data shape or scale, so staging passes and
  production breaks. Keep the difference listed and small.
- **Alert fatigue.** Too many low-value alerts and the real page gets ignored. Delete alerts nobody acts
  on.
- **Logs with no correlation id.** A distributed failure cannot be traced without one on every line.
- **Snowflake pipelines and hand-patched hosts.** If it cannot be rebuilt from code, it will drift.

## Verification

A deploy is complete when you can show: the version discriminator from production; health-gate numbers
before and after; zero crash restarts since rollout; and, for a new service, a runbook link, an SLO
document and an alert that has been fired once in a test.
