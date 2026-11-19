# Saga troubleshooting by symptom

Read this when a multi-step workflow across services misbehaves. Each entry starts from what
you see.

## Contents

- Saga stuck in a running or compensating state
- A step ran twice
- Compensation ran in the wrong order or skipped a step
- A compensation itself fails
- A saga finished but the data disagrees between services
- Design checklist

## Saga stuck in a running or compensating state

Likely causes:
- The coordinator sent a command and the reply was lost. Nothing times out the wait.
- The coordinator crashed between persisting its state and sending the next command.
- A participant rejected a message it could not parse and the rejection went to a dead letter
  queue no one watches.

Fixes:
- Every step has a deadline stored with the saga state. A sweeper finds sagas past their
  deadline and either re-sends the command (participants are idempotent) or starts
  compensation.
- Persist state and the outgoing command together (outbox), so a crash cannot lose the command.
- Alert on saga age by state, not only on failures.

## A step ran twice

Likely causes:
- At-least-once delivery plus a participant that does not dedupe.
- The coordinator re-sent after a timeout while the first command was still being handled.

Fixes:
- Each command carries a saga id and step id. The participant records processed
  `(saga_id, step)` pairs in the same transaction as its effect and acknowledges duplicates
  without acting.
- Timeouts longer than the participant's real p99, so re-sends are rare rather than routine.

## Compensation ran in the wrong order or skipped a step

Likely causes:
- Compensations derived from "steps configured" rather than "steps that completed".
- Parallel steps with no recorded completion per step.

Fixes:
- Record each completed step in the saga state. Compensate exactly the completed steps, in
  reverse order of completion.
- A step that may or may not have happened (timed out) is compensated too. Compensations
  must therefore be safe to run against a step that never took effect.

## A compensation itself fails

- Compensations are retried with backoff like any job, and must be idempotent.
- After the retry cap, the saga moves to a terminal `needs_attention` state with an alert and a
  runbook entry. A human decides. Never silently mark it compensated.
- Some actions cannot be undone (an email sent). Put those last in the saga, after every step
  that can still fail.

## A saga finished but services disagree

- A participant acknowledged before committing its local transaction. Acknowledge only after
  commit.
- Events published outside the transaction (dual write). Use the outbox.
- Run a reconciliation job that compares the services' records for completed sagas and
  reports mismatches. Its count of mismatches should be zero; if it has never reported one,
  test it by planting a mismatch.

## Design checklist

- [ ] Saga state persisted with step, status, deadline and completed-steps list.
- [ ] Every command and event carries saga id and step id.
- [ ] Every participant and every compensation is idempotent.
- [ ] Irreversible steps last.
- [ ] Sweeper for overdue sagas; alert on age per state.
- [ ] Terminal failure state with an owner and a runbook.
