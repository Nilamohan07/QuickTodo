# 0003: Use Observation and async/await, not Combine

- Status: Accepted
- Date: 2026-10-05

## Context

The view model needs to publish state to SwiftUI and call an asynchronous store. The two realistic options are `ObservableObject` with Combine publishers, or the Observation framework with async/await.

## Decision

Use `@Observable` view models isolated to the main actor, with `async` store calls.

- Observation tracks only the properties a view reads, so a change to `presentedError` doesn't re-render rows.
- `async` functions are easier to test than publisher chains. Tests simply `await viewModel.save(draft)` and assert.
- Swift 6 strict concurrency understands actors and `Sendable`. Combine pipelines would need extra annotations to get the same guarantees.

## Consequences

- iOS 17 is the minimum for Observation. The app already targets iOS 18.2.
- There's no stream of store changes yet. The view model reloads after writes and when the scene becomes active. If the app needs live updates from other processes, an `AsyncSequence` on the store is the natural next step.
