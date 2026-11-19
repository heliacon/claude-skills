---
name: testing-strategy
description: "Use when judging whether a suite tests the right things: finding test gaps, coverage targets, the test pyramid, which level to test at, property-based, mutation, snapshot or contract testing. Also \"are these tests any good\". Not for writing a test first (use `tdd`), test plans, defect triage or release exit (use `quality-assurance`) or user acceptance (use `uat`)."
license: MIT
---

# Testing strategy

A passing suite proves the tested paths work. It says nothing about the paths it never reached, and
nothing at all if its tests cannot fail. This skill answers two questions: **are the right things
tested**, and **would these tests fail if the code were wrong**?

## Method: auditing a suite or component

1. **Tier the risk** of each area (table below). Depth follows the tier, not the line count.
2. **Check completeness** against the matrix for the component type. Read
   `references/completeness-matrix.md` when auditing a backend, frontend, database or domain layer. It also
   holds the accessibility checklist for UI.
3. **Check the tests can fail** (mutation testing or manual calibration, below).
4. **Check reachability.** Tests must enter where real callers enter: the route, the command, the event
   handler. A green test on a function nothing calls is not coverage of a feature.
5. **Report** each area as PASS, PARTIAL or FAIL, with each gap named as a missing behaviour
   ("no test for refund when the card is expired"), not a percentage.

A missing required category makes the area PARTIAL, never PASS.

## Risk tiers

| Tier | Criteria | Required depth |
|---|---|---|
| Critical | Data mutation, money, auth, core domain calculations, migrations, anything irreversible | Every matrix category, plus property or mutation testing on the domain core |
| Supporting | Orchestration, API handlers, background jobs | Happy path, error paths, boundaries |
| Utility | Config loaders, formatters, small helpers | Happy path and one error case |

Skip deep testing for generated code, framework plumbing and accessors with no logic.

## Choosing the level

Use the pyramid as a smell check, not a quota. Roughly 70% unit, 20% integration, 10% end-to-end.
Flag these shapes:

- More end-to-end than integration tests: slow, brittle, failures hard to locate.
- No integration tests: every boundary is mocked, so integration faults are invisible.
- Unit tests that mock every collaborator: unit tests in name only.

When people argue about what "unit" means, classify by resource use instead. **Small:** one process,
no I/O, no sleep. **Medium:** one machine, may use a local database or filesystem. **Large:** may cross
machines or the network. Push each test to the smallest size that can show the behaviour.

**Tiered suites.** Run a fast core on every edit, a broader tier on every commit and the full suite
before a merge or release. Write down what each tier never reaches. A fast tier is a sample of the
harness: it can stay green while defects and resource exhaustion that only the full run reaches go
unseen. Changes in an area the fast tier skips need the full tier before anyone says "done".

## Coverage

Suggested starting thresholds on new code; set your own to suit the project:

| Metric | Threshold on new code |
|---|---|
| Line | 80% |
| Branch | 75% (every arm of every conditional) |
| Function | 90% (every exported function called) |

Report the actual figure next to the threshold: `lines: 73% (threshold 80%)`. Below threshold means
flag and do not auto-approve.

Coverage measures execution, not verification. A line can run under a test that asserts nothing about
it. Judge a suite by its behaviour gaps first and its percentage second.

## Can the tests fail?

