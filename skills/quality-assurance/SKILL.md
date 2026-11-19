---
name: quality-assurance
description: "Use when planning testing for a phase or release: test plan, risk register, defect triage (severity vs priority), a find-and-fix QA pass, flaky tests, the regression suite, exploratory sessions, exit criteria and go/no-go. Not for writing tests (`tdd`), auditing suite coverage (`testing-strategy`), user acceptance (`uat`) or closing a milestone (`milestone-gate`)."
license: MIT
---

# Quality assurance

QA is the process that **prevents** defects. Testing is the activity that **detects** them. A team that
tests hard at the end and prevents nothing at the start has confused the two. This skill owns the
process around testing: what to test, at what depth, in what order and to what exit bar. Test technique
is in the `tdd` and `testing-strategy` skills; business acceptance is in the `uat` skill.

## The rules that matter most

1. **File before you fix (default).** Put any non-trivial defect in your bug tracker before the fix
   is written, so the diagnosis and the lesson outlive the commit. A trivial fix can be explained in
   the commit message. Adapt the bar to your project's process.
2. **A regression test before the repair.** Each fixed defect gets a test that fails on the old code and
   passes on the new. Prove the first half by reverting the fix and watching it fail.
3. **Effort follows risk.** Spend by likelihood times impact, not evenly.
4. **Write down what is out of scope.** Silence about scope is how gaps ship. An untested area should be
   a decision, not an accident.
5. **Green is a floor.** A suite can pass against a feature that is wired wrong, switched off or
   unreachable. Drive the real flow (call the endpoint, click the button, run the command) before
   calling it done.
6. **Flaky tests are defects.** Quarantine, ticket, fix the cause. Never normalise "just re-run it".

## Shift left

| Stage | Prevention activity |
|---|---|
| Requirements | Ambiguity and testability review; acceptance criteria written before build |
| Design | Risk assessment, failure-mode review, test scope and environments defined |
| Build | TDD, static analysis, code review, contract tests (owned by the builders) |
| Integrate | Regression suite, non-functional checks, exploratory sessions |
| Release | Exit criteria, go/no-go, sign-off |

Quality is owned by the whole team. A QA pass verifies; it does not absolve the builder.

## Risk register

| | Low impact | High impact |
|---|---|---|
| High likelihood | Test normally | Test deepest: every category, exploratory, non-functional |
| Low likelihood | Smoke or skip | Test the failure path explicitly, even if rare |

Impact order: data loss or corruption, security breach, money error, core journey broken, degraded
experience, cosmetic. Rank, then resource from the top.

```
| Area            | Likelihood | Impact   | Risk | Depth                                   |
|-----------------|------------|----------|------|-----------------------------------------|
| Payment capture | Med        | Critical | HIGH | Full matrix + property + exploratory    |
| Footer copy     | Low        | Low      | LOW  | Smoke render                            |
```

Spend on data mutation, money, auth, migrations, anything irreversible, the critical journey and areas
with a history of defects. Do not spend on generated code, framework plumbing or throwaway spikes.

## Test plan

Keep it short, in `tasks/test-plan-<phase>.md`. Read `references/test-plan-template.md` for the
template when starting a plan. It must answer: in scope, out of scope (with reasons), approach per risk
tier, environments, test data (synthetic or masked, never raw production personal data), roles, entry
and exit criteria.

## Diff-aware scope

For a change rather than a whole release, test what changed and what depends on it:

1. List the changed files and functions from the diff.
2. Find their callers (search the codebase; do not guess from names, two paths can share a name and
   behave differently).
3. Re-run the tests for those, plus the smoke suite for critical journeys.
4. Exercise the changed behaviour by hand at its real entry point.

## The find-and-fix loop

When a QA pass is also allowed to fix:

1. **Baseline.** Run everything once and record the state before changing anything.
2. **Triage** each finding: severity, priority, reproducible or not.
3. For each defect, in priority order: file it, write the failing regression test, fix, re-run the
   affected tests, commit with the ticket id (if filed), record the root cause.
4. **Stop and evaluate** after every few fixes, and at once if a fix breaks something else or a defect
   resists two attempts. Re-plan rather than keep pushing. A loop that keeps patching symptoms is
   missing the cause.
5. **Report**: what was found, fixed, deferred (with tickets) and not tested.

Treat a ticket's diagnosis as a claim. Reproduce the mechanism, re-test the original symptom after the
fix and measure the blast radius. "Three instances fixed" is a sample size: enumerate the whole
population of the same pattern before closing.

## Defect lifecycle

`New, Triaged, In progress, Fixed, In verification, Closed`, with side states `Rejected`, `Duplicate`
(link the canonical ticket and merge in its repro data), `Won't fix` (with a written reason) and
`Reopened`.

