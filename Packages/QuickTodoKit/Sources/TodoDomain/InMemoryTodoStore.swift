//
//  InMemoryTodoStore.swift
//  TodoDomain
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation

/// A store that keeps tasks in memory, sorted the same way as the Core Data store. Meant for previews.
public actor InMemoryTodoStore: TodoStore {
    private var items: [UUID: TodoItem]

    public init(items: [TodoItem] = []) {
        self.items = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    }

    public func fetchItems() -> [TodoItem] {
        // Matches SQLite, where tasks without a due date sort first.
        items.values.sorted { lhs, rhs in
            switch (lhs.dueDate, rhs.dueDate) {
            case (let lhsDate?, let rhsDate?) where lhsDate != rhsDate:
                lhsDate < rhsDate
            case (nil, _?):
                true
            case (_?, nil):
                false
            default:
                lhs.title < rhs.title
            }
        }
    }

    public func insert(_ item: TodoItem) {
        items[item.id] = item
    }

    public func update(_ item: TodoItem) throws {
        guard items[item.id] != nil else { throw TodoStoreError.itemNotFound }
        items[item.id] = item
    }

    public func delete(id: UUID) throws {
        guard items.removeValue(forKey: id) != nil else { throw TodoStoreError.itemNotFound }
    }
}
