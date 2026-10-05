//
//  TodoItemTests.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 09/03/26.
//

import XCTest
@testable import QuickTodo

final class TodoItemTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    // MARK: - Todo Item

    func testInitialization() {
        let id = UUID()
        let date = Date()
        let item = TodoItem(id: id, title: "Buy groceries", isCompleted: false, dueDate: date)

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.title, "Buy groceries")
        XCTAssertFalse(item.isCompleted)
        XCTAssertEqual(item.dueDate, date)
    }

    func testDefaultValues() {
        let item = TodoItem(title: "No deadline")

        XCTAssertFalse(item.isCompleted)
        XCTAssertNil(item.dueDate)
    }

    func testMutability() {
        var item = TodoItem(title: "Original")
        item.title = "Updated"
        item.isCompleted = true
        item.dueDate = Date()

        XCTAssertEqual(item.title, "Updated")
        XCTAssertTrue(item.isCompleted)
        XCTAssertNotNil(item.dueDate)
    }

    // MARK: - Overdue

    func testItemDueYesterdayIsOverdue() {
        let now = date(2026, 10, 5, hour: 9)
        let item = TodoItem(title: "Late", dueDate: date(2026, 10, 4, hour: 18))

        XCTAssertTrue(item.isOverdue(on: now, calendar: calendar))
    }

    func testItemDueEarlierTodayIsNotOverdue() {
        let now = date(2026, 10, 5, hour: 18)
        let item = TodoItem(title: "Today", dueDate: date(2026, 10, 5, hour: 9))

        XCTAssertFalse(item.isOverdue(on: now, calendar: calendar))
    }

    func testCompletedItemIsNeverOverdue() {
        let now = date(2026, 10, 5, hour: 9)
        let item = TodoItem(title: "Done", isCompleted: true, dueDate: date(2026, 9, 1, hour: 9))

        XCTAssertFalse(item.isOverdue(on: now, calendar: calendar))
    }

    func testItemWithoutDueDateIsNeverOverdue() {
        XCTAssertFalse(TodoItem(title: "Someday").isOverdue())
    }

    // MARK: - Task Filter

    func testFilterAllCases() {
        XCTAssertEqual(TaskFilter.allCases, [.all, .active, .completed])
    }

    func testFilterRawValues() {
        XCTAssertEqual(TaskFilter.all.rawValue, "All")
        XCTAssertEqual(TaskFilter.active.rawValue, "Active")
        XCTAssertEqual(TaskFilter.completed.rawValue, "Completed")
        XCTAssertNil(TaskFilter(rawValue: "Invalid"))
    }

    func testFilterIncludes() {
        let active = TodoItem(title: "Active")
        let done = TodoItem(title: "Done", isCompleted: true)

        XCTAssertTrue(TaskFilter.all.includes(active))
        XCTAssertTrue(TaskFilter.all.includes(done))
        XCTAssertTrue(TaskFilter.active.includes(active))
        XCTAssertFalse(TaskFilter.active.includes(done))
        XCTAssertFalse(TaskFilter.completed.includes(active))
        XCTAssertTrue(TaskFilter.completed.includes(done))
    }
}

// MARK: - Helpers

private extension TodoItemTests {
    func date(_ year: Int, _ month: Int, _ day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
