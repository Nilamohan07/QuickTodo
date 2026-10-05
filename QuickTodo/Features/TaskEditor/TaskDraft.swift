//
//  TaskDraft.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation

struct TaskDraft: Equatable {
    let id: UUID?
    var title: String
    var dueDate: Date
    var isCompleted: Bool

    init(item: TodoItem? = nil, defaultDueDate: Date = .now) {
        id = item?.id
        title = item?.title ?? ""
        dueDate = item?.dueDate ?? defaultDueDate
        isCompleted = item?.isCompleted ?? false
    }

    var isEditing: Bool {
        id != nil
    }

    var trimmedTitle: String {
        title.trimmed
    }

    var isValid: Bool {
        !trimmedTitle.isEmpty
    }
}
