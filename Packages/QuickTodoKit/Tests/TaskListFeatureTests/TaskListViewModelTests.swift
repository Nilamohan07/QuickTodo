//
//  TaskListViewModelTests.swift
//  TaskListFeatureTests
//
//  Created by Udhayanila on 09/03/26.
//

import Foundation
@testable import TaskListFeature
import Testing
import TodoDomain
import TodoTestSupport

@MainActor
@Suite("Task list view model")
struct TaskListViewModelTests {
    private let store = MockTodoStore()

    // MARK: - Loading

    @Test func loadsItems() async {
        let item = TodoItem(title: "Existing")
        await store.setItems([item])
        let viewModel = makeViewModel()

        await viewModel.loadItems()

        #expect(viewModel.items == [item])
        #expect(viewModel.visibleItems == [item])
    }

    @Test func reportsLoadedOnlyAfterFirstFetch() async {
        let viewModel = makeViewModel()
        #expect(!viewModel.hasLoaded)

        await viewModel.loadItems()

        #expect(viewModel.hasLoaded)
    }

    @Test func loadItemsPicksUpExternalChanges() async {
        let viewModel = makeViewModel()
        await viewModel.loadItems()

        await store.setItems([TodoItem(title: "Direct Insert")])
        await viewModel.loadItems()

        #expect(viewModel.items.map(\.title) == ["Direct Insert"])
    }

    @Test func fetchFailureIsPresented() async {
        await store.setFetchError(.fetchFailed)
        let viewModel = makeViewModel()

        await viewModel.loadItems()

        #expect(viewModel.presentedError == .fetchFailed)
        #expect(viewModel.isShowingError)
        #expect(viewModel.presentedError?.message == "Your tasks couldn't be loaded. Please try again.")
    }

    @Test func newDraftUsesTheInjectedDate() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let viewModel = TaskListViewModel(store: store, dateProvider: .fixed(now))

