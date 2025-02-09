//
//  AddTaskView.swift
//  QuickTodo
//
//  Created by Udhayanila on 29/01/25.
//

import SwiftUI

// MARK: - Add Task View

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var taskViewModel: TaskViewModel
    @Binding var taskToEdit: Task?
    @State var dueDate: Date
    @State private var title: String = ""
    @State private var isCompleted: Bool = false
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Title Input
                TextField("Task Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .accessibilityLabel("Task Title")
                    .focused($isTitleFocused) // Attach focus state
                
                // Due Date Picker
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    .padding()
                    .accessibilityLabel("Due Date")
                
                // Completion Toggle
                Toggle("Completed", isOn: $isCompleted)
                    .padding()
                    .accessibilityLabel("Task Completion Status")
                
                // Save/Add Button
                Button(action: saveTask) {
                    Text(taskToEdit == nil ? "Add Task" : "Save Changes")
                        .modifier(PrimaryButtonStyle())
                }
                .scaleEffect(1.05)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: title)

                Spacer()
            }
            .padding()
            .onAppear(perform: setupEditingTask)
            .onAppear {
                // Focus the title field when the view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if taskToEdit == nil {
                        isTitleFocused = true
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "Add Task" : "Edit Task")
        }
    }

    // Pre-fill fields if editing an existing task
    private func setupEditingTask() {
        if let task = taskToEdit {
            title = task.title
            dueDate = task.dueDate ?? Date()
            isCompleted = task.isCompleted
        }
    }

    // Save or Update Task
    private func saveTask() {
        guard !title.isEmpty else { return }
        if let taskToEdit = taskToEdit {
            taskViewModel.updateTask(
                taskID: taskToEdit.id,
                newTitle: title,
                newIsCompleted: isCompleted,
                newDueDate: dueDate
            )
        } else {
            taskViewModel.addTask(
                title: title,
                isCompleted: isCompleted,
                dueDate: dueDate
            )
        }
        dismiss()
    }
}

// MARK: - Add Task View - Preview

#Preview {
    AddTaskView(taskViewModel: TaskViewModel(), taskToEdit: .constant(nil), dueDate: Date())
}
