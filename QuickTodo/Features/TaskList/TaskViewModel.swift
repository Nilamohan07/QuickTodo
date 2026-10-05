//
//  TaskViewModel.swift
//  QuickTodo
//
//  Created by Udhayanila on 29/01/25.
//

import Foundation
import Observation
import os

@MainActor
@Observable
final class TaskViewModel {
    private(set) var items: [TodoItem] = [] {
        didSet { updateVisibleItems() }
    }

    var selectedFilter: TaskFilter = .all {
        didSet { updateVisibleItems() }
    }

    private(set) var visibleItems: [TodoItem] = []
    private(set) var itemPendingDeletion: TodoItem?
    private(set) var presentedError: TodoStoreError?

    @ObservationIgnored private let store: any TodoStore

    init(store: any TodoStore = CoreDataTodoStore()) {
        self.store = store
        loadItems()
    }

    var isConfirmingDeletion: Bool {
        get { itemPendingDeletion != nil }
        set { if !newValue { itemPendingDeletion = nil } }
    }

    var isShowingError: Bool {
        get { presentedError != nil }
        set { if !newValue { presentedError = nil } }
    }

    // MARK: - Actions

    func loadItems() {
        do {
            items = try store.fetchItems()
        } catch {
            present(error)
        }
    }

    func save(_ draft: TaskDraft) {
        guard draft.isValid else { return }

        let item = TodoItem(
            id: draft.id ?? UUID(),
            title: draft.trimmedTitle,
            isCompleted: draft.isCompleted,
            dueDate: draft.dueDate
        )

        perform {
            if draft.isEditing {
                try store.update(item)
            } else {
                try store.insert(item)
            }
        }
    }

    func toggleCompletion(of item: TodoItem) {
        var updated = item
        updated.isCompleted.toggle()
        perform { try store.update(updated) }
    }

    func requestDeletion(of item: TodoItem) {
        itemPendingDeletion = item
    }

    func delete(_ item: TodoItem) {
        itemPendingDeletion = nil
        perform { try store.delete(id: item.id) }
    }
}

// MARK: - Task View Model - Helpers

private extension TaskViewModel {
    func perform(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            present(error)
        }
        loadItems()
    }

    func present(_ error: any Error) {
        Logger.tasks.error("Task operation failed: \(error.localizedDescription)")
        presentedError = error as? TodoStoreError ?? .saveFailed
    }

    func updateVisibleItems() {
        visibleItems = items.filter(selectedFilter.includes)
    }
}
