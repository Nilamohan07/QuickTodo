//
//  CoreDataTodoStoreTests.swift
//  TodoPersistenceTests
//
//  Created by Udhayanila on 05/10/26.
//

import CoreData
import Foundation
import Testing
import TodoDomain
@testable import TodoPersistence

@MainActor
@Suite("Core Data todo store")
struct CoreDataTodoStoreTests {
    private let stack = CoreDataStack(location: .inMemory)

    private var store: CoreDataTodoStore {
        CoreDataTodoStore(stack: stack)
    }

    @Test func insertAndFetch() async throws {
        let item = TodoItem(title: "Write tests", dueDate: Date())

        try await store.insert(item)

        #expect(try await store.fetchItems() == [item])
    }

    @Test func itemsAreSortedByDueDateThenTitle() async throws {
        let now = Date()
        try await store.insert(TodoItem(title: "Later", dueDate: now.addingTimeInterval(86_400)))
        try await store.insert(TodoItem(title: "Sooner B", dueDate: now))
        try await store.insert(TodoItem(title: "Sooner A", dueDate: now))

        #expect(try await store.fetchItems().map(\.title) == ["Sooner A", "Sooner B", "Later"])
    }

    @Test func update() async throws {
        var item = TodoItem(title: "Draft")
        try await store.insert(item)

        item.title = "Final"
        item.isCompleted = true
        try await store.update(item)

        #expect(try await store.fetchItems() == [item])
    }

    @Test func updateMissingItemThrows() async {
        await #expect(throws: TodoStoreError.itemNotFound) {
            try await store.update(TodoItem(title: "Ghost"))
        }
    }

    @Test func delete() async throws {
        let keep = TodoItem(title: "Keep")
        let remove = TodoItem(title: "Remove")
        try await store.insert(keep)
        try await store.insert(remove)

        try await store.delete(id: remove.id)

        #expect(try await store.fetchItems() == [keep])
    }

    @Test func deleteMissingItemThrows() async {
        await #expect(throws: TodoStoreError.itemNotFound) {
            try await store.delete(id: UUID())
        }
    }

    @Test func concurrentInsertsAreAllSaved() async throws {
        let store = store
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<20 {
                group.addTask { try await store.insert(TodoItem(title: "Task \(index)")) }
            }
            try await group.waitForAll()
        }

        #expect(try await store.fetchItems().count == 20)
    }

    @Test func recordsWithoutIDGetAStableID() async throws {
        let context = stack.container.viewContext
        let legacy = TaskDetails(context: context)
        legacy.title = "Legacy"
        try context.save()

        let firstFetch = try await store.fetchItems()
        let secondFetch = try await store.fetchItems()
        let id = try #require(firstFetch.first?.id)

        #expect(secondFetch.first?.id == id)
        try await store.delete(id: id)
        #expect(try await store.fetchItems().isEmpty)
    }

    @Test func recordWithoutTitleMapsToEmptyString() async throws {
        let context = stack.container.viewContext
        _ = TaskDetails(context: context)
        try context.save()

        let item = try #require(try await store.fetchItems().first)

        #expect(item.title == "")
        #expect(!item.isCompleted)
        #expect(item.dueDate == nil)
    }
}
