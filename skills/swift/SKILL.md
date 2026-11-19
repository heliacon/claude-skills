---
name: swift
description: Use when writing, reviewing or debugging Swift code (Package.swift or an Xcode project), such as SwiftUI views, async/await, actors, Sendable or data-race errors, Swift Testing or XCTest, SwiftData or macOS and iOS app hangs. Not for cross-platform mobile process, store release or React Native (use `mobile`).
license: MIT
---

# Swift

Version notes: rules marked with a version apply from that Swift or OS release. Read the project's
`swift-tools-version`, language mode and deployment targets before using any of them.

## Start here

1. Read `Package.swift` or the Xcode project: tools version, Swift language mode (5 or 6), platforms and
   deployment targets, targets, dependencies.
2. Note the UI layer (SwiftUI, UIKit, AppKit or a mix) and the test framework (Swift Testing `@Test`,
   XCTest or both).
3. Check concurrency settings: language mode 6 or strict concurrency checking, and (Swift 6.2+) whether the
   module defaults to main-actor isolation. They change what the compiler accepts.
4. Follow the patterns already in the code before introducing new ones.

## Rules that matter most

1. **Fix data-race diagnostics, do not silence them.** `@unchecked Sendable`, `nonisolated(unsafe)` and
   `@preconcurrency` turn off the checker. Use one only with a comment that states why the access is safe
   (for example "guarded by `lock`").
2. **Never block inside async code.** No semaphores, `DispatchGroup.wait()` or synchronous waits on the
   cooperative thread pool: a few blocked threads deadlock the whole pool. Bridge callback APIs with
   `withCheckedThrowingContinuation`, and resume exactly once on every path.
3. **A view body is a hot loop.** SwiftUI evaluates `body` far more often than the data changes. Never do
   real work there (sorting, aggregating, formatting thousands of rows, creating formatters).
4. **No `!` and no `try!` in production code** unless the invariant is local and obvious, and then with a
   comment. Prefer `guard let ... else` with a real failure path.
5. **`try?` discards the error.** Use it only where "failed" and "absent" mean the same thing to the
   caller. Otherwise `do`/`catch` and log or surface the error.
6. **Use the current API, not the one most examples online show.** Read `references/modern-apis.md` before
   writing new SwiftUI or Foundation code, and when reviewing code that targets a recent OS.

## When not to use

- App Store release, device matrix, push, offline sync process: the `mobile` skill.
- React Native or Expo: the `mobile` skill.
- Server API design behind the app: `api-design`.

## Concurrency

- `async`/`await` over completion handlers. `async let` for a fixed number of parallel calls; a task group
  for a dynamic number.
- An `actor` for shared mutable state. `@MainActor` for UI state and anything that touches views.
- **Actor reentrancy:** state can change at every `await` inside an actor method. Re-check conditions after
  each `await`, and do not hold an assumption across one. To avoid duplicate work, store the in-flight
  `Task` and await it from later callers.
- `Task { }` inherits the current actor and priority. `Task.detached` inherits neither: use it rarely, and
  say why.
- **Unstructured tasks are not cancelled for you.** Keep the handle and cancel it when the owner goes
  away. In SwiftUI prefer `.task { }` or `.task(id:)`, which cancel when the view disappears or the id
  changes.
- **Cancellation is cooperative.** Long loops call `try Task.checkCancellation()` or check
  `Task.isCancelled`. A cancelled task that keeps running still holds its resources.
- A `Task` closure captures `self` strongly until the task ends. That is fine for short work. A long or
  infinite loop (observing a stream) needs `[weak self]` inside the loop, or cancellation in the owner's
  teardown.
- `AsyncStream`: call `finish()` on the continuation, and use `onTermination` to tear down the producer.
- Swift 6.2+, both opt-in: with the `NonisolatedNonsendingByDefault` upcoming feature (SE-0461),
  nonisolated async functions run on the caller's actor, and `@concurrent` marks a function that must run
  off it. Default main-actor isolation (SE-0466) is a per-module setting. New app templates in Xcode 26
  turn both on. Check the project's settings before assuming either behaviour.

## SwiftUI

- iOS 17 / macOS 14+: `@Observable` classes. Own one with `@State`, pass it as a plain property, use
  `@Bindable` to make bindings, inject with `.environment(model)` and read with
  `@Environment(Model.self)`. Below those versions: `ObservableObject` with `@Published`,
  `@StateObject` to own and `@ObservedObject` to pass.
