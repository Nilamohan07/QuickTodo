//
//  AddTaskIntentTests.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
@testable import QuickTodo
import Testing
import TodoDomain

@Suite("Add task intent")
struct AddTaskIntentTests {
    private let now = Date(timeIntervalSince1970: 1_791_450_000)
    private let store = InMemoryTodoStore()

    private var environment: AppEnvironment {
        AppEnvironment(store: store, dateProvider: .fixed(now))
    }

    @Test func addsTrimmedTaskDueToday() async throws {
        let intent = AddTaskIntent()
        intent.taskTitle = "  Buy stamps "

        let item = try await intent.addTask(using: environment)

        #expect(item.title == "Buy stamps")
        #expect(item.dueDate == now)
        #expect(await store.fetchItems() == [item])
    }

    @Test func usesGivenDueDate() async throws {
        let dueDate = now.addingTimeInterval(86_400 * 2)
        let intent = AddTaskIntent()
        intent.taskTitle = "Renew passport"
        intent.dueDate = dueDate

        let item = try await intent.addTask(using: environment)

        #expect(item.dueDate == dueDate)
    }

    @Test func rejectsBlankTitle() async {
        let intent = AddTaskIntent()
        intent.taskTitle = "   "

        await #expect(throws: AddTaskIntentError.emptyTitle) {
            try await intent.addTask(using: environment)
        }
        #expect(await store.fetchItems().isEmpty)
    }
}
