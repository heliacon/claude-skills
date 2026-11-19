---
name: database
description: "Use when planning or writing a database migration or schema change: rename a column, add a column or index, change a type, backfill, ALTER TABLE, zero downtime on a large table. Also for SQL queries, ORM models, connection pools and transactions in PostgreSQL, MySQL or SQLite. Load it before touching any table that holds data. Not for service boundaries or which store to use; use `system-design`."
license: MIT
---

# Database

A schema change on a table with data is a production operation, not a code edit. Most
database incidents are a migration that took a lock for longer than anyone expected, or a
deploy where old code met a new schema.

## The rules that matter most

1. **Every schema change is a migration**, in version control, run by the migration tool.
   Never a manual `ALTER TABLE` against a shared environment.
2. **Never edit a migration that has run anywhere** but your own machine. Write a new one.
3. **Migrations must work with the code that is running now and the code about to ship.**
   During a deploy both versions run against one schema. Renames, drops and type changes go
   through expand and contract (below), never in one step.
4. **Know the lock before you run it.** On PostgreSQL most `ALTER TABLE` forms take an ACCESS
   EXCLUSIVE lock, which blocks reads too. Set `lock_timeout` (a few seconds) in every
   migration so a blocked migration fails and retries instead of queueing all traffic behind it.
5. **Large tables are different.** Create indexes concurrently, add constraints as NOT VALID
   then validate, backfill in batches outside the schema transaction. Time it on a
   production-sized copy first.
6. **Constraints live in the database.** NOT NULL, foreign keys, unique and check constraints.
   Application checks race; the database does not.
7. **Measure, do not guess.** `EXPLAIN (ANALYZE, BUFFERS)` before and after any query or index
   change. An index with no measured query behind it is a write cost with no benefit.

## Expand and contract

The safe shape for any change that would break running code:

1. **Expand:** add the new column, table or index. Nullable, or with a constant default. Old
   code ignores it.
2. **Dual write:** ship code that writes both old and new.
3. **Backfill:** copy old to new in batches (see `references/migrations.md`).
4. **Switch reads:** ship code that reads the new field. Verify with a count of mismatches,
   which must be zero.
5. **Stop writing old:** ship code that no longer touches the old field.
6. **Contract:** drop the old column in a later migration, after every running version has
   stopped reading it. With ORMs that select all columns, first tell the ORM to ignore it.

A rename is an add, a copy and a drop. So is a type change. Each step is its own deploy.

## Dangerous operations (PostgreSQL)

| Operation | Risk | Safe version |
|---|---|---|
| `CREATE INDEX` | Blocks writes for the whole build | `CREATE INDEX CONCURRENTLY`, outside a transaction |
| `ADD COLUMN ... DEFAULT <volatile>` (`now()`, `random()`) | Rewrites the table | Add nullable, backfill, then set the default |
| `ALTER COLUMN TYPE` | Usually rewrites the table and its indexes | New column plus expand and contract |
| `SET NOT NULL` | Scans the table under ACCESS EXCLUSIVE | `CHECK (col IS NOT NULL) NOT VALID`, `VALIDATE`, then `SET NOT NULL` (PostgreSQL 12+ skips the scan) |
| `ADD FOREIGN KEY` | Locks both tables while it checks every row | `ADD CONSTRAINT ... NOT VALID`, then `VALIDATE CONSTRAINT` in a separate step |
| `ADD UNIQUE` / `ADD PRIMARY KEY` | Builds an index under a strong lock | `CREATE UNIQUE INDEX CONCURRENTLY`, then `ADD CONSTRAINT ... USING INDEX` |
| `DROP COLUMN` / `RENAME` | Running code still uses it | Expand and contract |
| Large `UPDATE` or `DELETE` | Long locks, replica lag, bloat | Batches by key range with a pause |

MySQL, SQLite and the full detail for each row: read `references/migrations.md` before writing
any migration that touches a table with real data.

## Rollback

- Write the down migration when you write the up, and test both.
- A down migration that drops a column with new data in it is a data-loss migration. Say so
  in the file. For anything destructive, prefer rolling forward with a new fix migration.
- Take a backup or snapshot before any destructive step, and confirm you can restore it.

## Schema design

- **Start from the queries.** List the queries the feature must serve and their frequency,
  then design tables and indexes for them.
- **Normalise first; denormalise only on a measured read problem**, with a stated mechanism
  that keeps the copy correct.
- **NOT NULL by default.** Null only when "unknown" is a real, distinct value.
- **Primary keys:** `BIGINT GENERATED ALWAYS AS IDENTITY` for single-database tables; UUIDv7
  (time-ordered: `uuidv7()` on PostgreSQL 18+, or generated in the app) when ids are made
  outside the database or exposed publicly. Random UUIDv4 keys fragment B-tree indexes on large
  tables. Never a business value (email, username) as the key.
