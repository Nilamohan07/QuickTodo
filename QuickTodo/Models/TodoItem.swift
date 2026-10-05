//
//  TodoItem.swift
//  QuickTodo
//
//  Created by Udhayanila on 04/02/25.
//

import Foundation

// MARK: - Todo Item

struct TodoItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date?

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
    }

    // Due dates are picked without a time, so a task only becomes overdue once its day has passed.
    func isOverdue(on date: Date = .now, calendar: Calendar = .current) -> Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < calendar.startOfDay(for: date)
    }
}

// MARK: - Task Filter

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    var id: Self { self }

    func includes(_ item: TodoItem) -> Bool {
        switch self {
        case .all: true
        case .active: !item.isCompleted
        case .completed: item.isCompleted
        }
    }
}
