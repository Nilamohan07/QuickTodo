//
//  MockTodoStore.swift
//  TodoTestSupport
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import TodoDomain

/// An in-memory `TodoStore` with injectable failures.
public actor MockTodoStore: TodoStore {
    public private(set) var items: [TodoItem]
    public var fetchError: TodoStoreError?
    public var saveError: TodoStoreError?

    public init(items: [TodoItem] = []) {
        self.items = items
    }

    public func setItems(_ items: [TodoItem]) {
        self.items = items
    }

    public func setFetchError(_ error: TodoStoreError?) {
        fetchError = error
    }

    public func setSaveError(_ error: TodoStoreError?) {
        saveError = error
    }

    public func fetchItems() throws -> [TodoItem] {
        if let fetchError { throw fetchError }
        return items
    }

    public func insert(_ item: TodoItem) throws {
        if let saveError { throw saveError }
        items.append(item)
    }

    public func update(_ item: TodoItem) throws {
        if let saveError { throw saveError }
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            throw TodoStoreError.itemNotFound
        }
        items[index] = item
    }

    public func delete(id: UUID) throws {
        if let saveError { throw saveError }
        guard items.contains(where: { $0.id == id }) else {
            throw TodoStoreError.itemNotFound
        }
        items.removeAll { $0.id == id }
    }
}