- **Timestamps:** `created_at` and `updated_at` on mutable tables, `timestamptz`, stored in UTC.
- **Money:** `numeric(precision, scale)` or integer minor units. Never `float` or `real`.
- **Foreign keys** with a deliberate `ON DELETE`: `RESTRICT` by default, `CASCADE` only for
  true children, `SET NULL` only when orphaning is meaningful. Index the referencing column:
  PostgreSQL does not do it for you, and deletes on the parent scan the child without it.
- **Classify every column** when you add it: personal data, financial, operational or public.
  The class decides encryption, retention and whether it may appear in logs.
- **Soft delete** (`deleted_at`) needs a partial unique index (`WHERE deleted_at IS NULL`) or
  uniqueness breaks, and every query must filter it. Decide deliberately; it is not free.

## Indexing

- **Composite order:** columns tested with equality first, then the range column, then the
  sort column. "Most selective first" is a myth for equality predicates; what matters is that
  the leading columns match how the query filters.
- **Partial indexes** for queries that always filter the same way (`WHERE status = 'pending'`).
- **Covering indexes** (`INCLUDE (...)`) when a hot query can then skip the table.
- Every foreign key column indexed, unless measured as never joined or deleted through.
- Check for unused indexes (`pg_stat_user_indexes.idx_scan = 0` over a full business cycle)
  and drop them. Each one slows every write.

## Queries

- **Parameterised always.** String-built SQL is an injection hole even for "internal" values.
- **No N+1.** Eager-load or batch related rows; assert the query count in a test.
- **Bound everything.** Every query a user can trigger has a `LIMIT`.
- **Keyset pagination**, not `OFFSET`, for anything large:
  ```sql
  SELECT * FROM orders
  WHERE (created_at, id) < ($1, $2)        -- values from the last row of the previous page
  ORDER BY created_at DESC, id DESC
  LIMIT 20;
  ```
  with an index on `(created_at DESC, id DESC)`. `OFFSET 100000` reads and discards 100,000 rows.
- **`NOT IN (subquery)` returns nothing if the subquery yields one NULL.** Use `NOT EXISTS`.

## Transactions and concurrency

- Read Committed (the PostgreSQL default) is right for most work. It does **not** protect a
  read-then-write. Guard those with a conditional update, a version column,
  `SELECT ... FOR UPDATE`, or Serializable plus a retry loop on SQLSTATE `40001`.
- Keep transactions short and never wait on the network inside one.
- A session left `idle in transaction` holds locks and blocks vacuum. Set
  `idle_in_transaction_session_timeout`.
- Isolation levels in full, pooling, partitioning and vacuum: read `references/postgres.md`.

## Connections

- Always pool. A connection per request exhausts the server; PostgreSQL connections are
  processes with real memory cost.
- Size pools from the server's limit down, not from the app up: (instances x pool size) plus
  admin headroom must stay under `max_connections`. Start the total number of active
  connections near twice the server's CPU cores, then tune by measuring throughput and latency.
- Set a pool checkout timeout, connection recycling and a pre-ping or health check.
- Behind PgBouncer in transaction mode, session state (`SET`, advisory locks, some prepared
  statement modes) does not survive between transactions.

## Start of task

1. Identify the engine and version, the ORM and the migration tool.
2. Read the schema or model files before writing code.
3. Check row counts of every table the change touches. That decides which rules above apply.

## Gotchas

- **A migration that passed on an empty dev database.** Lock and rewrite costs scale with rows.
  Time it on production-sized data.
- **Lock queue pile-up.** A migration waiting for its lock behind one long query makes every
  later query wait behind it. Without `lock_timeout` a two-second migration becomes an outage.
- **`CREATE INDEX CONCURRENTLY` failed.** It leaves an INVALID index that still slows writes.
  Drop it and retry.
- **Transactional migration tools and CONCURRENTLY.** Many tools wrap each migration in a
  transaction, where CONCURRENTLY is an error. Mark that migration as non-transactional.
- **Unique index on dirty data.** Count duplicates first, or the build fails at the end of a
  long run.
- **SQLite foreign keys are off** unless `PRAGMA foreign_keys = ON` runs on every connection.
- **A count from a paged query is the page size.** A total computed from a `LIMIT`ed result is
  bounded by the limit. Count with its own query, or report that it is capped.
- **Timestamps without zone.** `timestamp` stores wall-clock time with no zone; the same value
  means different instants on different servers. Use `timestamptz`.
- **ORM default of `updated_at` in application memory.** Bulk updates bypass it. Use a database
  default or trigger if it must be right.

## Verification

- The migration ran up, down and up again on a copy with production-sized data; time and locks
  recorded.
- `lock_timeout` and, for long steps, `statement_timeout` are set in the migration.
- `EXPLAIN (ANALYZE, BUFFERS)` output before and after for each changed query or index.
- After a backfill, a query counting rows where old and new disagree returns zero.
- A query-count assertion in tests for each list or detail path that loads related rows.
