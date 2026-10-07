//
//  TaskEditorView.swift
//  TaskEditorFeature
//
//  Created by Udhayanila on 29/01/25.
//

import DesignSystem
import SwiftUI
import TodoDomain

// MARK: - Task Editor View

/// Add and edit screen for a single task. It only edits a draft; the caller decides how to save it.
public struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: TaskDraft
    @FocusState private var isTitleFocused: Bool

    private let onSave: (TaskDraft) -> Void

    public init(draft: TaskDraft, onSave: @escaping (TaskDraft) -> Void) {
        _draft = State(initialValue: draft)
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView {
                    VStack(spacing: Spacing.large) {
                        TextField(String(localized: "Task Title", bundle: .module), text: $draft.title)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .focused($isTitleFocused)
                            .onSubmit(save)
                            .accessibilityIdentifier(AccessibilityID.titleField)

                        DatePicker(
                            String(localized: "Due Date", bundle: .module),
                            selection: $draft.dueDate,
                            displayedComponents: .date
                        )

                        Toggle(String(localized: "Completed", bundle: .module), isOn: $draft.isCompleted)
                            .accessibilityIdentifier(AccessibilityID.completedToggle)

                        Button(saveTitle, action: save)
                            .buttonStyle(.primary)
                            .disabled(!draft.isValid)
                            .padding(.top)
                            .accessibilityIdentifier(AccessibilityID.saveButton)
                    }
                    .padding(Spacing.xxLarge)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel", bundle: .module)) { dismiss() }
                        .accessibilityIdentifier(AccessibilityID.cancelButton)
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

// MARK: - Task Editor View - Accessibility

// The UI tests look these up, so changing one means changing the tests too.
private enum AccessibilityID {
    static let titleField = "taskEditor.title"
    static let completedToggle = "taskEditor.completed"
    static let saveButton = "taskEditor.save"
    static let cancelButton = "taskEditor.cancel"
}

// MARK: - Task Editor View - Actions

private extension TaskEditorView {
    var navigationTitle: String {
        draft.isEditing
            ? String(localized: "Edit Task", bundle: .module)
            : String(localized: "Add Task", bundle: .module)
    }

    var saveTitle: String {
        draft.isEditing
            ? String(localized: "Save Changes", bundle: .module)
            : String(localized: "Add Task", bundle: .module)
    }

    func save() {
        guard draft.isValid else { return }
        onSave(draft)
        dismiss()
    }
}

// MARK: - Task Editor View - Preview

#Preview("Add") {
    TaskEditorView(draft: TaskDraft()) { _ in }
}

#Preview("Edit") {
    TaskEditorView(draft: TaskDraft(item: TodoItem(title: "Buy groceries", dueDate: .now))) { _ in }
}
