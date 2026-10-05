//
//  CoreDataManagerTests.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 09/03/26.
//

import XCTest
import CoreData
@testable import QuickTodo

final class CoreDataManagerTests: XCTestCase {

    // MARK: - Core Data Entity

    func testSaveTaskDetails() {
        let context = makeContext()
        insertRecord(title: "Test Task", in: context)

        XCTAssertNoThrow(try context.save())
    }

    func testFetchTaskDetails() throws {
        let context = makeContext()
        insertRecord(title: "Fetch Me", isCompleted: true, in: context)
        try context.save()

        let results = try context.fetch(TaskDetails.fetchRequest()) as [TaskDetails]

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Fetch Me")
        XCTAssertEqual(results.first?.isCompleted, true)
    }

    func testUpdateTaskDetails() throws {
        let context = makeContext()
        let record = insertRecord(title: "Original", in: context)
        try context.save()

        record.title = "Updated"
        record.isCompleted = true
        try context.save()

        let results = try context.fetch(TaskDetails.fetchRequest()) as [TaskDetails]

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Updated")
        XCTAssertEqual(results.first?.isCompleted, true)
    }

    func testDeleteTaskDetails() throws {
        let context = makeContext()
        let record = insertRecord(title: "Delete Me", in: context)
        try context.save()

        context.delete(record)
        try context.save()

        let results = try context.fetch(TaskDetails.fetchRequest()) as [TaskDetails]
        XCTAssertTrue(results.isEmpty)
    }

    func testTaskDetailsDefaultValues() {
        let record = TaskDetails(context: makeContext())

        XCTAssertNil(record.id)
        XCTAssertNil(record.title)
        XCTAssertFalse(record.isCompleted)
        XCTAssertNil(record.dueDate)
    }

    // MARK: - Core Data Manager

    func testSharedInstanceIsReused() {
        XCTAssertTrue(CoreDataManager.shared === CoreDataManager.shared)
    }

    func testInMemoryStoresAreIsolated() throws {
        let first = makeContext()
        let second = makeContext()
        insertRecord(title: "Only in first", in: first)
        try first.save()

        let results = try second.fetch(TaskDetails.fetchRequest()) as [TaskDetails]
        XCTAssertTrue(results.isEmpty)
    }

    func testMappingRoundTrip() {
        let item = TodoItem(title: "Round trip", isCompleted: true, dueDate: Date())
        let record = TaskDetails(context: makeContext())

        record.apply(item)

        XCTAssertEqual(TodoItem(record), item)
    }
}

// MARK: - Helpers

private extension CoreDataManagerTests {
    func makeContext() -> NSManagedObjectContext {
        CoreDataManager(inMemory: true).viewContext
    }

    @discardableResult
    func insertRecord(title: String, isCompleted: Bool = false, in context: NSManagedObjectContext) -> TaskDetails {
        let record = TaskDetails(context: context)
        record.id = UUID()
        record.title = title
        record.isCompleted = isCompleted
        record.dueDate = Date()
        return record
    }
}
