//
//  AppDelegate.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import AppIntents
import TodoReminders
import UIKit
import UserNotifications

/// Owns the composition root. It lives here rather than in the `App` struct because notification
/// taps can arrive before any view exists, and both need the same router.
final class AppDelegate: NSObject, UIApplicationDelegate {
    let environment: AppEnvironment
    let router = AppRouter()

    override init() {
        let environment = AppEnvironment.make(arguments: ProcessInfo.processInfo.arguments)
        self.environment = environment
        super.init()

        AppDependencyManager.shared.add(dependency: environment)
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        if environment.isUITesting {
            UIView.setAnimationsEnabled(false)
        }
        return true
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        guard let taskID = NotificationReminderScheduler.taskID(from: userInfo) else { return }

        await router.handle(.task(taskID))
    }
}
