---
name: backend-patterns
description: "Use when implementing server-side code: service layers, writes that must not double-apply, background jobs and queues, retries, timeouts, rate limiting, transactions, outbox or saga code. Also before a service ships. Not for the shape of the HTTP contract; use `api-design`. Not for choosing an architecture; use `system-design`."
license: MIT
---

# Backend patterns

Most backend outages come from the same handful of causes: a write applied twice, a call
with no timeout, retries that multiply load, a failure swallowed so the request "succeeds",
and two systems assumed to commit together. This skill is the defence against each.

## The rules that matter most

1. **Every write that matters is idempotent.** Creates, charges, sends and irreversible
   effects dedupe on a key. Every job and message consumer dedupes on its id. Delivery is
   at-least-once; plan for the second run.
2. **Every outbound call has a timeout.** HTTP, database, cache, queue, SDK. No default
   "wait forever". A hung dependency otherwise drains your pool and the outage spreads.
3. **Retry only what can succeed on retry, at one layer only.** Timeouts, 5xx, connection
   resets, 429 after `Retry-After`. Never 4xx validation. Retries at three nested layers turn
   one failing call into 27.
4. **Never swallow an error.** An empty `catch` or `except: pass` makes the request report
   success while the side effect never happened. Handle it, or let it propagate to a mapped
   error.
5. **No dual writes.** Writing to the database and then publishing to a queue (or calling
   another service) is not atomic. Use the outbox pattern below.
6. **Server owns identity and amounts.** Derive the user from the authenticated session and
   prices from the server. Never trust `user_id`, `role` or `price` from a request body.

## Idempotency keys

Storage that is correct under concurrency (the common version has a race):

```sql
CREATE TABLE idempotency_keys (
  scope        TEXT        NOT NULL,           -- caller or tenant id
  key          TEXT        NOT NULL,
  fingerprint  TEXT        NOT NULL,           -- SHA-256 of method + path + canonical body
  status       TEXT        NOT NULL,           -- 'in_progress' | 'done'
  status_code  SMALLINT,
  response     JSONB,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (scope, key)
);
```

1. `INSERT ... (status='in_progress') ON CONFLICT DO NOTHING`. If the insert won, run the
   operation.
2. If the insert lost, read the row. Fingerprint differs: 422. Status `in_progress`: 409 (the
   first request is still running). Status `done`: replay the stored status and body.
3. Write the result and set `done` **in the same transaction** as the business write. If the
   operation fails with a retryable error, delete the row so the client can retry.
4. Expire keys after a stated window (24 hours is common) with a scheduled delete.

The race in the naive version: look up, find nothing, execute, store. Two concurrent
requests both find nothing and both execute. The unique insert is the lock.

Scope keys per caller. A global key space lets one client replay another client's response.

## Transactions and lost updates

- Keep transactions short. No network calls inside a database transaction: the call can hang
  while you hold row locks.
- Read-modify-write (check a balance, then deduct) is a lost update waiting to happen under
  Read Committed. Use one of, in this order of preference:
  1. A single conditional statement: `UPDATE accounts SET balance = balance - $1 WHERE id = $2
     AND balance >= $1` and check the affected row count.
  2. Optimistic locking: a `version` column, `UPDATE ... WHERE id = $1 AND version = $2`,
     retry or 409 on zero rows.
  3. `SELECT ... FOR UPDATE` inside the transaction.
  4. Serializable isolation, with a retry loop for serialization failures.
- Isolation levels, pooling and lock details: the `database` skill.

## Outbox (reliable events after a write)

```python
with db.transaction():
    order.confirm()
    repo.save(order)
    outbox.insert(type="order.confirmed", aggregate_id=order.id, payload=order.event())
```

A separate relay reads unpublished rows in order, publishes, then marks them published.

- The relay publishes at least once. Consumers dedupe on the event id.
- Claim rows with `SELECT ... FOR UPDATE SKIP LOCKED LIMIT n` so several relays do not
  publish the same batch.
- Per-aggregate order matters more than global order. Partition by `aggregate_id` if the broker
  supports keyed ordering.
- Alert on the age of the oldest unpublished row, not on row count.

## Background jobs

Move work out of the request when it is slow, calls a third party or can be retried
(email, reports, webhooks, imports).

- **Backoff:** exponential with full jitter: `sleep = random(0, min(cap, base * 2**attempt))`.
  Jitter of a small fraction on top of the exponential still lets clients retry in lock step.
- **Attempts:** a cap per job type (five is a sound default), then the dead letter queue.
- **Fatal errors** (bad input, missing record, 4xx) go straight to failed. Retrying them only
  delays the alert.
- **Dead letter queue:** never delete. Alert on arrival, keep the payload, provide a replay
  command, replay only after the cause is fixed.
- **Visibility timeout or lease** longer than the slowest real run. Otherwise a slow job is
  handed to a second worker while the first is still running.
- **Poison messages:** a message that crashes the worker before it can record an attempt will
  loop forever. Count attempts before processing, not after.
- **Graceful shutdown:** on SIGTERM stop taking new work, finish or release in-flight work
  within the deadline, then exit.
