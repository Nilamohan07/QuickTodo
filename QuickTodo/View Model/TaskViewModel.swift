//
//  TaskViewModel.swift
//  QuickTodo
//
//  Created by Udhayanila on 29/01/25.
//

import Foundation
import CoreData

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskDetails] = []
    private let context = CoreDataManager.shared.context

    // Initializer to fetch tasks when the ViewModel is created
    init() {
        fetchTasks()
    }
    
    // Fetch all tasks from Core Data
    func fetchTasks() {
        let fetchRequest: NSFetchRequest<TaskDetails> = TaskDetails.fetchRequest()
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch tasks: \(error.localizedDescription)")
        }
    }
    
    // Filter tasks based on the selected filter
    func filteredTasks(for filter: TaskFilter) -> [TaskDetails] {
        switch filter {
        case .all:
            return tasks
        case .active:
            return tasks.filter { !$0.isCompleted }
        case .completed:
            return tasks.filter { $0.isCompleted }
        }
    }
    
    // Add a new task to Core Data
    func addTask(title: String, isCompleted: Bool = false, dueDate: Date = Date()) {
        let newTask = TaskDetails(context: context)
        newTask.id = UUID()
        newTask.title = title
        newTask.isCompleted = isCompleted
        newTask.dueDate = dueDate

        saveContext()
        fetchTasks() // Refresh tasks
    }

    // Toggle task completion status
    func toggleTaskCompletion(taskID: UUID) {
        if let task = tasks.first(where: { $0.id == taskID }) {
            task.isCompleted.toggle()
            saveContext()
            fetchTasks()
        }
    }

    // Delete a task from Core Data
    func deleteTask(taskID: UUID) {
        if let task = tasks.first(where: { $0.id == taskID }) {
            context.delete(task)
            saveContext()
            fetchTasks()
        }
    }

    // Update task details
    func updateTask(taskID: UUID, newTitle: String, newIsCompleted: Bool, newDueDate: Date?) {
        if let task = tasks.first(where: { $0.id == taskID }) {
            task.title = newTitle
            task.isCompleted = newIsCompleted
            task.dueDate = newDueDate ?? task.dueDate

            saveContext()
            fetchTasks()
        }
    }

    // Save changes to Core Data
    private func saveContext() {
        CoreDataManager.shared.saveContext()
    }
    
    func mapToTask(from details: TaskDetails) -> Task {
        return Task(
            id: details.id ?? UUID(),
            title: details.title ?? "",
            isCompleted: details.isCompleted,
            dueDate: details.dueDate
        )
    }
}
