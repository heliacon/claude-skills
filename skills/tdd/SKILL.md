---
name: tdd
description: "Use whenever a bug is to be fixed or a behaviour added test-first: TDD, red-green-refactor, \"write the test first\", \"reproduce it in a failing test\", or any request to fix a bug that should stay fixed. Load it before writing the test, even when the steps seem obvious. Not for judging a whole suite (use `testing-strategy`), test plans (use `quality-assurance`) or user acceptance (use `uat`)."
license: MIT
---

# Test-driven development

## The rule

No production behaviour without a failing test that asks for it. Write the test, run it, watch it fail
for the right reason, then write the least code that makes it pass. This is a discipline, not a
preference: a test written after the code is shaped by the code, so it confirms what the code does
instead of what it should do.

If code already exists without its test, set it aside and drive it again from a test. Do not keep it
open "as a reference" while writing the test: the test will be written to fit it.

## The cycle (one behaviour per cycle)

1. **Red.** Write one test for the next behaviour. Run it. It must fail, and the failure must be an
   assertion about the missing behaviour. An import error, a typo or a broken fixture is not red, it
   is a broken test. A test that passes on its first run proves nothing: either the behaviour already
   exists or the test cannot fail. Find out which before going on.
2. **Green.** Write the minimum code that passes. A hard-coded return is fine if the next test will
   force the general case.
3. **Run the affected suite.** Everything green, not only the new test.
4. **Refactor** with the tests green. No new behaviour during refactor. If refactor needs a new
   test, that is a new cycle.
5. **Commit** at green.

Work in vertical slices: one test, then its code, then the next test. Do not write a batch of tests
for an imagined design and then implement them all. A batch of red tests tells you nothing about which
step broke, and the tests were designed against code that did not exist yet. Make the first test a
tracer through every layer the feature touches, then widen.

If a test is hard to write, the design is telling you something: too many dependencies, hidden
state or a unit doing two jobs. Simplify the design rather than the test.

## Before the first test: agree the seams

For anything beyond a small change, list the seams where tests will attach (public functions,
endpoints, CLI commands, message handlers). For each, write one line on what a test there catches and
what it misses. If the design is still open, agree the seams with the user before writing tests.

Test through public interfaces. A test coupled to private helpers breaks on every refactor and protects
no behaviour a caller can see.

## Bug fixes: prove it first

1. File any non-trivial defect in your tracker before writing the fix, so the reasoning lives in the
   ticket and not only in a commit message. A trivial fix can be explained in the commit. Adapt this
   to your project's conventions.
2. Write a test that reproduces the bug at the lowest level that can show it. Run it. It must FAIL on
   the current code, with a failure that matches the reported symptom.
3. Fix the code. The test passes.
4. **Calibrate the test against the broken build.** Revert or stash the fix, run the test, require
   FAIL, restore the fix. A regression test that also passes on the broken code guards nothing.
5. Treat the reported instance as a sample. Search the codebase for the same shape (same call, same
   pattern, same borrowed type) and fix or record every other instance.

A ticket's stated root cause is a claim. Reproduce the mechanism yourself before building the fix on it.

## What every test must hold

- **A name that reads as a sentence:** `test_<unit>_<behaviour>_<condition>`, for example
  `test_password_at_min_length_is_accepted`.
- **Arrange, act, assert,** one behaviour per test.
- **An independent expected value.** It comes from a hand-worked example, the spec or a trusted
  reference. Never compute it with the same formula, helper or constant the code uses: that test
  agrees with the code by construction (a tautology) and passes when both are wrong.
- **Literals, not the production constant.** `assert retries == 3`, not `assert retries == MAX_RETRIES`.
  If the bug is in the constant, a bound read from the constant moves with the bug.
- **An assertion that matches the name.** A test named "within 0.3%" must assert 0.003, not 0.01.
  Read the operator too: `x < eps` passes on a large negative error, so write `abs(x) < eps`.
- **Isolation.** No test reads state another test wrote. Order must not matter.
- **Determinism.** Inject the clock, seed randomness, no real network. An injected clock must reach
  every write, not only the decision that reads it. Pin it to a value that cannot coincide with the
  real date (years away), or the suite will go red on some calendar day with no code change.