- **One log line per transition** with `job_id`, `job_type`, `attempt`, `status`, `error` and
  `next_retry_at`. Payload summaries carry ids, never personal data. See the `logging` skill.

## Timeouts, retries and circuit breakers

- Set a total deadline per request and pass the remaining budget downstream. A 30 second
  inner timeout under a 10 second outer one is a bug.
- Connect timeout short (about a second), read timeout sized from the dependency's measured
  p99 plus margin.
- Retry budget: cap retries as a share of traffic (for example 10%) so a dependency outage
  does not triple its load.
- Circuit breaker on each hard dependency: open after a run of failures, fail fast while open,
  probe with one request to close. Decide the fallback for each (cached value, degraded
  response, clear error). "No fallback" is a valid decision; an undecided one is not.

## Rate limiting

- **Default: token bucket**, held in a shared store (Redis) and updated atomically with a
  single script so concurrent requests cannot both take the last token.
- Apply the narrowest dimension first: per user or token when authenticated, per IP when not,
  tighter per endpoint for expensive operations, plus a global ceiling.
- Return limit headers on every response. `RateLimit` and `RateLimit-Policy` are the IETF
  draft names; many clients still read `X-RateLimit-Limit`, `-Remaining` and `-Reset`. Pick one
  set and document it. A 429 carries `Retry-After` and a problem details body.
- Fail open or fail closed when the limiter's store is down: decide per endpoint. Login and
  password reset fail closed.

## Sagas (multi-service workflows)

Use when one business operation spans services that cannot share a transaction. Each step has
a compensating action (refund, release, cancel), not a rollback. Orchestrate (one coordinator
owns the state machine) when there are more than three steps or compensation is complex;
choreography only for short chains. When to use one at all is a `system-design` decision.

Read `references/saga-troubleshooting.md` when a saga is stuck, runs a step twice or
compensates in the wrong order.

## Code structure

- Domain logic is plain code with no framework imports. Framework decorators, ORM sessions or
  request objects inside domain functions are a smell: the logic can no longer be tested or
  reused without the framework.
- Ports and adapters: the domain calls interfaces (`OrderRepository`, `PaymentGateway`). Tests
  of use cases run against in-memory adapters; a few integration tests cover the real ones.
- Inject the clock and the id generator. Then make sure the injected clock reaches **every**
  write, not only the decision. A seam that covers the branch but not the stored timestamp
  passes every test until the real date crosses a boundary.
- Validate configuration at start-up and refuse to start on a missing or malformed value.
  A missing setting discovered on the first request in production is an outage.

## Review checklist

Tick each or waive it in writing with a reason.

- [ ] Input validated at the boundary (types, ranges, lengths, enums); 422 with field errors.
- [ ] Authorisation checked server-side on every route, per object ("does this caller own this
      record"), not only by role and never by hiding UI.
- [ ] Idempotency on every create, charge, send and irreversible write; consumers dedupe by id.
- [ ] Every failure path maps to a status and problem type; no unmapped exception escapes as 500.
- [ ] Every list bounded with a server-enforced default and maximum.
- [ ] No N+1: query count measured in a test or log, not judged by eye.
- [ ] Multi-write operations in one transaction; read-modify-write guarded.
- [ ] Every outbound call has a timeout; retries only for retryable errors, with full jitter.
- [ ] Structured log at each decision point with a request id; no secrets or personal data.
- [ ] Rate limits on expensive and abusable endpoints; 429 shaped correctly.
- [ ] Secrets from the environment or a secret store, listed in `.env.example`, never logged,
      never returned.
- [ ] Breaking contract changes versioned (the `api-design` skill).
- [ ] Tests: unit tests on domain logic, contract tests per endpoint including denied and
      invalid paths, full suite and type checker green.

## Gotchas

- **N+1 in a loop.** Querying per row of a result set. Fine on 10 rows in development, an
  outage on 100,000 rows. Join or batch, and assert a query count in a test.
- **Leaking internals.** Raw stack traces, ORM messages or SQL in a response. Map to a problem
  type; log the detail with the request id.
- **Synchronous work that should be a job.** Email or report generation in the request ties up
  a worker and times out the client. Enqueue and return 202 with a status URL.
- **Retrying non-retryable errors.** A request that failed validation fails the same way five
  more times and hides the real alert.
- **Distributed transaction by hope.** Two services, two writes, assumed to succeed together.
  Outbox, saga or at-least-once delivery with idempotent consumers. Pick one explicitly.
- **Record a failure as a result.** A worker that writes an empty or default row when its
  upstream call fails produces data indistinguishable from a real "nothing found". Write the
  failure as a failure (status, error, attempt), never as a valid empty result.
- **Measuring work instead of useful output.** Throughput of jobs attempted looks healthy while
  most of them fail. Report successes per second and the success rate together.
- **Log and rethrow at every layer.** One failure becomes five error lines. Log once, where it
  is handled.

## Verification

- A test fires two concurrent identical requests with one idempotency key: one effect, one
  replayed response.
- A test makes a dependency hang: the call times out at the configured value and the request
  returns a mapped error within its deadline.
- A job handler test runs the same message twice: one effect.
- A query-count assertion on each list endpoint with several related rows.
- A kill test on a worker mid-job: the job is retried, not lost and not run twice to completion.
