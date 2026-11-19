---
name: go
description: Use when writing, reviewing or debugging Go code (a go.mod is present), such as error wrapping, context and cancellation, goroutines, channels and mutexes, goroutine leaks, data races, interfaces, generics, table-driven tests, fuzzing or benchmarks. Not for general API design across languages (use `api-design`).
license: MIT
---

# Go

Version notes: features marked "Go 1.N+" need `go 1.N` or later in `go.mod`. Several language changes
(loop variables, timers) depend on the `go` line in `go.mod`, not on the installed toolchain. Read it first.

## Start here

1. Read `go.mod`: the `go` version line, module path, dependencies, `tool` directives (Go 1.24+).
2. Look at the layout: `cmd/` for binaries, `internal/` for code no other module may import (enforced by
   the compiler). `pkg/` is a convention some projects use, not a standard. Follow what the repo does.
3. Find the lint setup (`.golangci.yml`, staticcheck config) and the build entry points (Makefile, task
   runner, goreleaser).
4. Follow the existing patterns for errors, logging and dependency wiring before adding new ones.

## Rules that matter most

1. **Handle every error once.** Either return it with context (`fmt.Errorf("load config %s: %w", path,
   err)`) or handle it (log, fall back, count). Never both: logging and returning prints the same failure
   at every layer. Never `_ =` an error without a comment saying why it is safe.
2. **Every goroutine has an owner and an end.** Before writing `go`, know who waits for it and what stops
   it (context cancellation, a closed channel, the input running out). A goroutine blocked for ever on a
   send or receive is a leak that grows with traffic.
3. **`context.Context` is the first parameter of anything that does I/O or may block,** passed down the
   whole call chain. Never stored in a struct. Always `defer cancel()` right after `WithTimeout` or
   `WithCancel`.
4. **Run the race detector** on tests that touch concurrency: `go test -race ./...`. A data race is a bug
   even when the output looks right.
5. **Set timeouts on network clients and servers.** `http.DefaultClient` and a zero `http.Server` have no
   timeouts. Set `Timeout` on the client and `ReadHeaderTimeout` (at least) on the server.
6. **Keep it plain.** Concrete types, small functions, explicit wiring in `main`. Add an interface,
   generics or a framework when a second real use appears, not before.

## When not to use

- HTTP API shape and versioning in general: `api-design`.
- CI pipelines and release automation: `ci-cd`.
- Test technique in general: `tdd` and `testing-strategy`.

## Errors

- Wrap with `%w` only when callers may depend on the cause; `%v` keeps it an internal detail. A wrapped
  error becomes part of your API.
- `errors.Join` (Go 1.20+) to return several errors, for example from cleanup.
- **A typed nil is not a nil error.** A function that returns `*MyErr` typed as `error` returns a non-nil
  interface even when the pointer is nil. Return a literal `nil` on success.

## Concurrency: choose the tool

| Situation | Use |
|---|---|
| Protect shared state (a map, counters, a cache) | `sync.Mutex` / `sync.RWMutex`, kept next to the data it guards |
| A single counter or flag | `sync/atomic` types (`atomic.Int64`, `atomic.Bool`, Go 1.19+) |
| Wait for N goroutines, no errors | `sync.WaitGroup`; `wg.Go(f)` in Go 1.25+ removes the misplaced-`Add` bug |
| Wait for N goroutines that can fail, cancel the rest on the first error | `errgroup.WithContext` (golang.org/x/sync) |
| Limit concurrency | `errgroup` with `SetLimit`, or a buffered channel as a semaphore |
| Compute once | `sync.OnceValue` / `sync.OnceFunc` (Go 1.21+) |

A mutex is not a failure to use channels. Shared state guarded by a mutex is usually simpler and faster
than a goroutine that owns it.

## Goroutine leak patterns

Each of these grows with traffic and shows up only as rising memory or goroutine counts:

- **A sender outlives its receiver.** The caller timed out or returned on the first error, and the worker
  blocks for ever sending its result. Give the channel a buffer of one, or `select` on `ctx.Done()` in
  the sender.
