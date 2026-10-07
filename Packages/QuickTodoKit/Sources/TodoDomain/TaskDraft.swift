//
//  TaskDraft.swift
//  TodoDomain
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation

// MARK: - Task Draft

/// The editable state behind the add and edit screens, and the one place a task gets validated.
public struct TaskDraft: Equatable, Sendable {
    public let id: UUID?
    public var title: String
    public var dueDate: Date
    public var isCompleted: Bool

    public init(item: TodoItem? = nil, defaultDueDate: Date = .now) {
        id = item?.id
        title = item?.title ?? ""
        dueDate = item?.dueDate ?? defaultDueDate
        isCompleted = item?.isCompleted ?? false
    }

    public var isEditing: Bool {
        id != nil
    }

    public var trimmedTitle: String {
        title.trimmed
    }

    public var isValid: Bool {
        !trimmedTitle.isEmpty
    }

    /// The item to persist, or `nil` while the title is blank. A new draft gets a fresh id.
    public func makeItem() -> TodoItem? {
        guard isValid else { return nil }

        return TodoItem(
            id: id ?? UUID(),
            title: trimmedTitle,
            isCompleted: isCompleted,
            dueDate: dueDate
        )
    }
}
