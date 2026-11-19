---
name: rust
description: Use when writing, reviewing or debugging Rust code (a Cargo.toml is present), such as borrow-checker errors, lifetimes, error types with thiserror or anyhow, async Rust and tokio, unsafe code and FFI, panics, clippy warnings or cargo test failures. Not for general security audits across languages (use `security-audit`).
license: MIT
---

# Rust

Version notes: items marked with an edition or Rust version apply from that release. Read
`Cargo.toml` (edition, `rust-version`) before relying on them.

## Start here

1. Read `Cargo.toml`: edition, `rust-version` (MSRV), workspace layout, features, dependencies and their
   versions. Read `Cargo.lock` for the versions actually built.
2. Check for lint configuration (`[lints]` in `Cargo.toml`, `clippy.toml`) and follow it.
3. Note the async runtime, if any (usually tokio) and whether the crate is a library, a binary or both.
4. Check where tests live: unit tests in `#[cfg(test)] mod tests` beside the code, integration tests in
   `tests/`, doc tests in `///` examples.

## Rules that matter most

1. **Check the crate's API for the version in `Cargo.lock`** (docs.rs for that version, or the source in
   the cargo registry) before calling it. Crate APIs change between majors and remembered signatures are
   often from an older release.
2. **No `.unwrap()` on anything that comes from outside the program** (input, files, network, environment,
   user data) in non-test code. Use `?`. `.expect("why this cannot fail")` only for true invariants, and
   the message states the invariant.
3. **Do not `.clone()` to silence the borrow checker.** First ask who should own the data. Restructure:
   borrow for shorter, split the borrow, pass an index or id, or move ownership. Clone when a copy is the
   real meaning, or the data is small and cheap.
4. **Never block an async executor thread.** No `std::thread::sleep`, blocking file or network I/O, or
   long CPU loops in async code. Use the runtime's async APIs, `tokio::task::spawn_blocking` for blocking
   calls, and a thread pool (rayon) for CPU-bound work.
5. **Never hold a lock guard across an `.await`.** With `std::sync::Mutex` it makes the future non-`Send`
   or deadlocks; with any lock it serialises unrelated work. Copy what you need out, drop the guard, then
   await. Use `tokio::sync::Mutex` only when the lock must be held across an await.
6. **Every `unsafe` block has a `// SAFETY:` comment** that names the invariants it relies on and why they
   hold here. Keep unsafe blocks as small as possible, behind a safe API that cannot be misused.

## When not to use

- A security audit or threat model of a system: `security-audit` (this skill's review reference still
  applies to the Rust parts).
- CI pipeline setup: `ci-cd`.
- Test technique in general (what to test, TDD loop): `tdd` and `testing-strategy`.

## Errors

- **Libraries:** a `thiserror` enum per module or domain. Variants carry the data a caller needs to act.
  Never expose `anyhow::Error` or `Box<dyn Error>` in a library's public API: callers cannot match on it.
- **Applications:** `anyhow::Result` with `.context("what was being attempted")` at each layer, so the
  final message reads as a chain of causes.
- Do not wrap and also log the same error. Either handle it (log and continue) or return it.
- `Result` is already `#[must_use]`. Put `#[must_use]` on other functions whose return value is the whole
  point (builders, pure computations), so ignoring it warns.

## Ownership and types

- Parameters: `&str`, `&[T]`, `&Path` over `String`, `Vec<T>`, `PathBuf`. Take ownership (`String`) when the
  function stores the value. Generic `impl AsRef<str>` only where callers really pass several types.
- Structs usually own their data. Add a lifetime parameter to a struct only when it is a short-lived view
  over borrowed data.
- `Rc<RefCell<T>>` or `Arc<Mutex<T>>` spread through a codebase is a design smell. Prefer a single owner
  with message passing, or an arena with indices for graphs.
- Make invalid states unrepresentable: enums over boolean flags, newtypes over bare integers for ids and
  units.
