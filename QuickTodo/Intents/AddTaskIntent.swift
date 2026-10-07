//
//  AddTaskIntent.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import AppIntents
import Foundation
import TodoDomain

/// Adds a task from Shortcuts, Siri or Spotlight. It goes through the same draft validation
/// and store as the editor, so reminders are scheduled the same way.
struct AddTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Task"
    static let description = IntentDescription("Adds a new task to QuickTodo.")

    @Parameter(title: "Title")
    var taskTitle: String

    @Parameter(title: "Due Date", kind: .date)
    var dueDate: Date?

    @Dependency private var environment: AppEnvironment

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$taskTitle) due \(\.$dueDate)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let item = try await addTask(using: environment)
        return .result(dialog: "Added “\(item.title)”.")
    }

    func addTask(using environment: AppEnvironment) async throws -> TodoItem {
        var draft = TaskDraft(defaultDueDate: dueDate ?? environment.dateProvider.now)
        draft.title = taskTitle

        guard let item = draft.makeItem() else { throw AddTaskIntentError.emptyTitle }
        try await environment.store.insert(item)
        NotificationCenter.default.post(name: .tasksDidChangeExternally, object: nil)
        return item
    }
}

// MARK: - Add Task Intent Error

enum AddTaskIntentError: Error, CustomLocalizedStringResourceConvertible {
    case emptyTitle

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .emptyTitle: "A task needs a title."
        }
    }
}

// MARK: - Notification Name

extension Notification.Name {
    /// Tells the list to reload after a task was written outside of it, like from Shortcuts.
    static let tasksDidChangeExternally = Notification.Name("QuickTodo.tasksDidChangeExternally")
}