## Required cases

**Every domain function:** happy path; boundaries (0, negative, maximum, empty, one, many); invalid
input raises with a clear message; determinism (same input twice gives the same output); every edge
case the function's spec documents.

**Every call to an external dependency** (HTTP, database, queue, model API): at least one error-path
test. Cover timeout, service unavailable and malformed response. A function that calls out and has no
error-path test is incomplete.

## Test doubles

- Use a real database for the database layer (in-memory or a throwaway container). Mocked queries
  test the mock.
- Mock external services at a boundary you own: wrap the SDK in a thin adapter and fake the adapter.
- A fake must return canned data. A fake that recomputes the logic under test cannot fail, because
  it agrees with the code by construction.
- Never assert only that a mock was called. Assert on the outcome a caller can observe.
- Python: never stub modules at import time in `sys.modules` from a test file. The stub leaks into
  every test collected after it. Use `monkeypatch` or a fixture scoped to the test.

## Fixtures

- Fake data only. Never real user data, real names or real credentials. State this in
  CONTRIBUTING.md.
- Keep fixture files in `tests/fixtures/`, with the real column structure of their source.
- Values must look realistic but be obviously fake: "Example Customer B", example.com addresses, one
  consistent fake date range.

## Traceability IDs (when tests trace to a written spec)

When a spec lists numbered requirements, give each test an ID of the form `[MODULE]-[TYPE]-[NN]`
(`AUTH-DOMAIN-01`, `EXPORT-03`) as the first comment in the test body. The comment is the canonical
link even if the name repeats it. Skip this when there is no spec to trace to.

## Rationalisations

| Excuse | Reality |
|---|---|
| "Too simple to need a test." | Simple code breaks too, and its test takes a minute. |
| "I'll add tests after." | Tests written after pass by construction. They describe the code, not the requirement. |
| "I tested it by hand." | A manual check cannot be re-run by the next change. |
| "It passed first time, good." | Unseen red. You do not know the test can fail. |
| "The deadline is tight, just this once." | The regression it lets through costs more than the test. |
| "This test is too hard to write." | That is design feedback. Fix the design. |
| "I'll keep the old code and adapt it." | Then the tests will be written to fit it. Drive it again from a test. |

## Red flags

- A test nobody has seen fail.
- A behaviour change in a commit with no test change.
- A skip or expected-failure marker with no reason.
- Expected values pasted from running the code (that snapshots the bug).
- A test whose only assertion is on a mock call.
- A green unit test for code nothing calls. Check the entry point (router registration, command
  table, event wiring) actually reaches it. A green test never proves that anything calls the code.

## Gotchas

- **In-memory SQLite with FastAPI's TestClient:** use `poolclass=StaticPool` and
  `connect_args={"check_same_thread": False}`. The client runs handlers in another thread; the default
  pool opens a new connection there, which sees an empty database. Same-thread session tests pass and
  hide it until the HTTP tests fail with "no such table".
- **Playwright `to_have_class`** takes a string or a regex, never a callable. To check membership, read
  `get_attribute("class")` and assert the class name is in it.
- **A test covers the step it names.** A picker test can pass every case while the file it picked is
  discarded one step later. Assert on the final effect the user depends on, not the intermediate value.
- **Unstable ordering.** Sorting or iterating over a hash-ordered collection can change between
  processes. Before trusting a before/after output diff, run the "before" side twice: if it differs from
  itself, the diff is noise.

## What not to test

Framework plumbing, third-party library internals, trivial accessors with no logic, generated code.
Test the logic you wrote and the way you call the libraries.

## Deeper technique

Property-based, mutation, snapshot and contract testing, and judging whether a suite is complete, are in
the `testing-strategy` skill. Design-by-contract guards and assertions in production code are in the
`code-quality` skill.

## Verification

Before calling the work done, show evidence, not prose:

- [ ] For each new test: the red output (the failing assertion line) and then the green output.
- [ ] For each bug fix: the test failing with the fix reverted, then passing with it restored.
- [ ] A fresh run of the full affected suite, green, with the command used.
- [ ] The entry point that calls the new code, named (file and line).
