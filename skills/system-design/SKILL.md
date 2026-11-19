---
name: system-design
description: "Use when deciding how a system or feature should be structured before building it: architecture, service boundaries, data ownership, consistency, scaling, monolith versus services, event-driven designs, legacy replacement or an ADR. Not for implementing a chosen pattern; use `backend-patterns`. Not for table design; use `database`."
license: MIT
---

# System design

Architecture is the set of decisions that are expensive to reverse. The job is to make as few
of them as possible, make each one on evidence and write down why.

## Order of work

1. **Scope gate.** Before any design, write down: the problem in one sentence, who has it,
   the measured or credibly estimated load (requests per second, data size, growth), the hard
   constraints (latency, compliance, budget, team size) and the non-goals. If load or
   constraints are unknown, say so and design for the known case. Stop here if the problem
   does not need a design (one component, easily reversed).
2. **Read what exists.** In an existing codebase, find the current conventions, layers and
   every entry point that touches the area before proposing anything. Two code paths can share
   a name and have opposite properties; characterise the system from the code, not from its
   names or its docs.
3. **Capabilities, not components.** List what the system must do. Group capabilities by who
   owns the concept end to end. Those groups are the candidate boundaries.
4. **Contracts before internals.** For each boundary, define what crosses it (calls, events,
   data) before deciding how either side works.
5. **Options with trade-offs.** At least two real options for each significant decision, in the
   table below. Recommend one.
6. **Lock the details that are expensive later:** data flow, data ownership, consistency per
   read path, failure behaviour per dependency, test strategy, performance budget.
7. **Blueprint and build order.** The files or modules to create or change, the order to build
   them, and the first thin slice that runs end to end.

## Defaults

- **A modular monolith first.** One deployable, strict internal module boundaries, one
  database with each table owned by one module. Split a service out when a boundary has a
  measured reason: different scaling, a different release cadence, a separate team or a
  different security zone.
- **Scale up before out.** A bigger machine plus a read replica covers most products for a
  long time. Add caches, queues, sharding or CQRS only when a measurement says so.
- **Boring technology.** Choose what the team already runs well. Justify anything new against
  this problem; popularity is not a reason.
- **Strong consistency for writes** through one authoritative store; eventual consistency
  only for derived read models (caches, projections, search indexes).

## Trade-off table

Use for every significant decision.

| | Option A | Option B |
|---|---|---|
| What it makes easy | | |
| What it makes harder | | |
| What it makes impossible or very costly to undo | | |
| Operational cost (people, money, on-call) | | |
| Signal that would make us revisit | | |

The last row matters most. "Revisit when write volume passes 2,000 per second" is testable;
"revisit if needed" is not.

## Back-of-envelope numbers

Estimate before choosing. Peak requests per second (daily volume / 86,400 x peak factor of
3 to 10), storage per year (rows x row size x growth), working set versus memory and fan-out
per request. Write the arithmetic down so it can be checked. An architecture that needs 10x
the estimated peak to justify itself is premature.

## Data ownership and consistency

- Every entity has exactly one writer. Others read through its API, its events or a replica.
- Every data store and every critical read path states its consistency model:
  - **Strong:** reads see the latest write. Money, stock levels, permissions.
  - **Read-your-writes:** the writer sees their own change at once. Profile and settings edits.
  - **Causal:** replies after the post they answer. Threads, activity feeds.
  - **Eventual:** may be stale, converges. Analytics, search, recommendations.
  "It depends" is not an answer; name the model and the maximum staleness.
- CAP only bites during a partition; the everyday trade is latency against consistency
  (PACELC). State which one each path favours when the network is healthy.

## Failure design

For each dependency, write: what happens when it is slow, when it is down and when it returns
wrong data. Decide the timeout, the fallback and who is alerted. The design must survive the
loss of any single component, or the document must say which loss takes the system down and
why that is accepted.

## Architecture decision records

Write an ADR when a decision touches more than one component, would take more than a day to
reverse, or chose between two reasonable options.

```markdown
# ADR-NNN: <decision as a short statement>
Status: proposed | accepted | superseded by ADR-MMM
Context: the forces and constraints, with numbers
Decision: what we will do
Alternatives: each option considered and why it lost
Consequences: what gets easier, what gets harder, what we must now watch
Revisit when: a measurable trigger
```

Keep ADRs short and immutable. Supersede, never rewrite. Prune the index when many describe
decisions that no longer bind; a long list of stale ADRs hides the few that matter.

## Component diagrams

- Each component: its responsibility, its consumers, its dependencies.
- Each connection: protocol (HTTP, gRPC, queue), direction, auth and who owns the data.
- Each data store: its single owning component.

## Antipatterns

- **Shared database between services.** Couples their schemas and releases. Services share ids
  and events, not tables.
- **Distributed monolith.** Services that must all be up and deploy together. All the cost of
  services, none of the benefit.
- **Synchronous chains.** A calls B calls C calls D. Availability multiplies down: four
  services at 99.9% give about 99.6%.
- **Vague boundaries.** If two engineers disagree about who owns a concept, the boundary is wrong.
- **Designing for a million users before the first hundred.** Every layer added for scale is
  paid for daily in complexity.
- **A diagram of the intended system presented as the current one.** Mark which is which.

## When to read the references

- Read `references/ddd.md` when the domain has complex rules, several sub-domains or several
  teams: bounded contexts, ubiquitous language, aggregates.
- Read `references/distributed-patterns.md` before choosing between outbox, saga, event
  sourcing or CQRS.
- Read `references/legacy-migration.md` when replacing or wrapping an existing system.

## Quality checklist

- [ ] Scope gate written, with load figures and non-goals.
- [ ] Existing code read; current conventions and entry points listed.
- [ ] Every entity has one owner and a stated consistency model.
- [ ] Every significant decision has the trade-off table and a revisit trigger.
- [ ] Each component's failure behaviour documented; single points of failure named.
- [ ] External dependencies replaceable behind an interface.
- [ ] Each component deployable on its own, or the coupling is written down as accepted.
- [ ] Build order with a first end-to-end slice.

## Gotchas

- **Designing from the docs, not the code.** Architecture docs drift. Measure what the code
  does (call sites, imports, actual data flow) and defer to it.
- **A pattern chosen for a word in the brief.** "Audit trail" does not mean event sourcing; an
  append-only audit table is usually enough. Map the requirement to the cheapest structure that
  meets it.
- **Microservices to solve a team problem the team does not have.** One team rarely benefits
  from more than a few deployables.
- **A cache added before the query was fixed.** It hides the slow query, adds an invalidation
  bug and still serves stale data under load.
- **An ADR written after the build.** It records the outcome, not the decision. Write it while
  the alternatives are still live.

## Verification

The design is done when another engineer can build the first slice from the document without
asking a question, and when each checklist item points at a section of the document, not at
an intention.
