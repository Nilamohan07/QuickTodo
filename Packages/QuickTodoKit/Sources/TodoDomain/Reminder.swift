//
//  Reminder.swift
//  TodoDomain
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation

// MARK: - Reminder

/// A due-date reminder for a single task.
public struct Reminder: Hashable, Sendable {
    /// Tasks only carry a day, so the reminder goes off at this hour on that day.
    public static let defaultHour = 9

    public let taskID: UUID
    public let title: String
    public let fireDate: Date

    public init(taskID: UUID, title: String, fireDate: Date) {
        self.taskID = taskID
        self.title = title
        self.fireDate = fireDate
    }

    /// The reminder an item should have right now, or `nil` if it shouldn't have one:
    /// it's completed, has no due date, or the reminder time has already passed.
    public init?(
        for item: TodoItem,
        now: Date,
        hour: Int = Reminder.defaultHour,
        calendar: Calendar = .current
    ) {
        guard
            !item.isCompleted,
            let dueDate = item.dueDate,
            let fireDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dueDate),
            fireDate > now
        else {
            return nil
        }

        self.init(taskID: item.id, title: item.title, fireDate: fireDate)
    }
}

// MARK: - Reminder Scheduling

/// Schedules and cancels reminders. Scheduling the same task again replaces its pending reminder.
///
/// Reminders are best effort, so implementations log failures instead of throwing them at callers.
public protocol ReminderScheduling: Sendable {
    func schedule(_ reminder: Reminder) async
    func cancelReminder(for taskID: UUID) async
}