        #expect(viewModel.makeNewDraft().dueDate == now)
    }

    @Test func editDraftForUndatedItemUsesTheInjectedDate() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let viewModel = TaskListViewModel(store: store, dateProvider: .fixed(now))

        #expect(viewModel.makeDraft(for: TodoItem(title: "Undated")).dueDate == now)
    }

    @Test func overdueUsesTheInjectedDate() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let viewModel = TaskListViewModel(store: store, dateProvider: .fixed(now))

        #expect(viewModel.isOverdue(TodoItem(title: "Late", dueDate: now.addingTimeInterval(-3 * 86_400))))
        #expect(!viewModel.isOverdue(TodoItem(title: "Soon", dueDate: now.addingTimeInterval(86_400))))
    }

    // MARK: - Saving

    @Test func saveNewDraftAddsItem() async {
        let viewModel = makeViewModel()

        await viewModel.save(draft(title: "Buy milk", isCompleted: true))

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.title == "Buy milk")
        #expect(viewModel.items.first?.isCompleted == true)
        #expect(viewModel.items.first?.dueDate != nil)
    }

    @Test func saveTrimsTitle() async {
        let viewModel = makeViewModel()

        await viewModel.save(draft(title: "  Pay rent \n"))

        #expect(viewModel.items.first?.title == "Pay rent")
    }

    @Test func saveIgnoresBlankTitle() async {
        let viewModel = makeViewModel()

        await viewModel.save(draft(title: "   "))

        #expect(viewModel.items.isEmpty)
        #expect(await store.items.isEmpty)
    }

    @Test func saveEditedDraftUpdatesItem() async throws {
        let viewModel = makeViewModel()
        await viewModel.save(draft(title: "Old Title"))
        let item = try #require(viewModel.items.first)
        let newDate = Date().addingTimeInterval(86_400 * 7)

        var draft = TaskDraft(item: item)
        draft.title = "New Title"
        draft.dueDate = newDate
        draft.isCompleted = true
        await viewModel.save(draft)

        #expect(viewModel.items == [TodoItem(id: item.id, title: "New Title", isCompleted: true, dueDate: newDate)])
    }

    @Test func saveFailureIsPresentedAndKeepsItems() async {
        await store.setItems([TodoItem(title: "Existing")])
        let viewModel = makeViewModel()
        await viewModel.loadItems()
        await store.setSaveError(.saveFailed)

        await viewModel.save(draft(title: "Won't save"))

        #expect(viewModel.presentedError == .saveFailed)
        #expect(viewModel.items.map(\.title) == ["Existing"])
    }

    @Test func dismissingErrorClearsIt() async {
        await store.setFetchError(.fetchFailed)
        let viewModel = makeViewModel()
        await viewModel.loadItems()

        viewModel.isShowingError = false

        #expect(viewModel.presentedError == nil)
    }

    // MARK: - Toggling

    @Test func toggleCompletion() async throws {
        let viewModel = makeViewModel()
        await viewModel.save(draft(title: "Toggle Me"))

        await viewModel.toggleCompletion(of: try #require(viewModel.items.first))
        #expect(viewModel.items.first?.isCompleted == true)

        await viewModel.toggleCompletion(of: try #require(viewModel.items.first))
        #expect(viewModel.items.first?.isCompleted == false)
    }

    @Test func toggleMissingItemPresentsError() async {
        let viewModel = makeViewModel()

        await viewModel.toggleCompletion(of: TodoItem(title: "Ghost"))

        #expect(viewModel.presentedError == .itemNotFound)
    }

    @Test func remainingCountIgnoresCompletedItems() async {
        let viewModel = makeViewModel()
        await viewModel.save(draft(title: "One"))
        await viewModel.save(draft(title: "Two"))
        await viewModel.save(draft(title: "Done", isCompleted: true))

        #expect(viewModel.remainingCount == 2)
    }

    // MARK: - Deleting

    @Test func requestDeletionWaitsForConfirmation() async throws {
        let viewModel = makeViewModel()
        await viewModel.save(draft(title: "Delete Me"))
        let item = try #require(viewModel.items.first)

        viewModel.requestDeletion(of: item)

        #expect(viewModel.itemPendingDeletion == item)
        #expect(viewModel.isConfirmingDeletion)
        #expect(viewModel.items.count == 1)
    }

    @Test func cancellingDeletionKeepsItem() async throws {
        let viewModel = makeViewModel()
        await viewModel.save(draft(title: "Keep Me"))
        viewModel.requestDeletion(of: try #require(viewModel.items.first))

        viewModel.isConfirmingDeletion = false

        #expect(viewModel.itemPendingDeletion == nil)
        #expect(viewModel.items.count == 1)
    }

    @Test func deleteRemovesOnlyThatItem() async throws {
        let viewModel = makeViewModel()
        await viewModel.save(draft(title: "Keep Me"))
        await viewModel.save(draft(title: "Delete Me"))
        let item = try #require(viewModel.items.first { $0.title == "Delete Me" })

        viewModel.requestDeletion(of: item)
        await viewModel.delete(item)

        #expect(viewModel.items.map(\.title) == ["Keep Me"])
        #expect(viewModel.itemPendingDeletion == nil)
    }

    @Test func itemLookupByID() async throws {
        let viewModel = makeViewModel()
        await viewModel.save(draft(title: "Find Me"))
        let item = try #require(viewModel.items.first)

        #expect(viewModel.item(withID: item.id) == item)
        #expect(viewModel.item(withID: UUID()) == nil)
    }

    // MARK: - Filtering

    @Test(arguments: TaskFilter.allCases)
    func filterOnEmptyList(_ filter: TaskFilter) {
        let viewModel = makeViewModel()

        viewModel.selectedFilter = filter

        #expect(viewModel.visibleItems.isEmpty)
    }

    @Test func visibleItemsFollowSelectedFilter() async {
        let viewModel = makeViewModel()
        await viewModel.save(draft(title: "Active 1"))
        await viewModel.save(draft(title: "Active 2"))
        await viewModel.save(draft(title: "Done", isCompleted: true))

        #expect(viewModel.visibleItems.count == 3)

        viewModel.selectedFilter = .active
        #expect(Set(viewModel.visibleItems.map(\.title)) == ["Active 1", "Active 2"])

        viewModel.selectedFilter = .completed
        #expect(viewModel.visibleItems.map(\.title) == ["Done"])
    }

    @Test func visibleItemsRefreshAfterToggle() async throws {
        let viewModel = makeViewModel()
        await viewModel.save(draft(title: "Task A"))
        await viewModel.save(draft(title: "Task B"))
        viewModel.selectedFilter = .active

        await viewModel.toggleCompletion(of: try #require(viewModel.items.first { $0.title == "Task A" }))

        #expect(viewModel.visibleItems.map(\.title) == ["Task B"])
        viewModel.selectedFilter = .completed
        #expect(viewModel.visibleItems.map(\.title) == ["Task A"])
    }

    @Test func filterTitles() {
        #expect(TaskFilter.allCases.map(\.title) == ["All", "Active", "Completed"])
    }
}

// MARK: - Helpers

private extension TaskListViewModelTests {
    func makeViewModel() -> TaskListViewModel {
        TaskListViewModel(store: store)
    }

    func draft(title: String, isCompleted: Bool = false) -> TaskDraft {
        var draft = TaskDraft()
        draft.title = title
        draft.isCompleted = isCompleted
        return draft
    }
}
