//
//  TaskRowView.swift
//  TaskListFeature
//
//  Created by Udhayanila on 04/02/25.
//

import DesignSystem
import SwiftUI
import TodoDomain

// MARK: - Task Row View

struct TaskRowView: View {
    let item: TodoItem
    let isOverdue: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: Spacing.medium) {
                completionIcon
                taskInfo
                Spacer(minLength: 0)
            }
            .padding(.vertical, Spacing.xxSmall)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            editButton
            deleteButton
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("taskRow.\(item.title)")
        .accessibilityValue(accessibilityStatus)
        .accessibilityHint(accessibilityHint)
        .accessibilityAction(named: Text("Edit", bundle: .module), onEdit)
        .accessibilityAction(named: Text("Delete", bundle: .module), onDelete)
    }
}

// MARK: - Task Row View - Extension

private extension TaskRowView {
    var completionIcon: some View {
        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(item.isCompleted ? Color.completed : .secondary)
            .contentTransition(.symbolEffect(.replace))
    }

    var taskInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
            Text(item.title)
                .font(.headline)
                .strikethrough(item.isCompleted)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                .lineLimit(2)

            if let dueDate = item.dueDate {
                Text("Due: \(dueDate, format: .dateTime.day().month(.abbreviated).year())", bundle: .module)
                    .font(.subheadline)
                    .foregroundStyle(isOverdue ? Color.overdue : .secondary)
            }
        }
    }

    var editButton: some View {
        Button(action: onEdit) {
            Label(String(localized: "Edit", bundle: .module), systemImage: "pencil")
        }
        .tint(.blue)
    }

    var deleteButton: some View {
        Button(action: onDelete) {
            Label(String(localized: "Delete", bundle: .module), systemImage: "trash")
        }
        .tint(.red)
    }

    var accessibilityStatus: Text {
        if item.isCompleted { return Text("Completed", bundle: .module) }
        return isOverdue ? Text("Overdue", bundle: .module) : Text("Pending", bundle: .module)
    }

    var accessibilityHint: Text {
        item.isCompleted
            ? Text("Marks the task as not completed", bundle: .module)
            : Text("Marks the task as completed", bundle: .module)
    }
}

// MARK: - Task Row View - Preview

#Preview {
    List {
        TaskRowView(
            item: TodoItem(title: "Sample Task", dueDate: .now),
            isOverdue: false,
            onToggle: {}, onEdit: {}, onDelete: {}
        )
        TaskRowView(
            item: TodoItem(title: "Finished Task", isCompleted: true),
            isOverdue: false,
            onToggle: {}, onEdit: {}, onDelete: {}
        )
    }
}
