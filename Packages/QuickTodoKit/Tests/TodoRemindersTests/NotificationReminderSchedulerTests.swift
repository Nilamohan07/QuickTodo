//
//  NotificationReminderSchedulerTests.swift
//  TodoRemindersTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import Testing
import TodoDomain
@testable import TodoReminders
import UserNotifications

@Suite("Notification reminder scheduler")
struct NotificationReminderSchedulerTests {
    private let reminder = Reminder(
        taskID: UUID(),
        title: "Renew passport",
        fireDate: Date(timeIntervalSince1970: 1_791_450_000)
    )

    @Test func schedulesWhenAuthorized() async throws {
        let center = FakeNotificationCenter(status: .authorized)
        let scheduler = NotificationReminderScheduler(center: center)

        await scheduler.schedule(reminder)

        let request = try #require(await center.addedRequests.first)
        #expect(request.identifier == reminder.taskID.uuidString)
        #expect(request.body == "Renew passport")
        #expect(request.taskID == reminder.taskID)
        #expect(await center.authorizationRequests == 0)
    }

    @Test func triggerMatchesFireDate() throws {
        let calendar = Calendar(identifier: .gregorian)
        let scheduler = NotificationReminderScheduler(center: FakeNotificationCenter(status: .authorized), calendar: calendar)

        let trigger = try #require(scheduler.makeRequest(for: reminder).trigger as? UNCalendarNotificationTrigger)

        #expect(calendar.date(from: trigger.dateComponents) == reminder.fireDate)
        #expect(!trigger.repeats)
    }

    @Test func asksForPermissionTheFirstTime() async {
        let center = FakeNotificationCenter(status: .notDetermined, grantsPermission: true)
        let scheduler = NotificationReminderScheduler(center: center)

        await scheduler.schedule(reminder)

        #expect(await center.authorizationRequests == 1)
        #expect(await center.addedRequests.count == 1)
    }

    @Test func skipsWhenPermissionIsRefused() async {
        let center = FakeNotificationCenter(status: .notDetermined, grantsPermission: false)
        let scheduler = NotificationReminderScheduler(center: center)

        await scheduler.schedule(reminder)

        #expect(await center.addedRequests.isEmpty)
    }

    @Test func skipsWhenDenied() async {
        let center = FakeNotificationCenter(status: .denied)
        let scheduler = NotificationReminderScheduler(center: center)

        await scheduler.schedule(reminder)

        #expect(await center.authorizationRequests == 0)
        #expect(await center.addedRequests.isEmpty)
    }

    @Test func cancelRemovesByTaskID() async {
        let center = FakeNotificationCenter(status: .authorized)
        let scheduler = NotificationReminderScheduler(center: center)

        await scheduler.cancelReminder(for: reminder.taskID)

        #expect(await center.removedIdentifiers == [reminder.taskID.uuidString])
    }

    @Test(arguments: [
        [NotificationReminderScheduler.taskIDKey: "not-a-uuid"],
        ["other": UUID().uuidString],
        [:]
    ] as [[String: String]])
    func ignoresForeignUserInfo(_ userInfo: [String: String]) {
        #expect(NotificationReminderScheduler.taskID(from: userInfo) == nil)
    }
}

// MARK: - Fake Notification Center

private actor FakeNotificationCenter: NotificationCenterClient {
    private let status: UNAuthorizationStatus
    private let grantsPermission: Bool

    private(set) var authorizationRequests = 0
    private(set) var addedRequests: [AddedRequest] = []
    private(set) var removedIdentifiers: [String] = []

    init(status: UNAuthorizationStatus, grantsPermission: Bool = false) {
        self.status = status
        self.grantsPermission = grantsPermission
    }

    func authorizationStatus() -> UNAuthorizationStatus {
        status
    }

    func requestAuthorization(options: UNAuthorizationOptions) -> Bool {
        authorizationRequests += 1
        return grantsPermission
    }

    // Requests aren't Sendable, so only the parts the tests look at cross into the actor.
    nonisolated func add(_ request: UNNotificationRequest) async {
        await record(AddedRequest(identifier: request.identifier, body: request.content.body, userInfo: request.content.userInfo))
    }

    private func record(_ request: AddedRequest) {
        addedRequests.append(request)
    }

    func removeRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers += identifiers
    }
}

private struct AddedRequest: Sendable {
    let identifier: String
    let body: String
    let taskID: UUID?

    init(identifier: String, body: String, userInfo: [AnyHashable: Any]) {
        self.identifier = identifier
        self.body = body
        taskID = NotificationReminderScheduler.taskID(from: userInfo)
    }
}
