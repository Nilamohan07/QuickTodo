//
//  TaskDraftTests.swift
//  QuickTodoTests
//
//  Created by Udhayanila on 05/10/26.
//

import XCTest
@testable import QuickTodo

final class TaskDraftTests: XCTestCase {

    func testNewDraftDefaults() {
        let now = Date()
        let draft = TaskDraft(defaultDueDate: now)

        XCTAssertNil(draft.id)
        XCTAssertFalse(draft.isEditing)
        XCTAssertEqual(draft.title, "")
        XCTAssertEqual(draft.dueDate, now)
        XCTAssertFalse(draft.isCompleted)
    }

    func testDraftFromExistingItem() {
        let dueDate = Date().addingTimeInterval(86_400)
        let item = TodoItem(title: "Call mum", isCompleted: true, dueDate: dueDate)
        let draft = TaskDraft(item: item)

        XCTAssertEqual(draft.id, item.id)
        XCTAssertTrue(draft.isEditing)
        XCTAssertEqual(draft.title, "Call mum")
        XCTAssertEqual(draft.dueDate, dueDate)
        XCTAssertTrue(draft.isCompleted)
    }

    func testItemWithoutDueDateFallsBackToDefault() {
        let fallback = Date(timeIntervalSince1970: 0)
        let draft = TaskDraft(item: TodoItem(title: "Someday"), defaultDueDate: fallback)

        XCTAssertEqual(draft.dueDate, fallback)
    }

    func testValidation() {
        var draft = TaskDraft()
        XCTAssertFalse(draft.isValid)

        draft.title = "   \n"
        XCTAssertFalse(draft.isValid)

        draft.title = "  Water plants  "
        XCTAssertTrue(draft.isValid)
        XCTAssertEqual(draft.trimmedTitle, "Water plants")
    }
}
