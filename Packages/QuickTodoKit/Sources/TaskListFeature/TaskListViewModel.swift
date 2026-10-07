//
//  TaskListViewModel.swift
//  TaskListFeature
//
//  Created by Udhayanila on 29/01/25.
//

import Foundation
import Observation
import os
import TodoDomain

/// State and actions for the task list. Every write reloads from the store, so the list
/// always shows what was actually persisted.
@MainActor
@Observable
public final class TaskListViewModel {
    public private(set) var items: [TodoItem] = [] {
        didSet { updateVisibleItems() }
    }

    public var selectedFilter: TaskFilter = .all {
        didSet { updateVisibleItems() }
    }

    public private(set) var visibleItems: [TodoItem] = []
    public private(set) var hasLoaded = false
    public private(set) var itemPendingDeletion: TodoItem?
    public private(set) var presentedError: TodoStoreError?

    @ObservationIgnored private let store: any TodoStore
    @ObservationIgnored private let dateProvider: DateProvider
    @ObservationIgnored private let logger = Logger(subsystem: "com.udhayanila.in.QuickTodo", category: "Tasks")

    public init(store: any TodoStore, dateProvider: DateProvider = .system) {
        self.store = store
        self.dateProvider = dateProvider
    }

    public var isConfirmingDeletion: Bool {
        get { itemPendingDeletion != nil }
        set { if !newValue { itemPendingDeletion = nil } }
    }

    public var isShowingError: Bool {
        get { presentedError != nil }
        set { if !newValue { presentedError = nil } }
    }

    public var remainingCount: Int {
        items.count { !$0.isCompleted }
    }

    // MARK: - Queries

    public func item(withID id: UUID) -> TodoItem? {
        items.first { $0.id == id }
    }

    public func makeNewDraft() -> TaskDraft {
        TaskDraft(defaultDueDate: dateProvider.now)
    }

    public func makeDraft(for item: TodoItem) -> TaskDraft {
        TaskDraft(item: item, defaultDueDate: dateProvider.now)
    }

    public func isOverdue(_ item: TodoItem) -> Bool {
        item.isOverdue(on: dateProvider.now)
    }

    // MARK: - Actions

    public func loadItems() async {
        do {
            items = try await store.fetchItems()
        } catch {
            present(error, fallback: .fetchFailed)
        }
        hasLoaded = true
    }

    public func save(_ draft: TaskDraft) async {
        guard let item = draft.makeItem() else { return }

        await perform {
            if draft.isEditing {
                try await store.update(item)
            } else {
                try await store.insert(item)
            }
        }
    }

    public func toggleCompletion(of item: TodoItem) async {
        var updated = item
        updated.isCompleted.toggle()
        await perform { try await store.update(updated) }
    }

    public func requestDeletion(of item: TodoItem) {
        itemPendingDeletion = item
    }

    public func delete(_ item: TodoItem) async {
        itemPendingDeletion = nil
        await perform { try await store.delete(id: item.id) }
    }
}

// MARK: - Task List View Model - Helpers

private extension TaskListViewModel {
    func perform(_ operation: () async throws -> Void) async {
        do {
            try await operation()
        } catch {
            present(error, fallback: .saveFailed)
        }
        await loadItems()
    }

    func present(_ error: any Error, fallback: TodoStoreError) {
        logger.error("Task operation failed: \(error.localizedDescription)")
        presentedError = error as? TodoStoreError ?? fallback
    }

    func updateVisibleItems() {
        visibleItems = items.filter(selectedFilter.includes)
    }
}
