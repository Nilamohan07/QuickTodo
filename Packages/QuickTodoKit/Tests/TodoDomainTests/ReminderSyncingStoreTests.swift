//
//  ReminderSyncingStoreTests.swift
//  TodoDomainTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import Testing
import TodoDomain
import TodoTestSupport

@Suite("Reminder syncing store")
struct ReminderSyncingStoreTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let base = MockTodoStore()
    private let reminders = MockReminderScheduler()

    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 10))!
    }

    private var tomorrow: Date {
        now.addingTimeInterval(86_400)
    }

    @Test func insertWithFutureDueDateSchedules() async throws {
        let item = TodoItem(title: "Call bank", dueDate: tomorrow)

        try await makeStore().insert(item)

        let reminder = try #require(await reminders.scheduled[item.id])
        #expect(reminder.title == "Call bank")
        #expect(await base.items == [item])
    }

    @Test func insertWithoutDueDateDoesNotSchedule() async throws {
        let item = TodoItem(title: "Someday")

        try await makeStore().insert(item)

        #expect(await reminders.scheduled.isEmpty)
    }

    @Test func editingDueDateReschedules() async throws {
        let store = makeStore()
        var item = TodoItem(title: "Report", dueDate: tomorrow)
        try await store.insert(item)

        item.dueDate = tomorrow.addingTimeInterval(86_400)
        try await store.update(item)

        let reminder = try #require(await reminders.scheduled[item.id])
        #expect(calendar.isDate(reminder.fireDate, inSameDayAs: tomorrow.addingTimeInterval(86_400)))
    }

    @Test func completingCancels() async throws {
        let store = makeStore()
        var item = TodoItem(title: "Report", dueDate: tomorrow)
        try await store.insert(item)

        item.isCompleted = true
        try await store.update(item)

        #expect(await reminders.scheduled[item.id] == nil)
        #expect(await reminders.cancelledIDs == [item.id])
    }

    @Test func deletingCancels() async throws {
        let store = makeStore()
        let item = TodoItem(title: "Report", dueDate: tomorrow)
        try await store.insert(item)

        try await store.delete(id: item.id)

        #expect(await reminders.scheduled.isEmpty)
        #expect(await reminders.cancelledIDs == [item.id])
    }

    @Test func failedWriteLeavesRemindersAlone() async {
        await base.setSaveError(.saveFailed)
        let item = TodoItem(title: "Report", dueDate: tomorrow)

        await #expect(throws: TodoStoreError.saveFailed) {
            try await makeStore().insert(item)
        }
        #expect(await reminders.scheduled.isEmpty)
        #expect(await reminders.cancelledIDs.isEmpty)
    }

    @Test func fetchPassesThrough() async throws {
        let item = TodoItem(title: "Existing")
        await base.setItems([item])

        #expect(try await makeStore().fetchItems() == [item])
    }
}

// MARK: - Helpers

private extension ReminderSyncingStoreTests {
    func makeStore() -> ReminderSyncingStore {
        ReminderSyncingStore(wrapping: base, reminders: reminders, dateProvider: .fixed(now), calendar: calendar)
    }
}
