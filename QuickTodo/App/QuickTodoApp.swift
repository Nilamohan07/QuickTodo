//
//  QuickTodoApp.swift
//  QuickTodo
//
//  Created by Udhayanila on 29/01/25.
//

import SwiftUI

@main
struct QuickTodoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView(environment: appDelegate.environment, router: appDelegate.router)
                .onOpenURL { url in
                    appDelegate.router.handle(url)
                }
        }
    }
}
