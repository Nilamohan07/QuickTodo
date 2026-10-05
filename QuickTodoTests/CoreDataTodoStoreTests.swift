//
//  CoreDataTodoStoreTests.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 05/10/26.
//

import XCTest
import CoreData
@testable import QuickTodo

@MainActor
final class CoreDataTodoStoreTests: XCTestCase {

    func testInsertAndFetch() throws {
        let store = makeStore()
        let item = TodoItem(title: "Write tests", dueDate: Date())

        try store.insert(item)

        XCTAssertEqual(try store.fetchItems(), [item])
    }

    func testItemsAreSortedByDueDate() throws {
        let store = makeStore()
        let now = Date()
        try store.insert(TodoItem(title: "Later", dueDate: now.addingTimeInterval(86_400)))
        try store.insert(TodoItem(title: "Sooner", dueDate: now))

        XCTAssertEqual(try store.fetchItems().map(\.title), ["Sooner", "Later"])
    }

    func testUpdate() throws {
        let store = makeStore()
        var item = TodoItem(title: "Draft")
        try store.insert(item)

        item.title = "Final"
        item.isCompleted = true
        try store.update(item)

        XCTAssertEqual(try store.fetchItems(), [item])
    }

    func testUpdateMissingItemThrows() {
        let store = makeStore()

        XCTAssertThrowsError(try store.update(TodoItem(title: "Ghost"))) { error in
            XCTAssertEqual(error as? TodoStoreError, .itemNotFound)
        }
    }

    func testDelete() throws {
        let store = makeStore()
        let keep = TodoItem(title: "Keep")
        let remove = TodoItem(title: "Remove")
        try store.insert(keep)
        try store.insert(remove)

        try store.delete(id: remove.id)

        XCTAssertEqual(try store.fetchItems(), [keep])
    }

    func testDeleteMissingItemThrows() {
        let store = makeStore()

        XCTAssertThrowsError(try store.delete(id: UUID())) { error in
            XCTAssertEqual(error as? TodoStoreError, .itemNotFound)
        }
    }

    func testRecordsWithoutIDGetAStableID() throws {
        let context = CoreDataManager(inMemory: true).viewContext
        let store = CoreDataTodoStore(context: context)
        let legacy = TaskDetails(context: context)
        legacy.title = "Legacy"
        try context.save()

        let firstFetch = try store.fetchItems()
        let secondFetch = try store.fetchItems()

        XCTAssertNotNil(legacy.id)
        XCTAssertEqual(firstFetch.first?.id, secondFetch.first?.id)
        XCTAssertNoThrow(try store.delete(id: try XCTUnwrap(firstFetch.first?.id)))
    }

    func testRecordWithoutTitleMapsToEmptyString() throws {
        let context = CoreDataManager(inMemory: true).viewContext
        let store = CoreDataTodoStore(context: context)
        _ = TaskDetails(context: context)
        try context.save()

        let item = try XCTUnwrap(store.fetchItems().first)

        XCTAssertEqual(item.title, "")
        XCTAssertFalse(item.isCompleted)
        XCTAssertNil(item.dueDate)
    }
}

// MARK: - Helpers

private extension CoreDataTodoStoreTests {
    func makeStore() -> CoreDataTodoStore {
        CoreDataTodoStore(context: CoreDataManager(inMemory: true).viewContext)
    }
}
