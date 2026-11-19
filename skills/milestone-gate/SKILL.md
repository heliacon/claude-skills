---
name: milestone-gate
description: Use when asked to run a milestone or release gate, or to close a milestone or phase, or when /craft:milestone-gate is run (optional milestone name). Also when closing a milestone in a project that defines gates, such as a `docs/gates/` folder. Not for checking one phase against its criteria (use `quality-assurance`) or user sign-off alone (use `uat`).
license: MIT
---

# Milestone gate

A hard-blocking quality gate for the whole milestone: engineering quality, product intent and sign-off.
It differs from a per-phase check, which tests one phase's output against its acceptance criteria.

**Milestone:** $ARGUMENTS

If no milestone is named above (blank, or the placeholder shows literally), infer it from the project
plan (roadmap, `tasks/todo.md`, plan docs): the most recent milestone whose phases are all finished and
which has no gate report yet. State the inference at the top of the report. If two candidates fit, ask.

Use it when someone asks for a gate or to close a milestone, or when the project has opted in (a
`docs/gates/` folder or a gate definition). In a project with neither, a plain "mark this done" does not
need it; suggest the gate in one line and do as asked.

## The rules that matter most

1. **The gate is blocking.** Any FAIL means the milestone is BLOCKED. There are two ways out: fix the
   failure and re-run that section, or a written waiver from the decision owner (a named person,
   usually the project lead) recorded in the report. Nothing else advances a blocked milestone.
2. **In a gated project, the gate is tied to the state change.** Once a project uses gates, no
   milestone is marked done anywhere (ticked in a roadmap or todo, marked complete in a phase table,
   plan or handoff note) unless a gate report with verdict PASSED exists in `docs/gates/`. If asked to
   mark one done there and no report exists, run the gate first.
3. **Evidence is fresh output, not memory.** For each row: name the command or check that proves it,
   run it now, read the whole output, then record the result with an excerpt. A check with no output
   from this run has not passed. A previous run's report is not evidence for this one.
4. **Some rows cannot be self-approved.** Design sign-off and every waiver need the decision owner. No
   agent approves them, including the one running the gate.
5. **An unfilled row is a FAIL.**

If the project defines its own gate (a project skill or `docs/gates/GATE-DEFINITION.md`), read it
first. It wins where it conflicts with this one.

## Entry criteria

Check these before anything else. If any fails, stop and report: a gate that cannot pass wastes a
session.

- [ ] Every phase in the milestone has passed its own phase check
- [ ] Test suite green on the milestone branch; no skips added this milestone without a recorded reason
- [ ] No open Critical or High bugs against the milestone's components in your tracker
- [ ] Working tree clean, work committed
- [ ] A scope statement for the milestone exists (roadmap entry, plan doc or todo section)

## Gate report

Create `docs/gates/GATE-<milestone>-<YYYY-MM-DD>.md` at the start and fill it as you go. Read
`references/report-template.md` for the layout. Each item gets a row with one status:

- **PASS**, with evidence (command and output excerpt, file and line, screenshot path).
- **FAIL**, with what failed.
- **WAIVED**, with the decision owner's waiver text, name and date.
- **N/A**, with a one-line reason.

"Not assessed" is not a status. A row you could not check is a FAIL until it is checked or waived.

Finish with a verdict block: **PASSED** or **BLOCKED (items: ...)**.

## Track A: engineering

Run in order. Each names the skills to load; use the matching agent (`architect`, `security`, `tester`,
`pm`, `designer`) where installed so the review is not marked by the author.

### A1. Architecture
Skills: `system-design`, plus the project's ADRs.
- [ ] Every architectural decision made this milestone has an ADR or a decisions-log entry
- [ ] No new circular dependencies or layering violations against the documented architecture
- [ ] Debt taken on knowingly is written down with a repayment note

### A2. Code review
Skills: `code-quality` plus the language skill (`go`, `rust`, `swift` and so on). Review the full
milestone diff at high effort.
- [ ] All Critical and High findings fixed, not deferred
- [ ] Medium findings fixed or ticketed with an id
- [ ] Pre-commit hooks never bypassed this milestone (search the log and CI for `--no-verify` or
      skipped hooks)

### A3. Security
Skills: `security-audit`, `security`.
- [ ] Threat model delta: what this milestone added to the attack surface
- [ ] Secret scan clean, history and working tree
- [ ] Dependency audit run; no known-vulnerable versions introduced
- [ ] Auth and input-validation paths touched this milestone re-reviewed
- [ ] No open Critical or High security findings

