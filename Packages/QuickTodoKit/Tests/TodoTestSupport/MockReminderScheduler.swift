//
//  MockReminderScheduler.swift
//  TodoTestSupport
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import TodoDomain

/// Records what would have been scheduled, keyed by task like the real scheduler.
public actor MockReminderScheduler: ReminderScheduling {
    public private(set) var scheduled: [UUID: Reminder] = [:]
    public private(set) var cancelledIDs: [UUID] = []

    public init() {}

    public func schedule(_ reminder: Reminder) {
        scheduled[reminder.taskID] = reminder
    }

    public func cancelReminder(for taskID: UUID) {
        scheduled[taskID] = nil
        cancelledIDs.append(taskID)
    }
}
