//
//  NotificationReminderScheduler.swift
//  TodoReminders
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import os
import TodoDomain
import UserNotifications

/// Schedules reminders as local notifications, one per task, keyed by the task id.
public struct NotificationReminderScheduler: ReminderScheduling {
    /// The `userInfo` key that carries the task id, read back when a notification is tapped.
    public static let taskIDKey = "taskID"

    private let center: any NotificationCenterClient
    private let calendar: Calendar
    private let logger = Logger(subsystem: "com.udhayanila.in.QuickTodo", category: "Reminders")

    public init(center: any NotificationCenterClient = SystemNotificationCenter(), calendar: Calendar = .current) {
        self.center = center
        self.calendar = calendar
    }

    public func schedule(_ reminder: Reminder) async {
        guard await isAuthorized() else { return }

        do {
            try await center.add(makeRequest(for: reminder))
        } catch {
            logger.error("Scheduling reminder for \(reminder.taskID) failed: \(error.localizedDescription)")
        }
    }

    public func cancelReminder(for taskID: UUID) async {
        await center.removeRequests(withIdentifiers: [taskID.uuidString])
    }

    /// The task a delivered notification belongs to, if it's one of ours.
    public static func taskID(from userInfo: [AnyHashable: Any]) -> UUID? {
        (userInfo[taskIDKey] as? String).flatMap(UUID.init(uuidString:))
    }
}

// MARK: - Helpers

extension NotificationReminderScheduler {
    func makeRequest(for reminder: Reminder) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Due Today", bundle: .module)
        content.body = reminder.title
        content.sound = .default
        content.userInfo = [Self.taskIDKey: reminder.taskID.uuidString]

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        return UNNotificationRequest(identifier: reminder.taskID.uuidString, content: content, trigger: trigger)
    }
}

private extension NotificationReminderScheduler {
    // Permission is asked for the first time a task actually needs a reminder, not at launch,
    // so the prompt shows up right after the user has done something it relates to.
    func isAuthorized() async -> Bool {
        switch await center.authorizationStatus() {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound])
            } catch {
                logger.error("Requesting notification permission failed: \(error.localizedDescription)")
                return false
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }
}