### A4. Regression
Skills: `tdd`, `quality-assurance`, `testing-strategy`.
- [ ] Full suite green, run fresh in the project's real environment (the container or CI image if that is
      the convention), not only the fast tier
- [ ] The project's own regression checks green (smoke or route inventory, evals, live checks)
- [ ] New behaviour this milestone has tests; coverage did not silently drop
- [ ] Each test added for a fix this milestone was seen failing without the fix
- [ ] Flaky tests quarantined and ticketed, not deleted or retried into green
- [ ] New code is reachable: each new feature is called from a real entry point, checked by driving it

### A5. Accessibility
Skills: `frontend`. Use an automated scanner (axe or similar) in diff mode against a baseline on every UI
surface the milestone touched.
- [ ] No new WCAG 2.2 AA violations against the baseline
- [ ] Keyboard path works for every new interaction; focus visible
- [ ] New images have meaningful alt text; contrast passes AA
- N/A only when the milestone has no UI surface. Say so.

### A6. Release readiness (when the milestone ships to users)
Skills: `devops`.
- [ ] Rollback plan written: the trigger conditions, the steps and how long it takes
- [ ] Migrations reversible or a forward-fix plan recorded
- [ ] Monitoring and alerts cover the new paths
- N/A for milestones that do not deploy.

## Track B: product

### B1. Roadmap
Skills: `product-management`.
- [ ] The milestone as shipped still maps to the roadmap outcome it was scoped against
- [ ] Scope drift written down: what was added, what was dropped and why
- [ ] The roadmap is updated and still true after this milestone

### B2. Requirements traceability
Skills: `requirements`, `uat`.
Cross-reference three sources: the requirements (stories and criteria), the per-phase verification
records and what was actually built (diff, changelog). Build one table.
- [ ] Every story maps to acceptance criteria, and every criterion to a passing test or executed script
- [ ] No orphans: no criterion without evidence, no shipped behaviour without a requirement
- [ ] Non-goals respected: nothing from the won't-have list shipped without a decision record
- [ ] Anything demoted mid-milestone is back on the roadmap or explicitly dropped

### B3. Personas and journeys
Skills: `uat`, `ux-research`.
- [ ] Persona-mission scripts run for each primary persona across the milestone's journeys, written as
      intentions, not clicks
- [ ] Bar: completed unaided. A mission that needed a hint is a FAIL for that script
- [ ] Friction notes recorded even on passes; defects filed with severity
- [ ] Missions run by someone (or a fresh agent) that did not build the feature

### B4. Design sign-off
Skills: `designer`, `visual-design`.
- [ ] Every changed screen rendered and captured at narrow and wide widths, judged from the render,
      never from the code
- [ ] Design critique run; hierarchy survives greyscale
- [ ] **The decision owner signs off the visuals.** Present the captures and record their yes, name and date.
      No agent can approve this row.

### B5. Docs and hygiene
Skills: `docs`.
- [ ] README matches shipped behaviour; handoff notes current; `tasks/lessons.md` updated with this
      milestone's corrections
- [ ] Bug tracker clean for the milestone: fixes closed with root cause and learning
- [ ] User-facing copy follows the project's style guide

## Verdict and record

1. Fill the verdict block: PASSED, or BLOCKED with the failing rows listed.
2. If BLOCKED: file a bug per failure, fix or get a written waiver, re-run only the failed sections, then
   re-issue the verdict in the same report with the new date.
3. On PASSED: mark the milestone done in the roadmap and `tasks/todo.md`, commit the report, update the
   handoff notes.
4. Retro (see the `workflow` skill): lessons, decisions and ADRs.

## Rationalisations

| Excuse | Reality |
|---|---|
| "The phases all passed, so the milestone has." | Phase checks never look across phases: drift, orphans and integration gaps live between them. |
| "The suite was green yesterday." | Evidence is this run's output. Run it. |
| "The user only asked to tick the box." | In a gated project the gate is tied to the state change, not the phrasing. |
| "Design looks fine to me." | B4 cannot be self-approved. |
| "Not assessed, so leave it blank." | Blank is FAIL. |
| "Small milestone, skip the security section." | Mark it N/A with a reason if it truly has no surface; otherwise run it. |

## Red flags

- In a gated project, a done mark in any roadmap or plan with no matching PASSED report in `docs/gates/`.
- A PASS row with no command, output or file reference.
- A waiver with no human name and date.
- The verdict written before the rows are filled.