- `@State` is initialised once per view identity. A value passed into `init` and copied into `@State` will
  not update when the parent passes a new one.
- **Identity:** `ForEach` needs ids that are stable and unique. `id: \.self` on values that can repeat, or
  indices into a mutable array, gives wrong animations, lost state and crashes.
- Heavy derived data: compute it in the model when inputs change, or memoise on a cheap key of the
  upstream inputs. Deduplicate repeated passes first. Then prove the memo helps by disabling it and
  measuring.
- Large bodies slow the type-checker and can fail to compile ("unable to type-check this expression in
  reasonable time"). Extract subviews and move long `switch` handlers into methods.

## Errors

- `enum` error types per domain, conforming to `LocalizedError` where a message reaches the user.
- Typed throws (`throws(MyError)`, Swift 6+) only for closed, internal domains where the caller handles
  every case. Untyped `throws` stays the default for public API.
- `Result` for stored outcomes. Not as a substitute for `async throws`.

## Testing

- New tests use Swift Testing: `@Test`, `#expect` and `#require` to stop on a failed precondition
  (unwrapping an optional). Use parameterised tests (`arguments:`) instead of loops inside one test.
- Swift Testing runs tests in parallel by default. Tests that share state (a file, a singleton, a defaults
  suite) need isolation or the `.serialized` trait.
- Callback-based code: `confirmation()` in Swift Testing, expectations in XCTest. Never `sleep`.
- XCTest stays for UI tests (XCUITest) and `measure` performance tests. Both frameworks run under
  `swift test` and `xcodebuild test`.
- **Keep test windows out of the way.** If tests run on a machine someone is using, a macOS app under test
  can use an accessory activation policy and place windows off-screen without activating the app, so it
  does not take focus. Layout, Metal drawing and view-tree
  inspection all still work. Launch the app once per run, not per assertion.
- **A snapshot is not evidence of AppKit layout.** `cacheDisplay(in:to:)` renders SwiftUI-hosted AppKit
  controls and Metal layers blank. Assert on the laid-out view tree (frames, titles, zero-size frames)
  instead.

## Gotchas

- **`ArraySlice` keeps the parent's indices.** After `dropFirst()`, indexing from 0 traps or reads the wrong
  element, and `i + 1 < slice.count` skips elements. Iterate `slice.indices` or rebase with `Array(slice)`.
  In a GUI app a skipped branch can fall through to the main loop and look like a hang.
- **A hang in a GUI app: sample the process before adding prints.** `sample <pid>` (macOS) shows where the
  main thread is in seconds. The suspect function may never be called at all.
- **`Calendar.date(bySetting:value:of:)` searches forward.** Setting `.day` to 1 on a mid-April date gives
  1 May. To build "day N of this month", take `dateComponents([.year, .month], from:)`, set `day`, and call
  `date(from:)`.
- **Only one `.fileImporter` and one `.fileExporter` per view work.** Chain several and only the last of
  each kind presents; the others do nothing, with no warning. Use one of each, driven by an enum that
  describes the job.
- **Advancing a queue of sheets by setting the item to `nil` then the next value in one pass presents
  nothing.** Delays make it flaky, not fixed. Keep one sheet presented while items remain and change its
  content.
- **Fixed-format dates** (parsing an API's timestamps) need `Locale(identifier: "en_US_POSIX")` or an
  `ISO8601FormatStyle`. The user's locale and calendar otherwise break parsing on some devices. Do not
  create formatters in a view body or a loop.
- **`pkill -f pattern` can match your own shell** when the pattern appears in the command line that runs
  it. Kill by pid.
- `[weak self]` belongs in escaping closures stored by a class. SwiftUI view structs and non-escaping
  closures do not need it.

## Verification

```bash
swift build && swift test            # packages
xcodebuild test -scheme App -destination 'platform=iOS Simulator,name=<device>'   # app targets
```

- [ ] Builds with zero warnings in the project's language mode. No new `@unchecked Sendable`,
      `nonisolated(unsafe)` or `!` without a justifying comment.
- [ ] Tests pass, and each new test was seen to fail with the change reverted.
- [ ] SwiftLint or swift-format, if the project uses one, is clean.
- [ ] UI changes: run the app and look at the result, in light and dark mode and at a large Dynamic Type
      size. Performance claims: Instruments numbers before and after, from a release build.

For a review, report per file: line, the rule broken, why it matters, the fix. Worst first.
