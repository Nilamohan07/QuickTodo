//
//  TaskModel.swift
//  QuickTodo
//
//  Created by Udhayanila on 04/02/25.
//

import Foundation

// MARK: - Task

struct Task: Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
}

// MARK: - Task Filter

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}
