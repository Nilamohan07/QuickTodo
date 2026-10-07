//
//  QuickTodoShortcuts.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import AppIntents

struct QuickTodoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "New \(.applicationName) task"
            ],
            shortTitle: "Add Task",
            systemImageName: "plus.circle"
        )
    }
}
