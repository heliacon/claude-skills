# Distributed patterns: when to use which

Read this before choosing outbox, saga, event sourcing, CQRS or a queue. Implementation detail
for outbox and sagas is in the `backend-patterns` skill.

## Contents

- Decision table
- Outbox
- Saga
- Event sourcing
- CQRS
- Scaling patterns

## Decision table

| Need | Use | Not |
|---|---|---|
| Publish an event reliably after a database write | Outbox | Write then publish (dual write) |
| One business operation across services with no shared transaction | Saga | Two-phase commit across services |
| Full history is the requirement, or "state as of date X" queries | Event sourcing | An audit column bolted on later |
| Read shape very different from write shape, at measured cost | CQRS with projections | CQRS by default |
| Burst absorption, slow work, decoupled consumers | Queue | A queue between two functions in one process |

## Outbox

Solves the dual-write problem: a domain write and an event publish that must both happen or
neither. The event row is written in the same transaction as the domain change; a relay
publishes afterwards. Delivery becomes at-least-once, so consumers must dedupe.

## Saga

A sequence of local transactions across services, each with a compensating action
(release, refund, cancel). Compensation is a new business action, not a rollback.

- **Orchestration** (a coordinator owns the state machine): more than three steps, complex
  compensation, need to see the whole flow in one place. The default.
- **Choreography** (each service reacts to events): two or three steps, loosely coupled
  services. Harder to trace as it grows.

Order steps so irreversible actions (emails, shipments) come last.

## Event sourcing

The event log is the source of truth; current state is derived by replay.

Use when the audit trail is a hard requirement, temporal queries matter or the domain is a
long chain of state transitions. Do not use for plain CRUD.

Costs to accept up front:
- Event schemas are forever. Plan versioning (upcasters) on day one.
- Rebuilding projections takes time; snapshots are needed once streams are long.
- Personal data in immutable events conflicts with deletion rights. Keep personal data out of
  events, or encrypt per subject and discard the key on deletion.

## CQRS

Separate write model and read models. Reads come from projections updated by events, so they
lag. Adopt only when one model demonstrably cannot serve both sides; the lag must be acceptable
on every screen that reads a projection, including the screen the user sees right after a write
(read-your-writes).

## Scaling patterns

| Pattern | Use when | Cost |
|---|---|---|
| Vertical scaling | Load predictable, team small | Low |
| Horizontal scaling behind a load balancer | Spikes, redundancy needed, stateless app tier | Medium |
| Read replica | Read heavy, some staleness tolerable | Medium; replica lag must be handled |
| Cache | Repeated reads of the same data, latency sensitive | Medium; invalidation is the hard part |
| Queue | Background work, bursts, decoupling | High; new failure modes |
| Sharding | One primary cannot hold the writes or data | Very high; cross-shard queries and rebalancing |
| CQRS | Complex domain, divergent read and write shapes | Very high |

Default: vertical plus a read replica. Add the next row only when a measurement says so.
