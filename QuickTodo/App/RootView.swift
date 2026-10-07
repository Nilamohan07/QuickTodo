//
//  RootView.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import Combine
import SwiftUI
import TaskEditorFeature
import TaskListFeature
import TodoDomain

/// Glues the features together: the list asks for the editor, the router decides what's on screen.
struct RootView: View {
    @Bindable private var router: AppRouter
    @State private var taskList: TaskListViewModel

    init(environment: AppEnvironment, router: AppRouter) {
        self.router = router
        _taskList = State(initialValue: TaskListViewModel(store: environment.store, dateProvider: environment.dateProvider))
    }

    var body: some View {
        TaskListView(
            viewModel: taskList,
            onAddTask: { router.present(.newTask) },
            onEditTask: { router.present(.editTask($0.id)) }
        )
        .sheet(item: $router.sheet) { sheet in
            editor(for: sheet)
        }
        // Posted from whatever thread the intent runs on.
        .onReceive(NotificationCenter.default.publisher(for: .tasksDidChangeExternally).receive(on: RunLoop.main)) { _ in
            Task { await taskList.loadItems() }
        }
    }
}

// MARK: - Root View - Extension

private extension RootView {
    @ViewBuilder
    func editor(for sheet: AppRouter.Sheet) -> some View {
        switch sheet {
        case .newTask:
            TaskEditorView(draft: taskList.makeNewDraft(), onSave: save)
        case .editTask(let id):
            if let item = taskList.item(withID: id) {
                TaskEditorView(draft: taskList.makeDraft(for: item), onSave: save)
            } else if !taskList.hasLoaded {
                // A notification tap on a cold launch can get here before the first load finishes.
                ProgressView()
            } else {
                MissingTaskView { router.dismissSheet() }
            }
        }
    }

    func save(_ draft: TaskDraft) {
        Task { await taskList.save(draft) }
    }
}

// MARK: - Missing Task View

// Shown when a link or notification points at a task that has since been deleted.
private struct MissingTaskView: View {
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Task Not Found",
                systemImage: "questionmark.circle",
                description: Text("This task may have been deleted.")
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
    }
}

// MARK: - Root View - Preview

#Preview {
    RootView(environment: .preview(), router: AppRouter())
}
