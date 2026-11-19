# Current Swift and SwiftUI APIs

Read this before writing new SwiftUI or Foundation code, and when reviewing code that targets a recent OS.
Most published examples predate these APIs, so they are the ones a model reaches for first. Each row names
the release where the current form arrived. Use the older form only when the deployment target is below it.

## SwiftUI

| Older form | Current form | From |
|---|---|---|
| `ObservableObject` + `@Published` + `@StateObject` / `@ObservedObject` | `@Observable` class, owned with `@State`, bound with `@Bindable` | iOS 17, macOS 14 |
| `@EnvironmentObject` | `.environment(model)` and `@Environment(Model.self)` | iOS 17, macOS 14 |
| `NavigationView` | `NavigationStack` or `NavigationSplitView`, with `navigationDestination(for:)` | iOS 16, macOS 13 |
| `NavigationLink(destination:isActive:)` | value-based `NavigationLink(value:)` and a path | iOS 16, macOS 13 |
| `.navigationBarTitle(_:)` | `.navigationTitle(_:)` | iOS 14 |
| `.foregroundColor(_:)` | `.foregroundStyle(_:)` | iOS 15 (old form soft-deprecated: still compiles, warns in new SDKs) |
| `.cornerRadius(_:)` | `.clipShape(.rect(cornerRadius:))` | iOS 13, back-deployed (needs the Xcode 15 SDK) |
| `.onChange(of:perform:)` with one parameter | `.onChange(of:) { old, new in }` or `{ }` | iOS 17, macOS 14 |
| `.animation(_:)` with no value | `.animation(_:value:)` or `withAnimation` | iOS 15 |
| `.onAppear { Task { ... } }` | `.task { }` or `.task(id:)` (cancelled automatically) | iOS 15 |
| `.tabItem { }` | `Tab("Title", systemImage:) { }` inside `TabView` | iOS 18, macOS 15 |
| `PreviewProvider` struct | `#Preview { }` macro | Xcode 15 |
| `GeometryReader` to read a size for layout | `containerRelativeFrame` (iOS 17), `onGeometryChange` (iOS 16, back-deployed; needs the Xcode 16 SDK), or a `Layout` (iOS 16) | iOS 16 / iOS 17 |
| `UIScreen.main.bounds` | the window scene or geometry from the view hierarchy | flagged iOS 16, deprecated iOS 26 |

## Foundation and concurrency

| Older form | Current form | From |
|---|---|---|
| `DispatchQueue.main.async { }` | `@MainActor` code, or `await MainActor.run { }` | Swift 5.5 |
| completion-handler `URLSession` | `try await URLSession.shared.data(from:)` | iOS 15 |
| `Task.sleep(nanoseconds:)` | `Task.sleep(for: .seconds(1))` | iOS 16, macOS 13 |
| `DateFormatter` / `NumberFormatter` for display | `date.formatted(...)`, `Text(value, format: ...)`, `FormatStyle` | iOS 15 |
| `String(format: "%.2f", x)` for display | `x.formatted(.number.precision(.fractionLength(2)))` | iOS 15 |
| `URL(fileURLWithPath:)`, `appendingPathComponent` | `URL(filePath:)`, `appending(path:)` | iOS 16, macOS 13 |
| Combine for one-shot async work | `async`/`await`; `AsyncSequence` for streams | Swift 5.5 |
| Core Data for new, simple models | SwiftData `@Model` (keep Core Data where it already works or needs features SwiftData lacks) | iOS 17, macOS 14 |
| XCTest `XCTAssertEqual` in new unit tests | Swift Testing `#expect(a == b)` | Xcode 16 |

## Before you replace an older form

- Check the deployment target. An `if #available` branch is worse than the old API if every supported OS
  needs it.
- Migrating `ObservableObject` to `@Observable` changes when views update (per property read, not per
  object). Run the app and check the screens that depend on the model, not only the build.
- Do not mix a migration into a bug fix. Separate commits keep each reviewable.
