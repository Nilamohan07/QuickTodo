//
//  TodoItemTests.swift
//  TodoDomainTests
//
//  Created by Udhayanila on 09/03/26.
//

import Foundation
import Testing
import TodoDomain

@Suite("Todo item")
struct TodoItemTests {
    private let calendar = Calendar(identifier: .gregorian)

    // MARK: - Todo Item

    @Test func initialization() {
        let id = UUID()
        let date = Date()
        let item = TodoItem(id: id, title: "Buy groceries", isCompleted: false, dueDate: date)

        #expect(item.id == id)
        #expect(item.title == "Buy groceries")
        #expect(!item.isCompleted)
        #expect(item.dueDate == date)
    }

    @Test func defaultValues() {
        let item = TodoItem(title: "No deadline")

        #expect(!item.isCompleted)
        #expect(item.dueDate == nil)
    }

    @Test func mutability() {
        var item = TodoItem(title: "Original")
        item.title = "Updated"
        item.isCompleted = true
        item.dueDate = Date()

        #expect(item.title == "Updated")
        #expect(item.isCompleted)
        #expect(item.dueDate != nil)
    }

    // MARK: - Overdue

    @Test func itemDueYesterdayIsOverdue() {
        let now = date(2026, 10, 5, hour: 9)
        let item = TodoItem(title: "Late", dueDate: date(2026, 10, 4, hour: 18))

        #expect(item.isOverdue(on: now, calendar: calendar))
    }

    @Test func itemDueEarlierTodayIsNotOverdue() {
        let now = date(2026, 10, 5, hour: 18)
        let item = TodoItem(title: "Today", dueDate: date(2026, 10, 5, hour: 9))

        #expect(!item.isOverdue(on: now, calendar: calendar))
    }

    @Test func completedItemIsNeverOverdue() {
        let now = date(2026, 10, 5, hour: 9)
        let item = TodoItem(title: "Done", isCompleted: true, dueDate: date(2026, 9, 1, hour: 9))

        #expect(!item.isOverdue(on: now, calendar: calendar))
    }

    @Test func itemWithoutDueDateIsNeverOverdue() {
        #expect(!TodoItem(title: "Someday").isOverdue())
    }

    // MARK: - Task Filter

    @Test func filterAllCases() {
        #expect(TaskFilter.allCases == [.all, .active, .completed])
    }

    @Test func filterRawValues() {
        #expect(TaskFilter.all.rawValue == "All")
        #expect(TaskFilter.active.rawValue == "Active")
        #expect(TaskFilter.completed.rawValue == "Completed")
        #expect(TaskFilter(rawValue: "Invalid") == nil)
    }

    @Test(arguments: [
        (TaskFilter.all, false, true),
        (TaskFilter.all, true, true),
        (TaskFilter.active, false, true),
        (TaskFilter.active, true, false),
        (TaskFilter.completed, false, false),
        (TaskFilter.completed, true, true)
    ])
    func filterIncludes(filter: TaskFilter, isCompleted: Bool, expected: Bool) {
        let item = TodoItem(title: "Task", isCompleted: isCompleted)

        #expect(filter.includes(item) == expected)
    }
}

// MARK: - Helpers

private extension TodoItemTests {
    func date(_ year: Int, _ month: Int, _ day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
