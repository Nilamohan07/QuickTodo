# QuickTodo

A small to-do app for iPhone and iPad, built with SwiftUI and Core Data.

You can add tasks with a due date, edit them, mark them done with a tap and delete them after a confirmation. A segmented filter switches between All, Active and Completed tasks. Overdue tasks are highlighted in red and completed ones are greyed out and struck through. The app works in both light and dark mode.

## Screenshots

![Simulator Screenshot - iPad mini (A17 Pro) - 2025-02-09 at 14 38 17](https://github.com/user-attachments/assets/d443e67a-2408-40b7-a373-eeee8599759a)
![Simulator Screenshot - iPad mini (A17 Pro) - 2025-02-09 at 14 38 35](https://github.com/user-attachments/assets/2142cf40-4534-45b4-8a6b-a58ec616dbd7)

## Architecture

The app uses MVVM with a small persistence layer behind a protocol.

```
QuickTodo/
├── App/            App entry point
├── Features/
│   ├── TaskList/   TaskListView, TaskRowView, FloatingAddButton, TaskViewModel
│   └── TaskEditor/ TaskEditorView (add and edit) and TaskDraft
├── Models/         TodoItem and TaskFilter
├── Persistence/    CoreDataManager, TodoStore protocol and its Core Data implementation
├── Shared/         Reusable styles and backgrounds
└── Extensions/
```

- **Views** only render state and forward user actions. They don't talk to Core Data.
- **`TaskViewModel`** is an `@Observable`, `@MainActor` class that holds the task list, the selected filter, the pending delete confirmation and any error to show. It depends on `TodoStore`, which is injected through the initializer.
- **`TodoStore`** is a small protocol (fetch, insert, update, delete). `CoreDataTodoStore` is the real implementation. It maps the `TaskDetails` entity to a plain `TodoItem` value type so nothing above the persistence layer deals with managed objects.
- **`CoreDataManager`** sets up the `NSPersistentContainer`. It can also create an in-memory store, which the tests and SwiftUI previews use.
- Persistence failures are turned into a `TodoStoreError` with a readable message. The list screen shows it in an alert, and the details go to `os.Logger`.

## Tech

- Swift, SwiftUI (`NavigationStack`, Observation, SF Symbol effects)
- Core Data
- XCTest

## Requirements

- iOS 18.2 or later
- Xcode 16 or later (tested with the current Xcode release)

## Running the app

```bash
git clone https://github.com/Nilamohan07/QuickTodo.git
cd QuickTodo
open QuickTodo.xcodeproj
```

Pick the `QuickTodo` scheme and an iOS simulator or device, then run it with Cmd+R.

## Running the tests

In Xcode, press Cmd+U. From the command line:

```bash
xcodebuild test \
  -project QuickTodo.xcodeproj \
  -scheme QuickTodo \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

The tests cover the models, the Core Data store (using an in-memory store) and the view model (using a mock store).

## License

MIT

## Contact

nilamohan07@outlook.com
