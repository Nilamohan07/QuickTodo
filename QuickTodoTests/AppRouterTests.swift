//
//  AppRouterTests.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
@testable import QuickTodo
import Testing

@MainActor
@Suite("App router")
struct AppRouterTests {
    private let router = AppRouter()

    @Test func newTaskLinkPresentsEditor() {
        router.handle(.newTask)

        #expect(router.sheet == .newTask)
    }

    @Test func taskLinkPresentsThatTask() {
        let id = UUID()

        router.handle(.task(id))

        #expect(router.sheet == .editTask(id))
    }

    @Test func urlIsParsedAndRouted() throws {
        let id = UUID()

        router.handle(try #require(URL(string: "quicktodo://task/\(id.uuidString)")))

        #expect(router.sheet == .editTask(id))
    }

    @Test func unsupportedURLLeavesCurrentSheet() throws {
        router.present(.newTask)

        router.handle(try #require(URL(string: "quicktodo://settings")))

        #expect(router.sheet == .newTask)
    }

    @Test func dismissClearsSheet() {
        router.present(.newTask)

        router.dismissSheet()

        #expect(router.sheet == nil)
    }
}
