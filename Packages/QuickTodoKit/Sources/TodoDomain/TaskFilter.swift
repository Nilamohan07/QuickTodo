//
//  TaskFilter.swift
//  TodoDomain
//
//  Created by Udhayanila on 04/02/25.
//

import Foundation

// MARK: - Task Filter

/// The segments of the task list. Raw values are stable identifiers, not display text.
public enum TaskFilter: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"

    public var id: Self { self }

    public func includes(_ item: TodoItem) -> Bool {
        switch self {
        case .all: true
        case .active: !item.isCompleted
        case .completed: item.isCompleted
        }
    }
}
