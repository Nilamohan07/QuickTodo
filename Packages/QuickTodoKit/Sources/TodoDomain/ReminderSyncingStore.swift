//
//  ReminderSyncingStore.swift
//  TodoDomain
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation

/// Wraps a store and keeps each task's reminder in step with every write.
///
/// Anything that saves through this store, the list screen or an App Intent, gets the same
/// reminder behaviour without knowing reminders exist.
public struct ReminderSyncingStore: TodoStore {
    private let base: any TodoStore
    private let reminders: any ReminderScheduling
    private let dateProvider: DateProvider
    private let calendar: Calendar

    public init(
        wrapping base: any TodoStore,
        reminders: any ReminderScheduling,
        dateProvider: DateProvider = .system,
        calendar: Calendar = .current
    ) {
        self.base = base
        self.reminders = reminders
        self.dateProvider = dateProvider
        self.calendar = calendar
    }

    public func fetchItems() async throws -> [TodoItem] {
        try await base.fetchItems()
    }

    public func insert(_ item: TodoItem) async throws {
        try await base.insert(item)
        await syncReminder(for: item)
    }

    public func update(_ item: TodoItem) async throws {
        try await base.update(item)
        await syncReminder(for: item)
    }

    public func delete(id: UUID) async throws {
        try await base.delete(id: id)
        await reminders.cancelReminder(for: id)
    }
}

// MARK: - Helpers

private extension ReminderSyncingStore {
    func syncReminder(for item: TodoItem) async {
        if let reminder = Reminder(for: item, now: dateProvider.now, calendar: calendar) {
            await reminders.schedule(reminder)
        } else {
            await reminders.cancelReminder(for: item.id)
        }
    }
}
