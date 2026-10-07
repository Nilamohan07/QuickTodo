//
//  TaskFlowUITests.swift
//  QuickTodoUITests
//
//  Created by Udhayanila on 05/10/26.
//

import XCTest

// Runs against the -ui-testing launch mode: an in-memory store seeded with three tasks
// ("Buy groceries", "Pay rent", completed "Book dentist") and a fixed date.
@MainActor
final class TaskFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
    }

    func testSeededTasksAreListed() {
        XCTAssertTrue(row("Buy groceries").waitForExistence(timeout: 5))
        XCTAssertTrue(row("Pay rent").exists)
        XCTAssertTrue(row("Book dentist").exists)
        XCTAssertTrue(app.staticTexts["2 tasks remaining"].exists)
    }

    func testAddTask() {
        // The add button is on screen before the first load finishes, so wait for the list.
        XCTAssertTrue(row("Buy groceries").waitForExistence(timeout: 5))
        app.buttons["taskList.add"].tap()

        let titleField = app.textFields["taskEditor.title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.typeText("Water plants")
        app.buttons["taskEditor.save"].tap()

        XCTAssertTrue(row("Water plants").waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["3 tasks remaining"].waitForExistence(timeout: 5))
    }

    func testCompleteTask() {
        let groceries = row("Buy groceries")
        XCTAssertTrue(groceries.waitForExistence(timeout: 5))

        groceries.tap()

        XCTAssertTrue(app.staticTexts["1 task remaining"].waitForExistence(timeout: 5))

        app.segmentedControls["taskList.filter"].buttons["Completed"].tap()
        XCTAssertTrue(row("Buy groceries").waitForExistence(timeout: 5))
        XCTAssertFalse(row("Pay rent").exists)
    }

    func testDeleteTask() {
        let rent = row("Pay rent")
        XCTAssertTrue(rent.waitForExistence(timeout: 5))

        rent.swipeLeft()
        let swipeDelete = app.buttons["Delete"].firstMatch
        XCTAssertTrue(swipeDelete.waitForExistence(timeout: 5))
        swipeDelete.tap()

        let alert = app.alerts["Delete Task?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["Delete"].tap()

        XCTAssertTrue(rent.waitForNonExistence(timeout: 5))
        XCTAssertTrue(row("Buy groceries").exists)
    }

    func testCancelledEditorKeepsList() {
        XCTAssertTrue(row("Buy groceries").waitForExistence(timeout: 5))
        app.buttons["taskList.add"].tap()
        XCTAssertTrue(app.textFields["taskEditor.title"].waitForExistence(timeout: 5))

        app.buttons["taskEditor.cancel"].tap()

        XCTAssertTrue(row("Buy groceries").waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["2 tasks remaining"].exists)
    }
}

// MARK: - Helpers

private extension TaskFlowUITests {
    func row(_ title: String) -> XCUIElement {
        app.buttons["taskRow.\(title)"]
    }
}
