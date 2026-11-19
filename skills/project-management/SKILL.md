---
name: project-management
description: Use when asked "how long will this take", "when will it be done", or to plan phases, estimate, find the critical path, run a risk register or RAID log, plan capacity, control scope change or write a status (RAG) report. Not for what to build (use `product-management`) or session task lists (use `workflow`).
license: MIT
---

# Project management

This skill is *how long* and *in what order*, and how to say so honestly. Feature value lives in the `product-management` skill; testable conditions in the `requirements` skill; the session task file and handoff in the `workflow` skill.

## Rules that matter most

1. **Quote ranges, never a single date, until the design is settled.** An early estimate is a forecast with a shelf life, not a promise. Re-estimate at every phase boundary.
2. **A gate must be able to say no.** "Design complete" is not a gate. "Design signed off by the named approver" is. Every phase ends in something testable.
3. **RAG reports the forecast, not the effort.** "The team is working hard" is not green. If the date is at risk, the status is amber this week, not the week it slips.
4. **Nothing enters a baselined scope silently.** Every change is sized, its displacement stated and a decision recorded.
5. **Know the critical path before promising a date.** Speeding up work that has float does not move the finish.
6. **Two critical tasks on one person are sequential.** A plan that shows them in parallel is fiction.

## When not to use

- Deciding what to build or in what priority: the `product-management` skill.
- Writing stories and acceptance criteria: the `requirements` skill.
- The per-session plan file, lessons loop and handoff: the `workflow` skill.
- Declaring a milestone done: the `milestone-gate` skill.

## Phase planning

- Each phase produces something testable and has a single accountable owner.
- Keep phases to 1 or 2 weeks. Longer phases hide risk until it is too late.
- The last phase is never "testing". Testing happens inside each phase; testing deferred to the end concentrates all the risk where there is no time left.
- Write per phase: goal (one sentence: what is true when done), owner, done-when (specific and verifiable), tasks, acceptance criteria, dependencies, risks. The `workflow` skill has the `tasks/todo.md` layout.

## Estimation

- **Points** measure relative size (complexity, effort, uncertainty) for team planning. **Time** is for external commitments only, derived from measured velocity.
- Never convert points to hours with a fixed multiplier. It launders a guess into false precision.
- For any estimate quoted upward, take three numbers: optimistic O, most likely M, pessimistic P.
  - Expected = (O + 4M + P) ÷ 6. Standard deviation ≈ (P − O) ÷ 6.
  - A wide O to P spread is the risk signal: retire the unknowns (a spike, a prototype) before committing, not after.
- **Cone of uncertainty**: at project start a range of roughly 4× either side is normal. It narrows only as unknowns are retired.
- **Velocity forecasting**: use the last 3 to 6 iterations of *completed* work, not plans. For any date a stakeholder will hold you to, use the low end of the range.
- Sum of tasks is not the project. Add integration, review, deployment and the hand-offs between people. These are the parts most often left out.

## Capacity

- Plan against net capacity: people × days, minus leave, holidays, meetings, support rota and interrupt work. Teams commonly lose 20 to 30% to these.
- Load each person as a percentage of their net capacity. Above about 85% there is no slack to absorb anything, and the plan will slip on the first surprise.
- Split each iteration into committed (P0, must land) and stretch. Report against the committed line only.
- Watch for imbalance: one person on every critical task, one reviewer for everything, a specialist nobody else can cover. These are hidden dependencies.

## Critical path and dependencies

- The critical path is the longest chain of dependent tasks. Its length is the minimum duration.
- **Float** is how long a task can slip before it moves the finish. Critical tasks have zero. A near-critical chain with two days of float becomes critical the moment it slips two days; watch those too.
- Dependency types: finish-to-start (the default, the usual blocker), start-to-start (parallel work with a shared trigger), finish-to-finish (integration and sign-off).
- **Hidden dependencies hurt most**: a shared person, a shared environment, a single reviewer, an external approval. They do not appear in a task list. Surface each with an owner and a needed-by date.
- When work runs in parallel (people or agents), give each stream the files or modules it owns and the interface contract it must honour. Two streams editing one file is an unplanned dependency.

## Risk register and RAID log

Score each risk as likelihood × impact. Act by quadrant:

- High likelihood, high impact: mitigate before the phase starts.
- Low likelihood, high impact: write the contingency and its trigger now.
- High likelihood, low impact: accept, record, monitor.

Every risk needs a **mitigation** (action now to reduce likelihood or impact), a **contingency** (the plan if it happens) with a **trigger** (when to invoke it) and an **owner**. A risk with no owner and no next action is a wish. A risk that has happened moves to Issues.

Keep one RAID log and review it every phase, sorted by score:

| Register | Is | Key fields |
|---|---|---|
| Risks | Might happen | Likelihood, impact, mitigation, contingency, trigger, owner |
| Assumptions | Believed true, not verified | What breaks if false, who validates, by when |
| Issues | Happening now | Impact, owner, action, target date |
| Dependencies | Needed from elsewhere | Owner, needed-by date, status |

Assumptions are the quiet killer: an unlogged assumption is an unowned risk.

## Change control

- Baseline the scope at hand-off. After that, every addition is a change, not a clarification.
- Path for a change: capture the ask, size it in time and effort, state what it displaces, get an explicit decision from the scope owner, record it.
- The trade-off is always one of: a later date, more people or something dropped. "Just add it" is never free.
- Escalate when scope has grown more than 20% without approval. That threshold invokes change control; it is not an allowance to absorb 19% quietly.

## Escalation thresholds

Stop and tell the person accountable for the plan (the sponsor or decision owner) when:

- A phase has run twice its estimate.
- A dependency has been blocked for more than 3 working days.
- A materialised risk changes feasibility.
- Scope has grown more than 20% without approval.

## Status reporting

A status report says three things: what changed since the last one, what is at risk, what you need from the reader. Anything else is noise. Read `references/governance.md` for the RAG definitions, stakeholder cadence, delivery-model choice, Definition of Done and DORA signals.

## Gotchas

- **The single date off an early guess.** It becomes a stick to beat the team with. Quote a range and its assumptions.
- **The register written once and never read.** Score, sort and review each phase; retire what has passed.
- **Dependencies discovered at integration.** Shared people, environments and approvals. Surface them at planning.
- **Watermelon status.** Green outside, red inside. It destroys trust and removes the chance to recover.
- **Small additions absorbed.** This is how a locked MVP doubles.
- **Optimising off the critical path.** Effort spent where there is float changes nothing.
- **Hours from points.** False precision. Forecast from velocity.
- **Integration left out of the estimate.** The tasks add up; the project does not.

## Verification

Before signing off a plan or a status report:

- [ ] Every phase has a done-when gate that can say no
- [ ] Estimates are ranges from measured velocity or three-point estimates, with assumptions written
- [ ] Capacity is net of leave and meetings; nobody is loaded above about 85%
- [ ] The critical path is named and its float known
- [ ] Every external and cross-team dependency has an owner and a needed-by date
- [ ] Top risks are scored, with mitigation, contingency, trigger and owner
- [ ] Assumptions are logged and assigned
- [ ] Scope is baselined and every change went through change control
- [ ] RAG reflects the forecast honestly
- [ ] Every stakeholder group has a cadence and a no-surprises escalation path
