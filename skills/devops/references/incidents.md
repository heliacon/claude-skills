# Incidents, runbooks and postmortems

Read when an incident is open, when writing a service runbook or when writing a postmortem.

## Contents
- Severity levels
- During an incident: triage
- Status updates
- Runbook template
- Postmortem template

## Severity levels

| Level | Meaning | Respond within | Involve |
|---|---|---|---|
| SEV1 | Full outage, data loss or a security breach | 15 minutes | Incident lead, engineering lead, leadership |
| SEV2 | Major feature down or degraded for many users | 1 hour | Incident lead, owning team |
| SEV3 | Minor feature broken, workaround exists | Next working day | Owning team |

When unsure, pick the higher level and downgrade later. Upgrading late costs more than downgrading.

## During an incident: triage

1. **Declare it.** Open a channel or document, name an incident lead, start a timeline with times.
2. **Stabilise before you diagnose.** If a deploy went out recently, roll it back first. Restoring
   service beats understanding it.
3. **Assess impact.** Who is affected, how many, since when, is data at risk.
4. **Diagnose from evidence.** Dashboards, recent changes (deploys, config, flags, dependencies), logs
   around the start time. Write each hypothesis and its test in the timeline.
5. **Mitigate, then verify** against the same signal that showed the problem.
6. **Close** only after the signal has been normal for an agreed period, then schedule the postmortem.

One person changes production at a time, and says what they are about to change before doing it.

## Status updates

Post on a fixed rhythm (every 30 minutes for SEV1 and SEV2), even when nothing changed:

```
[HH:MM UTC] [Service]: [what is broken, as users see it]
Impact: [who and how many] | Status: investigating / mitigating / monitoring / resolved
Next update: [HH:MM UTC]
```

Separate the internal channel (hypotheses, commands) from customer-facing status (impact and next
update only, no speculation about cause).

## Runbook template

Write before go-live, and test it: have someone who did not write it follow it in staging. A runbook
that only works for its author fails in a real incident.

```markdown
# Runbook: [service]

## Overview
- Purpose: [one sentence]
- Owner and on-call: [team, rotation]
- Dashboards: [links]  | Logs: [link]  | Repo: [link]
- Dependencies: [what it calls, what calls it]

## Failure scenarios
### [Scenario, for example "database connection pool exhausted"]
- Symptoms: [alerts that fire, what users see]
- Confirm: [exact commands or queries]
- Mitigate: [steps to restore service now]
- Fix: [root-cause resolution]
- Undo: [how to revert the mitigation if it makes things worse]

## Routine operations
[Restart, scale, rotate a secret, restore from backup: exact steps]
```

## Postmortem template

Within two working days of a SEV1 or SEV2, write `docs/postmortems/YYYY-MM-DD-title.md`. Blameless:
describe what the system allowed, not who slipped.

```markdown
# [Title]

- Date, duration, severity:
- Impact: [users, requests, revenue, data, with numbers]

## Timeline (UTC)
[Detection, each decision, mitigation, resolution. Include how it was detected.]

## Root cause
[The technical cause, and why the system allowed it.]

## Contributing factors
[Monitoring gaps, unclear runbooks, risky defaults.]

## What went well / what went badly

## Actions
| Action | Owner | Due | Ticket |
[Each action prevents recurrence, improves detection or shortens recovery. Add a check that would have
caught this.]
```

Track the actions to completion. A postmortem whose actions are never done will be written again.
