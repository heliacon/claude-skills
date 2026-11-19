# Safe migrations in detail

Read this before writing any migration that touches a table with real data, and before any
backfill.

## Contents

1. Pre-flight checklist
2. PostgreSQL lock levels that matter
3. Recipes (PostgreSQL)
4. Backfills
5. Deploy ordering
6. MySQL
7. SQLite
8. Enum and type changes
9. Rollback and data loss

## 1. Pre-flight checklist

- [ ] Row count and size of every table touched (`SELECT pg_size_pretty(pg_total_relation_size('t'))`).
- [ ] Which lock each statement takes, and for how long (section 2).
- [ ] Does the running code still work after this migration? Does the new code work before it?
- [ ] `lock_timeout` set (2 to 5 seconds). Long steps have their own `statement_timeout`.
- [ ] Timed on a production-sized copy. Record the time in the migration file.
- [ ] Long-running queries and open transactions checked just before running
      (`pg_stat_activity` where `state <> 'idle'` and `xact_start` is old).
- [ ] Backup or snapshot taken and restore tested, for any destructive step.
- [ ] Down migration written and tested, or the file states it is irreversible and why.

## 2. PostgreSQL lock levels that matter

| Lock | Blocks | Taken by |
|---|---|---|
| ACCESS EXCLUSIVE | Everything, including `SELECT` | Most `ALTER TABLE` forms, `DROP`, `TRUNCATE`, `VACUUM FULL`, `REINDEX` (non-concurrent) |
| SHARE ROW EXCLUSIVE | Writes and other schema changes | `ADD FOREIGN KEY` (on both tables), `CREATE TRIGGER` |
| SHARE | Writes | `CREATE INDEX` (non-concurrent) |
| SHARE UPDATE EXCLUSIVE | Other schema changes and vacuum, not reads or writes | `CREATE INDEX CONCURRENTLY`, `VALIDATE CONSTRAINT`, `ANALYZE` |

**The queue effect.** Locks are granted in order. An ALTER waiting for ACCESS EXCLUSIVE behind
a 10-minute report blocks every query that arrives after it, even plain reads. This is why
`lock_timeout` is mandatory: the migration should give up and retry, not hold the queue.

```sql
SET lock_timeout = '3s';
SET statement_timeout = '15min';   -- for the long, low-lock steps only
```

Retry a lock-timeout failure a few times with a pause. Run during low traffic if it keeps
failing.

## 3. Recipes (PostgreSQL)

**Add a column.** Nullable or with a constant default is instant (PostgreSQL 11+). A volatile
default rewrites the table.
```sql
ALTER TABLE orders ADD COLUMN coupon_code text;            -- instant
ALTER TABLE orders ADD COLUMN source text DEFAULT 'web';   -- instant, constant default
```

**Add an index.** Outside a transaction block.
```sql
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_coupon
  ON orders (coupon_code) WHERE coupon_code IS NOT NULL;
-- on failure: DROP INDEX CONCURRENTLY idx_orders_coupon; then retry
```
Check `pg_index.indisvalid` afterwards. An invalid index is maintained on writes but never used.

**Make a column NOT NULL.**
```sql
ALTER TABLE orders ADD CONSTRAINT orders_source_nn CHECK (source IS NOT NULL) NOT VALID;
ALTER TABLE orders VALIDATE CONSTRAINT orders_source_nn;      -- scans, low lock
ALTER TABLE orders ALTER COLUMN source SET NOT NULL;          -- uses the check, no scan (12+)
ALTER TABLE orders DROP CONSTRAINT orders_source_nn;
```

**Add a foreign key.**
```sql
ALTER TABLE orders ADD CONSTRAINT orders_customer_fk
  FOREIGN KEY (customer_id) REFERENCES customers (id) NOT VALID;   -- brief lock
ALTER TABLE orders VALIDATE CONSTRAINT orders_customer_fk;          -- separate migration
```
Index `orders.customer_id` first (concurrently).

**Add a unique constraint.**
```sql
SELECT email, count(*) FROM users GROUP BY email HAVING count(*) > 1;  -- must be empty
CREATE UNIQUE INDEX CONCURRENTLY users_email_key ON users (email);
ALTER TABLE users ADD CONSTRAINT users_email_key UNIQUE USING INDEX users_email_key;
```

