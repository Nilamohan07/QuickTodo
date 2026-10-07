//
//  AppEnvironment.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import TodoDomain
import TodoPersistence
import TodoReminders

/// Every dependency the app needs, built once at launch and passed down explicitly.
final class AppEnvironment: Sendable {
    let store: any TodoStore
    let dateProvider: DateProvider
    let isUITesting: Bool

    init(store: any TodoStore, dateProvider: DateProvider, isUITesting: Bool = false) {
        self.store = store
        self.dateProvider = dateProvider
        self.isUITesting = isUITesting
    }
}

// MARK: - Variants

extension AppEnvironment {
    static let uiTestingArgument = "-ui-testing"

    static func make(arguments: [String]) -> AppEnvironment {
        arguments.contains(uiTestingArgument) ? .uiTesting() : .live()
    }

    /// The on-disk store, with reminders kept in sync on every write.
    static func live() -> AppEnvironment {
        let stack = CoreDataStack()
        let store = ReminderSyncingStore(
            wrapping: CoreDataTodoStore(stack: stack),
            reminders: NotificationReminderScheduler(),
            dateProvider: .system
        )
        return AppEnvironment(store: store, dateProvider: .system)
    }

    /// A fresh in-memory Core Data store with known tasks and a fixed date, so UI tests
    /// see the same screen on every run. Reminders are off to keep the permission prompt away.
    static func uiTesting() -> AppEnvironment {
        let now = SampleData.referenceDate
        let stack = CoreDataStack(location: .inMemory)
        stack.preload(SampleData.items(relativeTo: now))
        return AppEnvironment(store: CoreDataTodoStore(stack: stack), dateProvider: .fixed(now), isUITesting: true)
    }

    static func preview() -> AppEnvironment {
        let now = Date.now
        return AppEnvironment(store: InMemoryTodoStore(items: SampleData.items(relativeTo: now)), dateProvider: .fixed(now))
    }
}

// MARK: - Sample Data

enum SampleData {
    /// 1 October 2026, 10:00 in the current time zone.
    static var referenceDate: Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 10)) ?? .now
    }

    static func items(relativeTo now: Date) -> [TodoItem] {
        let day: TimeInterval = 86_400
        return [
            TodoItem(title: "Buy groceries", dueDate: now.addingTimeInterval(day)),
            TodoItem(title: "Pay rent", dueDate: now.addingTimeInterval(-2 * day)),
            TodoItem(title: "Book dentist", isCompleted: true, dueDate: now.addingTimeInterval(3 * day))
        ]
    }
}
