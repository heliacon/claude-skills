---
name: code-quality
description: "Use when writing or reviewing production code for structure and maintainability: where logic should live, class or function, types, naming, comments, error handling and cleaning up code. Also \"would a staff engineer approve this\". Not for tests (use `tdd` or `testing-strategy`), cross-service architecture (use `system-design`) or security review (use `security-audit`)."
license: MIT
---

# Code quality

## The rules that matter most

1. **Pure domain, thin edges.** Business rules live in pure functions with no I/O. Side effects live in
   a service layer. Handlers only translate.
2. **Make illegal states unrepresentable.** If a value must never be used in some state, put that rule
   in the type, not in a comment or a runtime check someone can skip.
3. **No silent failure.** Every `catch`, fallback and default must either handle the error for real or
   surface it. A swallowed exception turns a crash you would notice into wrong data you will not.
4. **Comment why, not what.** Every threshold, magic number, regex and rejected obvious approach gets
   its reason.
5. **Simplest thing that is correct.** Before adding a layer, ask whether a plainer version does the
   same job.

## Three layers

**Domain (pure).** No framework, database or I/O imports. Plain immutable data in, plain data out. It
should be portable: someone could re-implement it in another language by reading this layer alone.
Location: `domain/` or `core/`.

**Services (orchestration).** Calls the domain. Owns database sessions, files, external APIs and every
side effect.

**Interface (thin).** HTTP handlers, CLI commands, UI event handlers. Validate, call a service, shape the
response. No business logic, no direct database access. A route handler over about 15 lines is doing
something that belongs lower down.

Validation models (Pydantic, Zod, Codable) stay at the interface. Never pass them into the domain.

## Class or function

Use a **class** when state must survive across calls (a session-scoped cache), the thing has identity
(an account, an order) or injection makes testing much cleaner. Use a **function** when the operation is
a transformation with no state between calls. Never wrap a single function in a class. Record the
choice in one line where it is not obvious:

```python
# Class: holds a connection-scoped cache of feature flags. Flag rules are in domain/flags.py.
class FlagResolver: ...
```

## Domain functions

- Pure: same input, same output, no side effects.
- Fully typed, immutable inputs and outputs.
- Invalid input raises with a clear message. Never return `None` to mean "bad input".
- Where the algorithm must be reproduced elsewhere (hashes, ids, money rounding), the docstring is a
  language-independent spec: steps, formats and a worked example, precise enough that another
  implementation gives identical output.

## Types and invariants

- Complete annotations. No bare `Any`. Strict type checking on the domain layer, passing before
  the change is done.
- Prefer types that cannot hold a bad value over checks scattered at call sites: a `NonEmptyList`, a
  `Money` with currency, an enum instead of a status string, a parsed `EmailAddress` instead of `str`.
- When an operation is only valid in some states, make the invalid call impossible to write (a
  different type per state, or a constructor that refuses). An error whose correct handling depends on
  data the code cannot see should refuse, not guess a correction. Put the refusal in the type so every
  caller meets it.
- If a rule cannot be enforced by inspection, find the product requirement behind it and make it a
  required parameter. A caller that must pass the value cannot forget it.

## Guards and assertions

- **Guard** clauses handle expected bad input: return early or raise a validation error.
- **Assertions** catch impossible states, programming errors that must never happen in production.
- Never use one for the other. Assertions can be compiled out; a guard must not be.
- Libraries where they help: `icontract` or `deal` (Python), `debug_assert!` (Rust), `precondition` and
  `assert` (Swift); plain `if` checks in Go.

## Immutability

Domain structures are frozen after creation. Services build new values rather than mutating. The only
mutable objects are ORM instances, and they never leave the service layer. Prefer `const`, `let` and
value types.

## Error handling: the silent-failure hunt

When writing or reviewing, look at every one of these and ask what happens to the error:

- `catch` or `except` blocks: does it log with context and re-raise, or return a real handled result?
  A bare `except: pass` is a defect.
