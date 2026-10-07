//
//  DeepLinkTests.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
@testable import QuickTodo
import Testing

@Suite("Deep links")
struct DeepLinkTests {
    @Test(arguments: ["quicktodo://task/new", "QuickTodo://task/new", "quicktodo://TASK/New", "quicktodo://task/new/"])
    func parsesNewTask(_ string: String) throws {
        let url = try #require(URL(string: string))

        #expect(DeepLink(url: url) == .newTask)
    }

    @Test func parsesTaskID() throws {
        let id = UUID()
        let url = try #require(URL(string: "quicktodo://task/\(id.uuidString.lowercased())"))

        #expect(DeepLink(url: url) == .task(id))
    }

    @Test(arguments: [
        "https://task/new",
        "quicktodo://list/new",
        "quicktodo://task",
        "quicktodo://task/not-a-uuid",
        "quicktodo://task/new/extra"
    ])
    func rejectsUnsupportedURLs(_ string: String) throws {
        let url = try #require(URL(string: string))

        #expect(DeepLink(url: url) == nil)
    }

    @Test(arguments: [DeepLink.newTask, .task(UUID())])
    func urlRoundTrips(_ link: DeepLink) {
        #expect(DeepLink(url: link.url) == link)
    }
}