- `as` casts truncate and change sign silently. Use `TryFrom` / `try_into()` when a value may not fit.
- Features must be additive: enabling one never removes an API or changes behaviour for other users.

## Async

- Prefer a bounded channel. An unbounded channel turns a slow consumer into unbounded memory use.
- Put a timeout on every network call (`tokio::time::timeout`).
- `tokio::select!` drops the losing branches' futures. A future that is not cancel-safe (for example a
  partly completed `read_exact` or a hand-written state machine) loses data when dropped. Check each
  branch's documentation for cancel safety, and create long-lived futures outside the loop with
  `tokio::pin!`.
- A dropped `JoinHandle` detaches the task; a panic inside it is only seen if someone awaits the handle.
  Await handles, or use `JoinSet` and check every result.
- Shut down on purpose: a `CancellationToken` (tokio-util) or a broadcast signal, then await the tasks.
- `async fn` in traits is stable (Rust 1.75+) but not usable as `dyn Trait`, and callers cannot require the
  returned future to be `Send` without extra bounds. Check before designing a public async trait.

## Panics are failures in production

A panic reachable from untrusted input is a denial of service. These all panic:
- Indexing a slice, `Vec` or map with an untrusted key or index (`v[i]`). Use `.get(i)`.
- Slicing a `str` at a byte offset that is not a character boundary.
- Integer overflow in debug builds. In release builds it wraps silently instead. Use `checked_*`,
  `saturating_*` or `wrapping_*` deliberately on arithmetic with outside values.
- Division by zero, `.unwrap()` on `None` or `Err`, `RefCell` double borrows.
- Unbounded recursion on nested input (deeply nested JSON in a hand-written parser).

Read `references/review.md` before reviewing unsafe code, FFI, or a crate that parses untrusted input.

## Testing

- `cargo test` runs unit, integration and doc tests. Use `cargo nextest run` if the project uses it.
- Async tests: `#[tokio::test]`. Code that waits on time: `#[tokio::test(start_paused = true)]` (needs
  tokio's `test-util` feature) so timers advance instantly and deterministically. Never real sleeps.
- Property tests (`proptest`) for parsers, encoders and anything with a round trip or an invariant.
- Snapshot tests (`insta`) for large structured output; review every snapshot change.
- Unsafe code: run the tests under Miri (`cargo +nightly miri test`). Lock-free code: `loom`.
- Parsers of untrusted input: a fuzz target (`cargo fuzz`).

## Gotchas

- **Edition 2024 (Rust 1.85+)** changes some defaults: `unsafe_op_in_unsafe_fn` warns, `extern` blocks must
  be `unsafe extern`, and temporaries in `if let` scrutinees drop earlier. Check the edition before
  copying code across crates.
- **`Cargo.lock`:** commit it for binaries. For libraries, commit it when it suits the project; the 2023
  guidance no longer says libraries should not, and `cargo new` stopped ignoring it. If you commit it,
  also test the MSRV and the newest dependency versions in CI when the library promises a range.
- **`impl Trait` in argument position** cannot be named with a turbofish by callers. Use a named generic
  if callers may need to specify the type.
- **`Drop` does not run** on `std::process::exit`, on panic with `panic = "abort"`, or for leaked values.
  Do not rely on it to flush important data.
- **`Mutex` poisoning:** `lock().unwrap()` is the usual convention, since a poisoned lock means another
  thread already panicked. Do not try to recover state from a poisoned lock without a reason.

## Verification

```bash
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test --all-features
cargo deny check    # or cargo audit, whichever the project uses for advisories
```

- [ ] All four commands pass with no new `#[allow(...)]` added to silence them.
- [ ] Each new test was seen to fail with the change reverted.
- [ ] No new `unwrap()`, unchecked index or unchecked arithmetic on outside input in non-test code.
- [ ] Every new `unsafe` block has a `// SAFETY:` comment, and Miri passes if it can run the tests.
- [ ] Performance claims come with a benchmark (criterion or the project's harness), before and after.
