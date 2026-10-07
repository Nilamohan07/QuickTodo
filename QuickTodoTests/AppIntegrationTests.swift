//
//  AppIntegrationTests.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
@testable import QuickTodo
import TaskListFeature
import Testing
import TodoDomain
import TodoPersistence

// Runs the real pieces together: view model, reminder syncing and an in-memory Core Data store.
@MainActor
@Suite("App integration")
struct AppIntegrationTests {
    @Test func addUpdateDeleteFlowWithCoreData() async throws {
        let reminders = RecordingReminders()
        let now = Date(timeIntervalSince1970: 1_791_450_000)
        let store = ReminderSyncingStore(
            wrapping: CoreDataTodoStore(stack: CoreDataStack(location: .inMemory)),
            reminders: reminders,
            dateProvider: .fixed(now)
        )
        let viewModel = TaskListViewModel(store: store, dateProvider: .fixed(now))

        var draft = viewModel.makeNewDraft()
        draft.title = "Original"
        draft.dueDate = now.addingTimeInterval(86_400 * 2)
        await viewModel.save(draft)
        let item = try #require(viewModel.items.first)
        #expect(await reminders.scheduledIDs == [item.id])

        var edited = TaskDraft(item: item)
        edited.title = "Updated"
        await viewModel.save(edited)
        #expect(viewModel.items.map(\.title) == ["Updated"])

        try await viewModel.delete(#require(viewModel.items.first))
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.presentedError == nil)
        #expect(await reminders.cancelledIDs == [item.id])
    }

    @Test func uiTestingEnvironmentIsSeededAndPinned() async throws {
        let environment = AppEnvironment.make(arguments: [AppEnvironment.uiTestingArgument])

        #expect(environment.isUITesting)
        #expect(environment.dateProvider.now == SampleData.referenceDate)
        #expect(try await environment.store.fetchItems().count == SampleData.items(relativeTo: .now).count)
    }
}

// MARK: - Recording Reminders

private actor RecordingReminders: ReminderScheduling {
    private(set) var scheduledIDs: [UUID] = []
    private(set) var cancelledIDs: [UUID] = []

    func schedule(_ reminder: Reminder) {
        scheduledIDs.append(reminder.taskID)
    }

    func cancelReminder(for taskID: UUID) {
        cancelledIDs.append(taskID)
    }
}
