//
//  TaskDetails+TodoItem.swift
//  TodoPersistence
//
//  Created by Udhayanila on 05/10/26.
//

import CoreData
import TodoDomain

extension TodoItem {
    init(_ record: TaskDetails) {
        self.init(
            id: record.id ?? UUID(),
            title: record.title ?? "",
            isCompleted: record.isCompleted,
            dueDate: record.dueDate
        )
    }
}

extension TaskDetails {
    func apply(_ item: TodoItem) {
        id = item.id
        title = item.title
        isCompleted = item.isCompleted
        dueDate = item.dueDate
    }
}
