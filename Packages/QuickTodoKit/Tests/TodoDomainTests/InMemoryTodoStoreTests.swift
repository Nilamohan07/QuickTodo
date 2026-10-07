//
//  InMemoryTodoStoreTests.swift
//  TodoDomainTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import Testing
import TodoDomain

@Suite("In-memory store")
struct InMemoryTodoStoreTests {
    @Test func sortsLikeCoreData() async {
        let now = Date()
        let store = InMemoryTodoStore(items: [
            TodoItem(title: "Later", dueDate: now.addingTimeInterval(86_400)),
            TodoItem(title: "B sooner", dueDate: now),
            TodoItem(title: "A sooner", dueDate: now),
            TodoItem(title: "Undated")
        ])

        #expect(await store.fetchItems().map(\.title) == ["Undated", "A sooner", "B sooner", "Later"])
    }

    @Test func updateAndDeleteRequireExistingItem() async {
        let store = InMemoryTodoStore()

        await #expect(throws: TodoStoreError.itemNotFound) { try await store.update(TodoItem(title: "Ghost")) }
        await #expect(throws: TodoStoreError.itemNotFound) { try await store.delete(id: UUID()) }
    }

    @Test func fixedDateProvider() {
        let date = Date(timeIntervalSince1970: 42)

        #expect(DateProvider.fixed(date).now == date)
    }
}