- Fallback values (`or []`, `?? 0`, `.get(key, default)`): would the default be indistinguishable from a
  real value downstream? Then it hides failures.
- Optional chaining that ends in nothing happening.
- Retries that end without telling anyone.
- A status check that treats "not 200" as one outcome. A broken service and a refused request are
  different; demand positive evidence of the state you mean.

## Performance

- Queries filter on indexed columns. Declare indexes in the schema, with a comment naming the query each
  serves.
- No N+1 queries. Join or eager-load.
- List endpoints paginate.
- Bulk writes are one statement, not a loop of single writes.
- Stream large files; do not load them whole.
- Hot paths allocate nothing they can avoid. A render or view body is a hot loop: a dashboard that
  recomputed an aggregate in its render path on every progress tick spent most of each frame there.
  Compute once when the input changes, then reuse.
- Measure before and after. Profile the parts, not the function the slow surface is named after: the cost
  is often in a helper it calls, multiplied by the number of call sites.

## Naming

| What | Convention | Example |
|---|---|---|
| Functions | verb_noun | `compute_hash`, `apply_rules` |
| Classes | Noun | `FlagResolver`, `StatusCalculator` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |
| Files | snake_case (or the language norm) | `flag_resolver.py` |

Follow the language's own conventions where they differ (lowerCamelCase functions in Swift, Go and
JS). One word, one meaning across the codebase.

## Comments

Required for: every threshold and magic number, every algorithm choice, every regex (what it matches and
why), every non-obvious transformation, every place the obvious approach was rejected.

```python
# Minimum similarity to auto-link duplicate support tickets without asking an agent.
# Set high because short subjects ("help", "login issue") produce confident false matches.
AUTO_LINK_THRESHOLD = 0.85
```

A comment that restates the code ("loop through records") is noise. Delete it.

## Simplifying and cleaning up

- **Chesterton's fence.** Before deleting code that looks pointless, find out why it is there (blame,
  the linked ticket, the test that covers it). Remove it once you know.
- **Dead code** goes, not commented out. Version control remembers it.
- **Size the change.** A diff a reviewer cannot hold in their head gets a weaker review. Split
  refactors from behaviour changes.
- **Deep modules over shallow ones.** A good module hides a lot of behaviour behind a small interface.
  A wrapper whose interface is as large as what it wraps adds a layer and hides nothing.
- **Condition on the state, never an allowlist.** A rule like "skip these named controls" breaks the
  moment someone adds a control. Key the rule on the property that makes them different.

## Gotchas

- **Two paths, one name.** Two code paths can share a function or feature name and behave in opposite
  ways. Find every entry point before describing what "the" function does.
- **Merging two paths.** When unifying two code paths, check the ambiguous inputs on their own. A value
  such as "unsigned" or "empty" can mean different things on each side, and the merged default silently
  picks one. List the cases; do not argue them.
- **Slices keep their parent's indices** in some languages (Swift `ArraySlice`). Indexing a slice from 0
  when its `startIndex` is above 0 traps or reads the wrong elements, and mixing `count` with
  `startIndex`-based indices skips elements. Iterate `slice.indices`, or rebase with `Array(slice)`.
- **A guess must not act with authority.** A value inferred by a heuristic (a guessed type, a default
  tenant) must not disable a safety check. Where nobody can confirm the guess, use the strictest
  default.

## Reviewing

Read the tests first: they say what the author believed the code must do, and gaps there predict gaps in
the code. Then review on five axes: correctness, readability, architecture fit, security and
performance. Rank findings Critical, High, Medium, Low; fix Critical and High before merge.

## Verification

Before marking work done:

- [ ] Type checker strict on the domain layer passes; linter clean. Paste the command and its result.
- [ ] Every `catch`, fallback and default in the diff has been looked at and justified.
- [ ] Would a staff engineer approve it unchanged? Is there a simpler way? Does it add a failure mode?
      Would a newcomer understand it in five minutes? Any "no" gets fixed first.
