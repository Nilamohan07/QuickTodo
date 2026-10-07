# 0002: Stay on Core Data

- Status: Accepted
- Date: 2026-10-05

## Context

The app already has users with a Core Data store (`TaskDetailsDataModel.sqlite`). SwiftData is the obvious modern alternative and the model even carries the `usedWithSwiftData` flag.

## Decision

Keep Core Data, behind the `TodoStore` protocol.

- Existing stores open unchanged. The store URL, model name and entity are kept, and a test pins the URL.
- Background writes through `performBackgroundTask` give me a clear, testable concurrency story under Swift 6. SwiftData's `ModelContext` and `@ModelActor` would work, but I'd be trading a known setup for one with fewer escape hatches.
- Nothing above `TodoPersistence` knows which framework is used. Features and intents only see `TodoItem`.

## Consequences

- Migrating to SwiftData later is contained to one module plus a store migration. The protocol and the domain tests don't change.
- I write a little more boilerplate: the managed object subclass and the mapping to `TodoItem`.