- **`range` over a channel nobody closes.** The consumer waits for ever. The sender closes, never the
  receiver; closing twice or sending after close panics.
- **A cancel func never called.** `context.WithCancel` or `WithTimeout` without `defer cancel()` keeps the
  context's resources until the parent ends. `go vet` (lostcancel) catches the obvious cases.
- **A ticker never stopped**, below Go 1.23 (see the version table).
- **An HTTP response body not closed.** The connection and its reader goroutine stay alive. Close after
  the error check, and drain it if you want the connection reused.
- **`wg.Add` inside the goroutine.** `Wait` can return before `Add` runs. Call `Add` before `go`, or use
  `wg.Go` (Go 1.25+); `go vet` in 1.25 flags the bad form.

Test for leaks with `go.uber.org/goleak` (`goleak.VerifyNone(t)` or `VerifyTestMain`) in any package that
starts goroutines.

## Behaviour that depends on the `go` line or the release

| From | Change | Gotcha |
|---|---|---|
| Go 1.21 | The `go` line is a minimum requirement, and the `toolchain` line can make the go command download a newer toolchain | A dependency that raises its `go` line raises yours on `go get` |
| Go 1.22 | Loop variables are per iteration | Modules with an older `go` line still share one variable across iterations, so closures and goroutines see the last value |
| Go 1.22 | `http.ServeMux` patterns take a method and wildcards (`"GET /items/{id}"`, read with `r.PathValue("id")`) | Older `go` lines keep the old matching. Do not copy the new patterns into such a module |
| Go 1.23 | Unreferenced timers and tickers are collected without `Stop`, and timer channels no longer hold a stale value after `Reset` or `Stop` | Older `go` lines need `Stop` on every ticker and a drain before `Reset`; `time.After` in a long loop allocates a timer per iteration |
| Go 1.23 | Range over iterator functions (`iter.Seq`) | A `yield` call after it returned `false` panics. Stop when `yield` returns `false` |
| Go 1.24 | `tool` directives in `go.mod`, `t.Context()`, `b.Loop()`, `os.Root` for directory-confined file access, the `omitzero` JSON tag | Prefer `b.Loop` in new benchmarks: it runs setup once and stops the compiler optimising the body away |
| Go 1.25 | `testing/synctest` is stable; `GOMAXPROCS` follows the container's CPU limit on Linux | Services that set `GOMAXPROCS` by hand, or use a library to read cgroups, may now fight the runtime default |

## Testing

- Code that waits on time or runs goroutines: `testing/synctest` (Go 1.25+) runs it with a fake clock, so
  no real sleeps and no flaky timing.
- `t.Parallel()` cannot be combined with `t.Setenv` in the same test; it panics.
- Parsers and decoders: a fuzz test (`go test -fuzz=FuzzX`). Commit the corpus entries that found bugs
  under `testdata/fuzz/`.
- Benchmarks: compare runs with `benchstat`, never a single run.

## Gotchas

- **`append` may share the backing array.** Two slices made by appending to the same slice can overwrite
  each other. `slices.Clone` before appending to a slice you do not own.
- **Copying a struct copies its mutex.** Pass structs that contain a `sync.Mutex` by pointer; `go vet`
  (copylocks) catches most cases.
- **`http.DefaultClient` and a zero `http.Server` have no timeouts.** See rule 5.
- **JSON into `any` turns every number into `float64`.** Large integer ids lose precision. Decode into
  typed structs, or use `json.Decoder.UseNumber`.
- **`init()` and package-level mutable state** make tests order-dependent and wiring invisible. Build
  dependencies in `main` and pass them in.

## Verification

```bash
gofmt -l .                # must print nothing (or goimports)
go vet ./...
go test -race -count=1 ./...
golangci-lint run         # or staticcheck ./..., whichever the project uses
govulncheck ./...
```

- [ ] All pass. No new `//nolint` without a reason on the same line.
- [ ] Each new test was seen to fail with the change reverted.
- [ ] New goroutines: owner and stop condition named, leak check in the tests.
- [ ] `go.mod` and `go.sum` committed and tidy (`go mod tidy` leaves no diff).
- [ ] Performance claims backed by `benchstat` output, before and after.
