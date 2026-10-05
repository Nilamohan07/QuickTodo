//
//  TaskEditorView.swift
//  QuickTodo
//
//  Created by Udhayanila on 29/01/25.
//

import SwiftUI

// MARK: - Task Editor View

struct TaskEditorView: View {
    enum Mode: Identifiable {
        case add
        case edit(TodoItem)

        var id: String {
            switch self {
            case .add: "add"
            case .edit(let item): item.id.uuidString
            }
        }

        var item: TodoItem? {
            if case .edit(let item) = self { return item }
            return nil
        }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var draft: TaskDraft
    @FocusState private var isTitleFocused: Bool

    private let onSave: (TaskDraft) -> Void

    init(mode: Mode, onSave: @escaping (TaskDraft) -> Void) {
        _draft = State(initialValue: TaskDraft(item: mode.item))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        TextField("Task Title", text: $draft.title)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .focused($isTitleFocused)
                            .onSubmit(save)

                        DatePicker("Due Date", selection: $draft.dueDate, displayedComponents: .date)

                        Toggle("Completed", isOn: $draft.isCompleted)

                        Button(draft.isEditing ? "Save Changes" : "Add Task", action: save)
                            .buttonStyle(.primary)
                            .disabled(!draft.isValid)
                            .padding(.top)
                    }
                    .padding(32)
                }
            }
            .navigationTitle(draft.isEditing ? "Edit Task" : "Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                guard !draft.isEditing else { return }
                // Focus is dropped if it's requested before the sheet finishes presenting.
                try? await Task.sleep(for: .milliseconds(100))
                isTitleFocused = true
            }
        }
    }
}

// MARK: - Task Editor View - Actions

private extension TaskEditorView {
    func save() {
        guard draft.isValid else { return }
        onSave(draft)
        dismiss()
    }
}

// MARK: - Task Editor View - Preview

#Preview("Add") {
    TaskEditorView(mode: .add) { _ in }
}

#Preview("Edit") {
    TaskEditorView(mode: .edit(TodoItem(title: "Buy groceries", dueDate: .now))) { _ in }
}
