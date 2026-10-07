//
//  NotificationCenterClient.swift
//  TodoReminders
//
//  Created by Udhayanila on 05/10/26.
//

import UserNotifications

/// The slice of `UNUserNotificationCenter` the scheduler needs, so it can be tested without the system.
public protocol NotificationCenterClient: Sendable {
    func authorizationStatus() async -> UNAuthorizationStatus
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func removeRequests(withIdentifiers identifiers: [String]) async
}

/// Forwards to `UNUserNotificationCenter.current()`.
public struct SystemNotificationCenter: NotificationCenterClient {
    public init() {}

    public func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    public func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }

    public func add(_ request: UNNotificationRequest) async throws {
        try await UNUserNotificationCenter.current().add(request)
    }

    public func removeRequests(withIdentifiers identifiers: [String]) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}
