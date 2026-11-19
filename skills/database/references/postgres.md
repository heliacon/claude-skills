# PostgreSQL operations reference

Read this when choosing an isolation level, sizing a pool, partitioning a table, investigating
a slow query or bloat, or setting up a new database.

## Contents

1. New database defaults
2. Types to prefer and avoid
3. Isolation levels
4. Connection pooling
5. Query investigation
6. MVCC and vacuum
7. Partitioning

## 1. New database defaults

```sql
ALTER DATABASE app SET timezone = 'UTC';
REVOKE ALL ON DATABASE app FROM PUBLIC;
GRANT CONNECT ON DATABASE app TO app_user;
ALTER ROLE app_user SET idle_in_transaction_session_timeout = '60s';
ALTER ROLE app_user SET statement_timeout = '30s';   -- override per job where needed
```

- The application role owns no tables and cannot run DDL. Migrations use a separate role.
- Enable `pg_stat_statements` from day one; it is the first place to look for slow queries.

## 2. Types to prefer and avoid

| Avoid | Use | Why |
|---|---|---|
| `timestamp` | `timestamptz` | Without a zone the value is ambiguous |
| `serial` / `bigserial` | `bigint GENERATED ALWAYS AS IDENTITY` | Standard, cleaner ownership and permissions |
| `int` for ids on growing tables | `bigint` | Running out of 2.1 billion ids needs a rewrite |
| `money` | `numeric(p, s)` or integer minor units | `money` depends on the locale setting |
| `char(n)` | `text` | Pads with spaces, no benefit |
| `varchar(n)` with an arbitrary n | `text` plus a `CHECK (length(...) <= n)` when a limit is real | Easier to change the limit |
| `float` / `real` for money or counts | `numeric` / `bigint` | Binary floats round |
| JSON for fields you filter on | Columns; `jsonb` for true variable data | Constraints and statistics work on columns |

## 3. Isolation levels

| Level | Prevents | Still allows | Use for |
|---|---|---|---|
| Read Committed (default) | Dirty reads | Non-repeatable reads, lost updates on read-then-write | Most work |
| Repeatable Read | The above plus non-repeatable reads and phantoms (in PostgreSQL) | Write skew | Reports needing one consistent snapshot |
| Serializable | All anomalies | Nothing; may abort with 40001 | Read-then-write where concurrency causes wrong results |

Read Uncommitted behaves as Read Committed in PostgreSQL.

- Check-then-act (check balance, deduct) under Read Committed loses updates. Fix with a
  conditional `UPDATE ... WHERE balance >= $1`, a version column, `SELECT ... FOR UPDATE`, or
  Serializable.
- At Repeatable Read and Serializable the application **must** retry on SQLSTATE `40001`
  (serialization failure) and `40P01` (deadlock). Wrap the whole transaction in a retry loop
  with backoff; retry the transaction, not the statement.
- Lock rows in a consistent order (for example by id) to avoid deadlocks.

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts SET balance = balance - $2 WHERE id = $1 AND balance >= $2;
COMMIT;
```

## 4. Connection pooling

- Server side: keep `max_connections` modest (a few hundred at most) and put PgBouncer or
  similar in front if many app instances need connections. Each server connection is a process.
- Throughput peaks at a fairly small number of active connections (the starting point is in the
  skill's Connections section). More connections add contention, not speed.
- Budget: sum of all app pools plus workers plus admin headroom under `max_connections`.

PgBouncer modes:

| Mode | Use when | Breaks |
|---|---|---|
| Transaction (default choice) | Stateless queries | Session `SET`, advisory session locks, `LISTEN`, some prepared statement setups |
| Session | The app relies on session state | Little reuse; close to no pooling |
| Statement | Single-statement autocommit only | Multi-statement transactions |

Client pool settings: checkout timeout, connection recycle age, pre-ping or health check,
and a maximum below the budget above.

## 5. Query investigation

1. Find the expensive queries: `pg_stat_statements` ordered by `total_exec_time`.
2. `EXPLAIN (ANALYZE, BUFFERS)` the query with realistic parameters.
3. Read the plan for:
   - Seq Scan on a large table with a selective filter: missing or unusable index.
   - Estimated rows far from actual rows: stale statistics (`ANALYZE table`) or correlated
     columns (extended statistics).
   - Nested Loop with a huge loop count: missing index on the inner side, or a bad estimate.
   - Sort or Hash spilling to disk: `work_mem` or an index that provides the order.
   - High shared buffer reads: the working set does not fit in memory.
4. Change one thing, run the same EXPLAIN, compare.

`EXPLAIN ANALYZE` executes the statement. Wrap writes in `BEGIN; ... ROLLBACK;`.

## 6. MVCC and vacuum

Readers do not block writers. Each update writes a new row version; vacuum reclaims old ones.

- Long transactions (including `idle in transaction`) stop vacuum from reclaiming anything
  newer than their snapshot. Bloat grows across the whole database.
- Watch `pg_stat_user_tables.n_dead_tup` and `last_autovacuum` on hot tables. Tune autovacuum
  per table (lower scale factor) rather than running manual `VACUUM FULL`, which takes ACCESS
  EXCLUSIVE.
- Transaction id wraparound is a hard stop. Monitor `age(datfrozenxid)` and alert well before
  the limit.

## 7. Partitioning

Consider it when a table reaches tens of millions of rows and queries always filter on one
key, or when old data must be dropped in bulk. Below about 10 million rows the overhead
usually outweighs the benefit.

| Strategy | Key | Use when |
|---|---|---|
| Range | Time | Time series; drop old partitions instead of `DELETE` |
| List | Category | A known set of values that every query filters on |
| Hash | Any | Even spread with no natural range |

```sql
CREATE TABLE events (
  id bigint GENERATED ALWAYS AS IDENTITY,
  kind text NOT NULL,
  created_at timestamptz NOT NULL
) PARTITION BY RANGE (created_at);

CREATE TABLE events_2025_01 PARTITION OF events
  FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

DROP TABLE events_2025_01;   -- removes a month instantly
```

- Every query must filter on the partition key, or it scans all partitions.
- Primary keys and unique constraints must include the partition key.
- Create future partitions ahead of time (`pg_partman` or a scheduled job). An insert with no
  matching partition fails, unless a default partition exists, which then grows unnoticed.
