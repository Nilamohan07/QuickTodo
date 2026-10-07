//
//  TodoItem.swift
//  TodoDomain
//
//  Created by Udhayanila on 04/02/25.
//

import Foundation

// MARK: - Todo Item

/// A task as the rest of the app sees it, independent of how it's stored.
public struct TodoItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var isCompleted: Bool
    public var dueDate: Date?

    public init(id: UUID = UUID(), title: String, isCompleted: Bool = false, dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
    }

    /// Whether the task's due day has passed without it being completed.
    public func isOverdue(on date: Date = .now, calendar: Calendar = .current) -> Bool {
        // Due dates are picked without a time, so a task only becomes overdue once its day has passed.
        guard let dueDate, !isCompleted else { return false }
        return dueDate < calendar.startOfDay(for: date)
    }
}