**Severity and priority are separate fields.** Severity is the technical impact; priority is business
urgency. A rare crash in a deprecated path can be high severity, low priority. A misaligned logo on the
launch page can be low severity, high priority. Never collapse them.

**A good report:** environment and build, preconditions, numbered exact steps, expected, actual,
evidence (log line, screenshot, response body), frequency. A bug that cannot be reproduced cannot be
verified fixed.

**Close with a learning:** the fix, the root cause and one line of what it taught. Closed tickets are
the memory that prevents recurrence.

**Fixes that remove things need a higher bar.** A rule that correctly finds rows can still delete real
ones when it acts. Audit every removal a fix makes, not only the additions.

## Regression management

- On every change re-run the smoke suite and every test touching the changed module or its dependants.
- The regression suite is a product, not a landfill. Add a test for every escape and fixed defect.
  Prune slow, redundant or meaningless tests. A bloated suite gets skipped, which defeats it.

**Flaky test policy:**
1. Quarantine it at once (tag it out of the gate) so it stops training people to ignore red.
2. Ticket it. Flakiness is a defect in the test.
3. Fix the cause: timing, shared state, unseeded randomness, real network, unstable ordering. Retries
   are not a fix.

## Exploratory sessions

Exploratory testing is planned work. Run it session-based:

- **Charter:** one line ("explore checkout with expired cards to assess data integrity").
- **Timebox:** 60 to 90 minutes, uninterrupted.
- **Notes:** what was tried, bugs, questions, coverage gaps.
- **Debrief:** file defects, decide follow-up charters.

Put sessions on high-risk and newly integrated areas. A green scripted suite with no exploratory time on
a critical feature is a coverage illusion.

## Non-functional checks

Functional pass is not quality. Each needs explicit evidence for high-risk areas:

| Dimension | Check |
|---|---|
| Performance | p50 and p99 latency, throughput and error rate measured against a stated target |
| Accessibility | WCAG 2.2 AA: automated scan, keyboard-only path, screen-reader pass |
| Security | Authn and authz on every endpoint, input validation, no secrets in logs, dependency audit; deep review via the `security-audit` skill |
| Internationalisation | Unicode, right-to-left, locale formats, no concatenated strings, room for longer text |
| Resilience | Timeout, dependency down, partial response, idempotent retry |
| Compatibility | Target browsers, devices, OS versions, breakpoints |

No measured evidence on a high-risk area makes it PARTIAL, not PASS.

## Exit criteria and Definition of Done

**Entry** (before testing starts): the build deploys, smoke passes, environment and data are ready,
every item in scope has acceptance criteria.

**Exit** (before release): every in-scope criterion PASS; no open defect at or above the agreed
severity; regression green; non-functional evidence for high-risk areas; coverage thresholds met;
residual risks written down and accepted by a named person.

**Definition of Done** for a work item:
- [ ] Acceptance criteria met and demonstrated
- [ ] Tests written and passing at the depth its risk tier needs
- [ ] Regression test added for each fixed defect
- [ ] Non-functional checks done where the risk warrants
- [ ] No known defect above threshold left open
- [ ] Docs and changelog updated
- [ ] Behaviour verified by hand at its real entry point, not only green in CI

**Go/no-go** is an explicit decision with a named owner. "We ran out of time" is not an exit criterion:
descope explicitly or move the date.

## Metrics and their traps

| Metric | Tells you | Trap |
|---|---|---|
| Escape rate | How much QA catches | Falls if nobody looks in production |
| Coverage % | What executed | Execution is not verification |
| Pass rate | Suite health | Says nothing about untested paths |
| Defect density | Where bugs cluster | Rewards under-reporting; never grade people with it |
| Time to detect or resolve | Loop speed | Rewards closing tickets early |

## Red flags

- A non-trivial fix with no ticket and no explanation in the commit.
- A fixed defect with no regression test, or one never seen failing on the old code.
- "Passed" with no out-of-scope list.
- A test marked flaky and still in the gate, or "retry 3 times" added to make it pass.
- QA sign-off presented as customer acceptance. Passing QA means it works as specified; whether it
  meets the business need is the `uat` skill's question.

## Verification

Before signing off a phase, every line has evidence:

- [ ] Risk register exists; depth matches tier
- [ ] Test plan states in scope and out of scope
- [ ] Each acceptance criterion marked PASS, FAIL or UNTESTED (no silent gaps)
- [ ] Every defect filed before its fix; closed defects carry root cause and learning
- [ ] Regression test per fixed defect, shown failing with the fix reverted
- [ ] At least one exploratory session per high-risk area, with notes
- [ ] Non-functional evidence for high-risk areas
- [ ] Behaviour exercised at its real entry point, with the command or steps recorded
- [ ] Go/no-go recorded with a named owner and the accepted residual risks
- [ ] Business acceptance routed to UAT
