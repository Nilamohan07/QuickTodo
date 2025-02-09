//
//  TaskRowView.swift
//  QuickTodo
//
//  Created by Udhayanila on 04/02/25.
//

import SwiftUI

// MARK: - Task Row View

struct TaskRowView: View {
    @Binding var showAddTaskView: Bool
    @Binding var taskToEdit: Task?
    @Binding var taskToDelete: Task?
    @Binding var showDeleteConfirmation: Bool
    @State private var isEditing = false
    @State private var editedTitle = ""
    let task: Task
    let taskViewModel: TaskViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditing {
                editTaskField
            } else {
                taskInfoView
            }
        }
        .frame(height: 50)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            editButton
            deleteButton
        }
    }
}

// MARK: - Task Row View - Extension

private extension TaskRowView {
    var editTaskField: some View {
        HStack {
            TextField("Edit Task", text: $editedTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.headline)
                .padding(.vertical, 4)
            
            Button(action: {
                taskViewModel.updateTask(taskID: task.id, newTitle: editedTitle, newIsCompleted: task.isCompleted, newDueDate: task.dueDate)
                isEditing = false
            }) {
                Text("Save")
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    
    var taskInfoView: some View {
        VStack(alignment: .leading) {
            HStack {
                completionIcon
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .gray : .black)
                    .lineLimit(1)
                Spacer()
            }
            
            if let dueDate = task.dueDate {
                Text("Due: \(formattedDate(dueDate))")
                    .font(.subheadline)
                    .foregroundColor(dueDate < Date() && !task.isCompleted ? .red : .gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            taskViewModel.toggleTaskCompletion(taskID: task.id)
        }
    }
    
    var completionIcon: some View {
        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundColor(task.isCompleted ? .green : .gray)
            .padding(.trailing, 16)
    }
    
    var editButton: some View {
        Button(action: {
            showAddTaskView = true
            taskToDelete = nil
            taskToEdit = task
        }) {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }
    
    var deleteButton: some View {
        Button {
            showDeleteConfirmation = true
            taskToEdit = nil
            taskToDelete = task
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Task Row View - Preview

#Preview {
    TaskRowView(
        showAddTaskView: .constant(false),
        taskToEdit: .constant(nil), taskToDelete: .constant(nil), showDeleteConfirmation: .constant(false),
        task: Task(id: UUID(), title: "Sample Task", isCompleted: false, dueDate: Date()),
        taskViewModel: TaskViewModel()
    )
}
