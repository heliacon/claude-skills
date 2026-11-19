---
name: logging
description: Use when adding logging, error handling, failure reporting, metrics, tracing, alerts, SLOs or dashboards. Also when asked "how will we know it broke", "why is nothing in the logs" or "add observability". Covers structured logs, metrics, traces and user-facing error reports.
license: MIT
---

# Logging and observability

Telemetry exists to answer questions during an incident. Instrument for the questions, then
prove the telemetry fires. A log line nobody has seen fire is a guess.

## The rules that matter most

1. **Define "working" first.** Before adding any instrumentation, write the three to five
   questions someone will ask when this breaks ("are uploads failing?", "which tenant?", "since
   when?") and what healthy looks like as a number. Instrument to answer those.
2. **Pick the signal for the question.**
   - **Log:** a discrete event with context you will read one at a time (this upload failed,
     here is why).
   - **Metric:** a count, rate or distribution you will graph and alert on (errors per minute,
     p99 latency).
   - **Trace:** where time went across components for one request.
   Do not alert on log text if a metric can carry the number.
3. **A failure is recorded as a failure.** Never write a default, empty or zero result when the
   work failed. A failed fetch stored as "no data" is indistinguishable from a real "no data"
   and corrupts every figure built on it.
4. **Every ERROR answers five questions:** what was being attempted, what went wrong, what was
   expected, what action was taken, where to look next.
5. **Never log secrets or personal data.** Passwords, tokens, API keys, full card numbers,
   names, emails, addresses, request bodies of authenticated endpoints. Log internal ids.
   Enforce it in the logger (a redaction filter), not by remembering.
6. **Prove it fires.** Trigger each failure path and see the log line, the metric move and the
   alert arrive. Until then the instrumentation is unverified.

## Format

- **Services and anything shipped to a log store:** structured JSON, one object per line, to
  stdout. Let the platform collect and rotate.
- **Local tools, desktop apps and single-process scripts:** human-readable text to a rotating
  file, for example in this shape:
  ```
  [2025-01-15 09:32:12] [ERROR] [PARSER] Row 23 of orders_2025-01.csv: date "2025-13-45" could not be parsed. Expected YYYY-MM-DD. Upload rolled back. Details in failed/orders_2025-01.csv.error
  ```
- One format per service. Mixed formats break every parser downstream.
- Timestamps in UTC, ISO 8601, with milliseconds for services.
- Component names short, upper case and fixed per project (`API`, `PARSER`, `SCHEDULER`,
  `STARTUP`) so one filter finds one area.

Structured fields for every service log line:

```json
{"ts": "2025-01-15T09:32:12.481Z", "level": "ERROR", "service": "orders",
 "msg": "Payment charge failed", "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
 "span_id": "00f067aa0ba902b7", "order_id": "ord_abc123", "error.type": "ConnectionTimeout",
 "attempt": 2}
```

Messages are constant strings; variable data goes in fields. "Payment charge failed" with an
`order_id` field can be counted and grouped; an id baked into the message cannot.

## Levels

| Level | Meaning | Who acts |
|---|---|---|
| ERROR | A request, job or record failed and was not recovered | Someone, soon |
| WARNING | Degraded or unexpected, but handled (fallback used, retry succeeded, input skipped) | Someone, if it trends |
| INFO | Lifecycle and business events: start, stop, config summary, job completed with counts | Nobody; context |
| DEBUG | Detail for diagnosis | Off unless `LOG_LEVEL=DEBUG` |

Log application start (version, environment, key non-secret config) and shutdown. Log a
summary line when a batch finishes: "Complete: 44 loaded, 3 skipped, 0 failed". A batch
with no completion line has not finished, as far as anyone reading the log knows.

## Messages people can act on

Write each message so someone who did not write the code knows what happened.

| Useless | Useful |
|---|---|
| `Error in parser` | `Row 23 of orders_2025-01.csv: quantity "1,2" is not a number` |
| `Done` | `Upload complete: 44 loaded, 3 skipped (duplicates), 0 failed` |
| `Exception: KeyError 'SKU'` | `Column "SKU" missing from orders_2025-01.csv. Found: Date, Product, Qty` |
| `Retrying...` | `Payment API timeout for ord_abc123, attempt 2 of 5, next try in 4s` |

Log the exception with its stack trace (`exc_info` or the language equivalent) at the place it
is handled, and only there. Logging and rethrowing at every layer turns one failure into five.

## Failure reports for people who are not engineers

When a file or batch operation fails and a person must fix the input, write a plain-text report
next to the failed file (`<name>.error`) or show the same content in the UI:

```
File: orders_2025-01.csv
Failed at: row 23
Problem: the date "2025-13-45" is not a real date (there is no month 13)
Expected: a date like 2025-01-15
Rows processed before the failure: 22 (they will be skipped on retry)

Next step: open the file, correct the date in row 23 and drop the file in again.
```

"Next step" uses no jargon and is something the reader can do. Retrying must be safe: say
whether earlier rows are skipped or reprocessed, and make it true.

## Correlation and traces

- Accept the W3C `traceparent` header at the edge, or start a trace if absent. Propagate it on
  every outbound call and every queued message.
- Put `trace_id` (and `span_id`) on every log line, so one search returns everything for one
  request across services.
- Default to OpenTelemetry SDKs and auto-instrumentation for HTTP, database and queue clients;
  add manual spans only around meaningful work.
- Sample traces deliberately: keep every error and slow trace, sample the healthy ones.

## Metrics

- **Services:** rate, errors, duration (RED) per endpoint or job type. **Resources** (pools,
  queues, disks): utilisation, saturation, errors (USE).
- Latency as a histogram, read as percentiles. An average hides the slow tail users feel.
- **Label cardinality is a cost.** Never use user id, email, request id, raw URL or error text
  as a metric label. Use route templates and error classes.
- Count both outcomes. A metric for "jobs attempted" with none for "jobs succeeded" will look
  healthy while everything fails.
- For queues and outboxes, the age of the oldest item beats the count.

## SLOs and alerts

- SLI = good events / valid events (for example, requests answered under 300ms without a 5xx).
- Error budget = 1 - SLO. At 99.9% over 30 days that is 43.2 minutes of total failure, or the
  equivalent spread out.
- Alert on budget burn rate, using a long and a short window together (for example 1 hour and
  5 minutes, firing at about 14 times the sustainable rate), so pages are both fast and real.
- Alert on symptoms users feel, not on causes (CPU at 80% is a dashboard, not a page).
- Every page links a runbook with the first three things to check. An alert with no action is
  noise; delete it or make it a ticket.
- Each alert must be able to fire. Count how often it has fired. An alert that has never fired
  in a period when the failure did occur is broken; test it by inducing the condition.

## Gotchas

- **Rotating file handler in several processes.** Python's `RotatingFileHandler` is not safe
  across processes (gunicorn workers, multiprocessing). Rotation corrupts or loses lines. Log to
  stdout, or use one writer process.
- **Python `extra` with a reserved key.** `extra={"message": ...}` or `{"args": ...}` raises at
  log time, often inside an error path. Prefix custom keys or use a structured logger.
- **Python prints `WARNING`, not `WARN`.** Filters and parsers that match `WARN]` miss them.
- **Logger configured after imports.** Modules that log at import time use the default handler
  and their lines vanish. Configure logging first in the entry point.
- **Logging in a hot loop.** A per-item INFO line in a loop of a million items floods the store
  and slows the loop. Log a summary with counts, and sample per-item lines.
- **Expensive message construction.** An f-string inside a DEBUG call is built even when DEBUG
  is off. Use the logger's lazy formatting or guard the call.
- **Swallowed error with a log line.** `except Exception: log.error(...)` and carry on still
  reports success to the caller. Log and then fail, or log and return an explicit failure.
- **Failures stored as normal rows.** If failures are stored as normal-looking rows, the only
  way to find them later is indirect, such as write time. Record an explicit status column.

## Verification

- For each question from rule 1, show the log query, metric or trace that answers it.
- Force each failure path (bad input, dependency down, timeout) in a test or staging and capture
  the ERROR line with all five elements.
- Show a log line from a request that crossed two components carrying the same `trace_id`.
- Grep a sample of real output for secrets and personal data patterns (emails, tokens, card
  numbers): zero hits.
- For each alert, record the date it last fired or the test that made it fire.

Read `references/setup.md` when wiring up a logger: Python (text file, JSON stdout), Go
`slog`, Rust `tracing` and Swift `os.Logger` setups.
