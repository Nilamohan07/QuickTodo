//
//  TodoStore.swift
//  TodoDomain
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation

// MARK: - Todo Store

/// Persistence boundary for tasks. Implementations decide which thread or context does the work.
public protocol TodoStore: Sendable {
    func fetchItems() async throws -> [TodoItem]
    func insert(_ item: TodoItem) async throws
    func update(_ item: TodoItem) async throws
    func delete(id: UUID) async throws
}

// MARK: - Todo Store Error

/// What can go wrong at the store boundary. User-facing wording lives with the screens that show it.
public enum TodoStoreError: Error, Equatable, Sendable {
    case fetchFailed
    case saveFailed
    case itemNotFound
}