**Mutation testing.** The tool makes small changes (flip `>` to `>=`, delete a statement, swap a
constant) and reruns the suite. A surviving mutant marks code that tests execute without checking.
Run it on the critical domain layer; aim for a mutation score above 80% there. It is slow, so run it
periodically or on changed files, not on every commit. Some survivors are **equivalent mutants**: the
change has no observable effect. Mark them and move on; do not write tests to kill them.
Tools: `mutmut` (Python), Stryker (JS/TS, C#), `cargo-mutants` (Rust), `go-mutesting` (Go).

**Manual calibration** when no tool fits. Break the code the way the test claims to guard against
(revert the fix, invert the comparison, remove the guard). Require red. Then restore. Calibrate against
the defect class you care about: a check that runs and passes can still be inert. A detector that has
fired zero times across a large real dataset may be unable to fire; count its positives before trusting
its silence.

**Read the assertion.** Expected values from an independent source, literals rather than the constant
under test, and `abs(x) < eps` rather than `x < eps`. The `tdd` skill covers these in detail.

## Property-based testing

Use it for pure functions with a wide input space: parsers, serialisers, money and date arithmetic,
sorting and ranking, state machines. Skip it for UI and side-effect-heavy paths.

Properties worth looking for:

- **Round trip:** `decode(encode(x)) == x`.
- **Invariant:** output length, sum, ordering or bounds always hold (`tax <= gross`).
- **Idempotence:** `f(f(x)) == f(x)` (normalise, deduplicate, sort).
- **Oracle:** compare with a slow, obviously correct reference implementation.
- **Metamorphic:** a known relation between outputs of related inputs (doubling every price doubles the
  total).
- **Commutativity or order independence** where the domain promises it.

Two ways a property test asserts nothing:

- **Tautology.** The property restates the implementation, so it holds for any bug the two share.
- **Vacuity.** A filter or `assume()` rejects most generated inputs, so the property is checked on a few
  trivial cases. Read the generator statistics. Build constraints into the generator instead of
  filtering afterwards.

When a property fails, copy the shrunk counterexample into an ordinary example test so it stays as a
regression. Tools: Hypothesis (Python), fast-check (JS/TS), proptest (Rust), rapid (Go),
swift-testing parameterised tests or SwiftCheck (Swift).

## Snapshot and golden-file tests

Good for the shape of large outputs (reports, rendered HTML, CLI output, API payloads). A snapshot locks
in current behaviour, bugs included, so it proves stability, not correctness. Review every snapshot diff
line by line. Never bulk-update snapshots to make a run green.

## Contract tests

- One service with a published schema: generate requests from the schema and check responses
  against it (Schemathesis for OpenAPI).
- Several services sharing an API: consumer-driven contracts (Pact), so the provider's build fails when
  it breaks a consumer.

## Mocking strategy

Mock at boundaries you own, use real infrastructure for the layer under test. A real database for
repository tests. A thin adapter around each third-party SDK, faked in unit tests and exercised for real
in a small number of integration tests. A fake must return canned data; a fake that reimplements the
logic cannot disagree with it.

## Resilience checklist (every external call)

- [ ] Timeout: handled, not hung.
- [ ] Service unavailable (5xx, connection refused): fallback or a propagated error.
- [ ] Partial or truncated response: an error, not silent corruption.
- [ ] Schema mismatch: a validation error, not silently wrong state.
- [ ] Retry: idempotent, no double writes.

An external call with no error-path test makes the area PARTIAL.

## Test design techniques

Pick the technique from the shape of the input. Do not just add more examples.

| Technique | Use when | Gives you |
|---|---|---|
| Equivalence partitioning | Inputs fall into classes that behave alike | One case per class, no redundant cases |
| Boundary value analysis | Ranges, limits, off-by-one risk | min-1, min, min+1, max-1, max, max+1, zero |
| Decision table | Output depends on a combination of conditions | Every combination mapped to its expected action |
| State transition | Workflows and lifecycles | Valid transitions pass; every invalid one is refused, not silently allowed |
| Pairwise | Many independent parameters | All pairs covered at a fraction of the full product |
| Error guessing | Experience says an input breaks things | Null, empty, huge, Unicode, negative dates, leap days, time zones |

Every range gets boundary analysis. Every collection gets empty, one and many.

## Test hygiene gates

Each of these blocks APPROVED status:

| Gate | Rule |
|---|---|
| Empty assertions | No test without an assertion on observable behaviour |
| Leftovers | No `TODO`, `FIXME` or bare `pass` in test code |
| Skips | Every skip carries a reason; mass skipping blocks approval |
| Isolation | No test depends on state another test wrote |
| Magic numbers | Unexplained literals in assertions get a name or a comment |
| Complexity | No new production function with cyclomatic complexity over 15 |

## Gotchas

- **A defaulted flag hides a mode.** If a harness option has a default and no caller ever overrides it,
  the other mode has never been tested. Grep the call sites, not the definition.
- **Fixing reachability exposes untested code.** When a feature that was unreachable becomes reachable,
  expect defects behind it: it has never run for real.
- **Tests that pass because of the mock.** If every test of a module goes through the same fake, the
  suite measures the fake.
- **An unrun check is not evidence.** A test or probe with no recorded output has never passed. Find
  the run, not the definition.

## Performance targets

Load testing usually sits outside CI, but targets must exist before approval. Read
`references/performance-baseline.md` when an external-facing endpoint or job has no recorded target.

## Verification

The output of an audit is a table, one row per area:

| Area | Tier | Missing categories | Can-fail check | Coverage (actual / threshold) | Verdict |
|---|---|---|---|---|---|

Every PARTIAL or FAIL names the missing behaviour and the test that would close it.
