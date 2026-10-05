//
//  MockTodoStore.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
@testable import QuickTodo

@MainActor
final class MockTodoStore: TodoStore {
    var items: [TodoItem]
    var fetchError: TodoStoreError?
    var saveError: TodoStoreError?

    init(items: [TodoItem] = []) {
        self.items = items
    }

    func fetchItems() throws -> [TodoItem] {
        if let fetchError { throw fetchError }
        return items
    }

    func insert(_ item: TodoItem) throws {
        if let saveError { throw saveError }
        items.append(item)
    }

    func update(_ item: TodoItem) throws {
        if let saveError { throw saveError }
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            throw TodoStoreError.itemNotFound
        }
        items[index] = item
    }

    func delete(id: UUID) throws {
        if let saveError { throw saveError }
        guard items.contains(where: { $0.id == id }) else {
            throw TodoStoreError.itemNotFound
        }
        items.removeAll { $0.id == id }
    }
}
