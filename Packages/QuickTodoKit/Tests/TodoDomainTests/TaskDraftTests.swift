//
//  TaskDraftTests.swift
//  TodoDomainTests
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import Testing
import TodoDomain

@Suite("Task draft")
struct TaskDraftTests {
    @Test func newDraftDefaults() {
        let now = Date()
        let draft = TaskDraft(defaultDueDate: now)

        #expect(draft.id == nil)
        #expect(!draft.isEditing)
        #expect(draft.title == "")
        #expect(draft.dueDate == now)
        #expect(!draft.isCompleted)
    }

    @Test func draftFromExistingItem() {
        let dueDate = Date().addingTimeInterval(86_400)
        let item = TodoItem(title: "Call mum", isCompleted: true, dueDate: dueDate)
        let draft = TaskDraft(item: item)

        #expect(draft.id == item.id)
        #expect(draft.isEditing)
        #expect(draft.title == "Call mum")
        #expect(draft.dueDate == dueDate)
        #expect(draft.isCompleted)
    }

    @Test func itemWithoutDueDateFallsBackToDefault() {
        let fallback = Date(timeIntervalSince1970: 0)
        let draft = TaskDraft(item: TodoItem(title: "Someday"), defaultDueDate: fallback)

        #expect(draft.dueDate == fallback)
    }

    @Test(arguments: ["", "   ", " \n\t "])
    func blankTitlesAreInvalid(_ title: String) {
        var draft = TaskDraft()
        draft.title = title

        #expect(!draft.isValid)
        #expect(draft.makeItem() == nil)
    }

    @Test func validTitleIsTrimmed() {
        var draft = TaskDraft()
        draft.title = "  Water plants  "

        #expect(draft.isValid)
        #expect(draft.trimmedTitle == "Water plants")
    }

    @Test func makeItemForNewDraft() throws {
        let dueDate = Date(timeIntervalSince1970: 1000)
        var draft = TaskDraft(defaultDueDate: dueDate)
        draft.title = " Pay rent \n"
        draft.isCompleted = true

        let item = try #require(draft.makeItem())

        #expect(item.title == "Pay rent")
        #expect(item.dueDate == dueDate)
        #expect(item.isCompleted)
    }

    @Test func makeItemKeepsIDWhenEditing() throws {
        let original = TodoItem(title: "Original")
        var draft = TaskDraft(item: original)
        draft.title = "Renamed"

        let item = try #require(draft.makeItem())

        #expect(item.id == original.id)
        #expect(item.title == "Renamed")
    }
}
