//
//  TaskRowView.swift
//  QuickTodo
//
//  Created by Udhayanila on 04/02/25.
//

import SwiftUI

// MARK: - Task Row View

struct TaskRowView: View {
    let item: TodoItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                completionIcon
                taskInfo
                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            editButton
            deleteButton
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(accessibilityStatus)
        .accessibilityHint(item.isCompleted ? "Marks the task as not completed" : "Marks the task as completed")
        .accessibilityAction(named: "Edit", onEdit)
        .accessibilityAction(named: "Delete", onDelete)
    }
}

// MARK: - Task Row View - Extension

private extension TaskRowView {
    var isOverdue: Bool {
        item.isOverdue()
    }

    var completionIcon: some View {
        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(item.isCompleted ? .green : .secondary)
            .contentTransition(.symbolEffect(.replace))
    }

    var taskInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .strikethrough(item.isCompleted)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                .lineLimit(2)

            if let dueDate = item.dueDate {
                Text("Due: \(dueDate, format: .dateTime.day().month(.abbreviated).year())")
                    .font(.subheadline)
                    .foregroundStyle(isOverdue ? .red : .secondary)
            }
        }
    }

    var editButton: some View {
        Button(action: onEdit) {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }

    var deleteButton: some View {
        Button(action: onDelete) {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }

    var accessibilityStatus: String {
        if item.isCompleted { return "Completed" }
        return isOverdue ? "Overdue" : "Pending"
    }
}

// MARK: - Task Row View - Preview

#Preview {
    List {
        TaskRowView(item: TodoItem(title: "Sample Task", dueDate: .now), onToggle: {}, onEdit: {}, onDelete: {})
        TaskRowView(item: TodoItem(title: "Finished Task", isCompleted: true), onToggle: {}, onEdit: {}, onDelete: {})
    }
}
