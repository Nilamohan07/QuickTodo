# QuickTodo

A small to-do app for iPhone and iPad, built with SwiftUI and Core Data.

You can add tasks with a due date, edit them, mark them done with a tap and delete them after a confirmation. A segmented filter switches between All, Active and Completed tasks. Overdue tasks are highlighted in red and completed ones are greyed out and struck through. The app works in both light and dark mode.

## Screenshots

![QuickTodo](https://github.com/user-attachments/assets/746f67ef-6680-44eb-b4a9-82662274aa08)
![Simulator Screenshot - iPad mini (A17 Pro) - 2025-02-09 at 14 38 17](https://github.com/user-attachments/assets/d443e67a-2408-40b7-a373-eeee8599759a)
![Simulator Screenshot - iPad mini (A17 Pro) - 2025-02-09 at 14 38 35](https://github.com/user-attachments/assets/2142cf40-4534-45b4-8a6b-a58ec616dbd7)

## Features

- Due-date reminders. A local notification goes off at 09:00 on the due day, and tapping it opens the task. Reminders are rescheduled when a task changes and cancelled when it's completed or deleted.
- Deep links: `quicktodo://task/new` opens the editor, and `quicktodo://task/<id>` opens a task.
- An "Add Task" action in Shortcuts and Siri, which goes through the same validation and storage as the app.
- Strings live in String Catalogs, including a pluralised "tasks remaining" count.

## Architecture

The app target is a thin shell. Everything else lives in a local Swift package, `Packages/QuickTodoKit`, split into targets:

```
QuickTodo/                   App target: composition root, router, deep links, App Intents
Packages/QuickTodoKit/
├── TodoDomain               TodoItem, TaskFilter, TaskDraft, TodoStore, reminders logic
├── TodoPersistence          Core Data stack and store (the data model ships here)
├── TodoReminders            Local notifications
├── DesignSystem             Tokens, colors, button style, shared components
├── TaskListFeature          List screen and its view model
└── TaskEditorFeature        Add and edit screen
```

- Features depend only on `TodoDomain` and `DesignSystem`. They don't know about Core Data, notifications or each other.
- `TaskListViewModel` is an `@Observable`, `@MainActor` class that talks to a `TodoStore` protocol with async methods.
- `CoreDataTodoStore` does all its work on background contexts and hands back plain `TodoItem` values.
- `AppEnvironment` is the single place dependencies are built. It has live, UI-testing and preview variants.
- Everything builds in Swift 6 language mode with complete concurrency checking.

[ARCHITECTURE.md](ARCHITECTURE.md) covers the module graph, data flow, concurrency model, persistence and testing in more detail. The main decisions are recorded in [docs/adr](docs/adr).

## Tech

- Swift 6, SwiftUI, Observation, async/await
- Core Data
- UserNotifications, App Intents
- Swift Testing and XCTest (UI tests)
- SwiftLint, SwiftFormat, GitHub Actions

## Requirements

- iOS 18.2 or later
- Xcode 26 or later

## Running the app

```bash
git clone https://github.com/Nilamohan07/QuickTodo.git
cd QuickTodo
open QuickTodo.xcodeproj
```

Pick the `QuickTodo` scheme and an iOS simulator or device, then run it with Cmd+R. Xcode resolves the local package on its own.

## Running the tests

In Xcode, press Cmd+U. The scheme uses `QuickTodo.xctestplan`, which runs the app tests, every package test target and the UI tests, with code coverage on. From the command line:

```bash
xcodebuild test \
  -project QuickTodo.xcodeproj \
  -scheme QuickTodo \
  -testPlan QuickTodo \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

UI tests launch the app with `-ui-testing`. That gives them an in-memory store with three known tasks and a fixed date, so they see the same screen on every run.

CI runs the same plan on every push and pull request (`.github/workflows/ci.yml`), plus SwiftLint and SwiftFormat checks.

## License

MIT

## Contact

nilamohan07@outlook.com
