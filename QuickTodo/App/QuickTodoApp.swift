//
//  QuickTodoApp.swift
//  QuickTodo
//
//  Created by Udhayanila on 29/01/25.
//

import SwiftUI

@main
struct QuickTodoApp: App {
    @State private var taskViewModel = TaskViewModel()

    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: taskViewModel)
        }
    }
}
