//
//  AppRouter.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import Observation
import os

/// App-level navigation state. Everything that can be on screen is described here as data,
/// so deep links, notifications and taps all go through the same path.
@MainActor
@Observable
final class AppRouter {
    enum Sheet: Hashable, Identifiable {
        case newTask
        case editTask(UUID)

        var id: Self { self }
    }

    var sheet: Sheet?

    @ObservationIgnored private let logger = Logger(subsystem: "com.udhayanila.in.QuickTodo", category: "Navigation")

    func present(_ sheet: Sheet) {
        self.sheet = sheet
    }

    func dismissSheet() {
        sheet = nil
    }

    func handle(_ link: DeepLink) {
        switch link {
        case .newTask:
            present(.newTask)
        case .task(let id):
            present(.editTask(id))
        }
    }

    func handle(_ url: URL) {
        guard let link = DeepLink(url: url) else {
            logger.notice("Ignoring unsupported URL \(url.absoluteString, privacy: .public)")
            return
        }
        handle(link)
    }
}