**Rename a column or table.** Expand and contract: add new, dual write, backfill, switch reads,
stop writing old, drop old. For a table, a view with the old name can bridge one release.

**Change a column type.** Some changes are metadata only (widening `varchar(n)` or converting
`varchar` to `text`). Almost everything else rewrites: use a new column and expand and contract.

**Drop a column.** First ship code that no longer reads or writes it (and tell the ORM to
ignore it). Drop in a later release. The drop itself is fast; the danger is running code.

## 4. Backfills

- Not inside the schema migration. Run as a separate, resumable job or script.
- Batch by primary key range, not `OFFSET`:
  ```sql
  UPDATE orders SET source = 'web'
  WHERE id > $last_id AND id <= $last_id + 5000 AND source IS NULL;
  ```
  Commit each batch. Record progress so a restart resumes.
- Idempotent: the `WHERE ... IS NULL` (or equivalent) means a rerun changes nothing twice.
- Throttle: pause between batches and watch replica lag; stop if it grows.
- Size batches by time (each well under a second), not by a fixed number chosen in advance.
- New rows written during the backfill must already be handled by the dual-write code.
- Finish with a check that must return zero:
  `SELECT count(*) FROM orders WHERE source IS NULL;`
- Deleting in bulk follows the same pattern. For time-series data, partition and drop old
  partitions instead.

## 5. Deploy ordering

| Change | Order |
|---|---|
| Add column, table or index | Migrate, then deploy code that uses it |
| Remove column or table | Deploy code that stops using it, then migrate |
| Add NOT NULL or a constraint | Deploy code that always writes valid values, backfill, then migrate |
| Rename or retype | Expand and contract across several deploys |

Rolling deploys and blue-green both mean old and new code run at once. A migration that only
works with the new code breaks the old instances still serving traffic.

## 6. MySQL

- InnoDB online DDL: request `ALGORITHM=INSTANT` first, then `ALGORITHM=INPLACE, LOCK=NONE`.
  Stating them makes MySQL refuse rather than silently fall back to a copying, locking change.
- Even INPLACE operations take a brief metadata lock at start and end, and queue behind long
  transactions the same way as in PostgreSQL. Set `lock_wait_timeout` low.
- For large tables where online DDL is not available, use an online schema change tool
  (gh-ost or pt-online-schema-change) that copies to a shadow table and swaps.
- DDL is not transactional in MySQL. A failed multi-statement migration leaves the schema half
  changed. One DDL statement per migration.

## 7. SQLite

- `ALTER TABLE` supports add column, rename column, rename table and drop column (3.35+) only.
  Anything else needs the documented table-rebuild procedure: create the new table, copy, drop
  the old one, rename, recreate indexes, triggers and views.
- During a rebuild, turn foreign keys off (`PRAGMA foreign_keys = OFF`, which cannot be changed
  inside a transaction), do the rebuild in a transaction, run `PRAGMA foreign_key_check`, then
  turn them back on.
- `PRAGMA foreign_keys = ON` is per connection and off by default. Set it on every connection.
- Use WAL mode (`PRAGMA journal_mode = WAL`) for concurrent readers with one writer.

## 8. Enum and type changes

- PostgreSQL `ALTER TYPE ... ADD VALUE` is cheap, but the new value cannot be used in the same
  transaction that adds it. Removing or renaming a value needs a new type and a column swap.
- A text column with a `CHECK (status IN (...))` constraint is easier to evolve than a native
  enum: replace the constraint with `NOT VALID` then `VALIDATE`.
- Adding an enum value is also an API change if clients see it (the `api-design` skill).

## 9. Rollback and data loss

- A down migration that drops a column added by the up migration destroys any data written to
  it since. Mark such files clearly.
- Prefer roll-forward: a new migration that fixes the problem, with the old schema still
  intact thanks to expand and contract.
- Never run a destructive migration without a tested restore path.
- The real rollback plan for code is to redeploy the previous version. That only works if the
  schema still supports it, which is the whole point of expand and contract.
