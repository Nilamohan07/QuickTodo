# 0001: Split the app into local Swift package targets

- Status: Accepted
- Date: 2026-10-05

## Context

Everything lived in the app target, separated only by folders. Nothing stopped a view from importing Core Data or a feature from reaching into another feature. Previews and tests built the whole app.

## Decision

Move shared code into one local package, `Packages/QuickTodoKit`, with these targets: `TodoDomain`, `TodoPersistence`, `TodoReminders`, `DesignSystem`, `TaskListFeature` and `TaskEditorFeature`. Each target that has real logic gets its own test target. The app target keeps only the composition root, navigation and App Intents.

I chose one package with several targets over one package per module. Target boundaries already give me compiler-enforced `internal`, and a single manifest is easier to keep consistent.

## Consequences

- Dependency direction is checked by the compiler: features depend on `TodoDomain` and `DesignSystem`, never on each other or on Core Data.
- Package test targets run from the same test plan as the app tests.
- Modules that show text need their own String Catalog and `bundle: .module`.
- Splitting into separate packages later is mechanical if a module ever needs its own versioning.
