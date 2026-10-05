//
//  TaskViewModelTests.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 09/03/26.
//

import XCTest
@testable import QuickTodo

@MainActor
final class TaskViewModelTests: XCTestCase {

    // MARK: - Loading

    func testLoadsItemsOnInit() {
        let item = TodoItem(title: "Existing")
        let viewModel = TaskViewModel(store: MockTodoStore(items: [item]))

        XCTAssertEqual(viewModel.items, [item])
        XCTAssertEqual(viewModel.visibleItems, [item])
    }

    func testLoadItemsPicksUpExternalChanges() {
        let store = MockTodoStore()
        let viewModel = TaskViewModel(store: store)

        store.items = [TodoItem(title: "Direct Insert")]
        viewModel.loadItems()

        XCTAssertEqual(viewModel.items.map(\.title), ["Direct Insert"])
    }

    func testFetchFailureIsPresented() {
        let store = MockTodoStore()
        store.fetchError = .fetchFailed

        let viewModel = TaskViewModel(store: store)

        XCTAssertEqual(viewModel.presentedError, .fetchFailed)
        XCTAssertTrue(viewModel.isShowingError)
    }

    // MARK: - Saving

    func testSaveNewDraftAddsItem() {
        let viewModel = makeViewModel()
        var draft = TaskDraft()
        draft.title = "Buy milk"
        draft.isCompleted = true

        viewModel.save(draft)

        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.title, "Buy milk")
        XCTAssertEqual(viewModel.items.first?.isCompleted, true)
        XCTAssertNotNil(viewModel.items.first?.dueDate)
    }

    func testSaveTrimsTitle() {
        let viewModel = makeViewModel()
        var draft = TaskDraft()
        draft.title = "  Pay rent \n"

        viewModel.save(draft)

        XCTAssertEqual(viewModel.items.first?.title, "Pay rent")
    }

    func testSaveIgnoresBlankTitle() {
        let viewModel = makeViewModel()
        var draft = TaskDraft()
        draft.title = "   "

        viewModel.save(draft)

        XCTAssertTrue(viewModel.items.isEmpty)
    }

    func testSaveEditedDraftUpdatesItem() throws {
        let viewModel = makeViewModel()
        viewModel.save(draft(title: "Old Title"))
        let item = try XCTUnwrap(viewModel.items.first)
        let newDate = Date().addingTimeInterval(86_400 * 7)

        var draft = TaskDraft(item: item)
        draft.title = "New Title"
        draft.dueDate = newDate
        draft.isCompleted = true
        viewModel.save(draft)

        XCTAssertEqual(viewModel.items, [TodoItem(id: item.id, title: "New Title", isCompleted: true, dueDate: newDate)])
    }

    func testSaveFailureIsPresentedAndKeepsItems() {
        let store = MockTodoStore(items: [TodoItem(title: "Existing")])
        let viewModel = TaskViewModel(store: store)
        store.saveError = .saveFailed

        viewModel.save(draft(title: "Won't save"))

        XCTAssertEqual(viewModel.presentedError, .saveFailed)
        XCTAssertEqual(viewModel.items.map(\.title), ["Existing"])
    }

    func testDismissingErrorClearsIt() {
        let store = MockTodoStore()
        store.fetchError = .fetchFailed
        let viewModel = TaskViewModel(store: store)

        viewModel.isShowingError = false

        XCTAssertNil(viewModel.presentedError)
    }

    // MARK: - Toggling

    func testToggleCompletion() throws {
        let viewModel = makeViewModel()
        viewModel.save(draft(title: "Toggle Me"))
        let item = try XCTUnwrap(viewModel.items.first)

        viewModel.toggleCompletion(of: item)
        XCTAssertEqual(viewModel.items.first?.isCompleted, true)

        viewModel.toggleCompletion(of: try XCTUnwrap(viewModel.items.first))
        XCTAssertEqual(viewModel.items.first?.isCompleted, false)
    }

    func testToggleMissingItemPresentsError() {
        let viewModel = makeViewModel()

        viewModel.toggleCompletion(of: TodoItem(title: "Ghost"))

        XCTAssertEqual(viewModel.presentedError, .itemNotFound)
    }

    // MARK: - Deleting

    func testRequestDeletionWaitsForConfirmation() throws {
        let viewModel = makeViewModel()
        viewModel.save(draft(title: "Delete Me"))
        let item = try XCTUnwrap(viewModel.items.first)

        viewModel.requestDeletion(of: item)

        XCTAssertEqual(viewModel.itemPendingDeletion, item)
        XCTAssertTrue(viewModel.isConfirmingDeletion)
        XCTAssertEqual(viewModel.items.count, 1)
    }

    func testCancellingDeletionKeepsItem() throws {
        let viewModel = makeViewModel()
        viewModel.save(draft(title: "Keep Me"))
        viewModel.requestDeletion(of: try XCTUnwrap(viewModel.items.first))

        viewModel.isConfirmingDeletion = false

        XCTAssertNil(viewModel.itemPendingDeletion)
        XCTAssertEqual(viewModel.items.count, 1)
    }

    func testDeleteRemovesOnlyThatItem() throws {
        let viewModel = makeViewModel()
        viewModel.save(draft(title: "Keep Me"))
        viewModel.save(draft(title: "Delete Me"))
        let item = try XCTUnwrap(viewModel.items.first { $0.title == "Delete Me" })

        viewModel.requestDeletion(of: item)
        viewModel.delete(item)

        XCTAssertEqual(viewModel.items.map(\.title), ["Keep Me"])
        XCTAssertNil(viewModel.itemPendingDeletion)
    }

    // MARK: - Filtering

    func testFilterOnEmptyList() {
        let viewModel = makeViewModel()

        for filter in TaskFilter.allCases {
            viewModel.selectedFilter = filter
            XCTAssertTrue(viewModel.visibleItems.isEmpty)
        }
    }

    func testVisibleItemsFollowSelectedFilter() {
        let viewModel = makeViewModel()
        viewModel.save(draft(title: "Active 1"))
        viewModel.save(draft(title: "Active 2"))
        viewModel.save(draft(title: "Done", isCompleted: true))

        XCTAssertEqual(viewModel.visibleItems.count, 3)

        viewModel.selectedFilter = .active
        XCTAssertEqual(Set(viewModel.visibleItems.map(\.title)), ["Active 1", "Active 2"])

        viewModel.selectedFilter = .completed
        XCTAssertEqual(viewModel.visibleItems.map(\.title), ["Done"])
    }

    func testVisibleItemsRefreshAfterToggle() throws {
        let viewModel = makeViewModel()
        viewModel.save(draft(title: "Task A"))
        viewModel.save(draft(title: "Task B"))
        viewModel.selectedFilter = .active

        viewModel.toggleCompletion(of: try XCTUnwrap(viewModel.items.first { $0.title == "Task A" }))

        XCTAssertEqual(viewModel.visibleItems.map(\.title), ["Task B"])
        viewModel.selectedFilter = .completed
        XCTAssertEqual(viewModel.visibleItems.map(\.title), ["Task A"])
    }

    // MARK: - Core Data Integration

    func testAddUpdateDeleteFlowWithCoreData() throws {
        let store = CoreDataTodoStore(context: CoreDataManager(inMemory: true).viewContext)
        let viewModel = TaskViewModel(store: store)

        viewModel.save(draft(title: "Original"))
        var edited = TaskDraft(item: try XCTUnwrap(viewModel.items.first))
        edited.title = "Updated"
        viewModel.save(edited)
        XCTAssertEqual(viewModel.items.map(\.title), ["Updated"])

        viewModel.delete(try XCTUnwrap(viewModel.items.first))
        XCTAssertTrue(viewModel.items.isEmpty)
        XCTAssertNil(viewModel.presentedError)
    }
}

// MARK: - Helpers

private extension TaskViewModelTests {
    func makeViewModel() -> TaskViewModel {
        TaskViewModel(store: MockTodoStore())
    }

    func draft(title: String, isCompleted: Bool = false) -> TaskDraft {
        var draft = TaskDraft()
        draft.title = title
        draft.isCompleted = isCompleted
        return draft
    }
}
