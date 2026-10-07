//
//  ReminderTests.swift
//  TodoDomainTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import Testing
import TodoDomain

@Suite("Reminder timing")
struct ReminderTests {
    private let calendar = Calendar(identifier: .gregorian)

    @Test func firesAtNineOnTheDueDay() throws {
        let item = TodoItem(title: "Dentist", dueDate: date(2026, 10, 9, hour: 15))

        let reminder = try #require(Reminder(for: item, now: date(2026, 10, 8, hour: 20), calendar: calendar))

        #expect(reminder.taskID == item.id)
        #expect(reminder.title == "Dentist")
        #expect(reminder.fireDate == date(2026, 10, 9, hour: 9))
    }

    @Test func honoursCustomHour() throws {
        let item = TodoItem(title: "Gym", dueDate: date(2026, 10, 9, hour: 0))

        let reminder = try #require(Reminder(for: item, now: date(2026, 10, 8, hour: 8), hour: 7, calendar: calendar))

        #expect(reminder.fireDate == date(2026, 10, 9, hour: 7))
    }

    @Test func noReminderOnceTheTimeHasPassed() {
        let item = TodoItem(title: "Today", dueDate: date(2026, 10, 8, hour: 0))

        #expect(Reminder(for: item, now: date(2026, 10, 8, hour: 10), calendar: calendar) == nil)
    }

    @Test func noReminderForCompletedTask() {
        let item = TodoItem(title: "Done", isCompleted: true, dueDate: date(2026, 12, 1, hour: 0))

        #expect(Reminder(for: item, now: date(2026, 10, 8, hour: 10), calendar: calendar) == nil)
    }

    @Test func noReminderWithoutDueDate() {
        #expect(Reminder(for: TodoItem(title: "Someday"), now: .now, calendar: calendar) == nil)
    }
}

// MARK: - Helpers

private extension ReminderTests {
    func date(_ year: Int, _ month: Int, _ day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
