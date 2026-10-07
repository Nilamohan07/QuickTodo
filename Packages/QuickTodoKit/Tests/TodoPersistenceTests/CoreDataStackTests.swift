//
//  CoreDataStackTests.swift
//  TodoPersistenceTests
//
//  Created by Udhayanila on 09/03/26.
//

import CoreData
import Foundation
import Testing
import TodoDomain
@testable import TodoPersistence

// The view context is main-queue bound, so these run on the main actor.
@MainActor
@Suite("Core Data stack")
struct CoreDataStackTests {

    // MARK: - Core Data Entity

    @Test func saveTaskDetails() throws {
        let context = makeContext()
        insertRecord(title: "Test Task", in: context)

        try context.save()
    }

    @Test func fetchTaskDetails() throws {
        let context = makeContext()
        insertRecord(title: "Fetch Me", isCompleted: true, in: context)
        try context.save()

        let results = try context.fetch(TaskDetails.fetchRequest())

        #expect(results.count == 1)
        #expect(results.first?.title == "Fetch Me")
        #expect(results.first?.isCompleted == true)
    }

    @Test func updateTaskDetails() throws {
        let context = makeContext()
        let record = insertRecord(title: "Original", in: context)
        try context.save()

        record.title = "Updated"
        record.isCompleted = true
        try context.save()

        let results = try context.fetch(TaskDetails.fetchRequest())

        #expect(results.count == 1)
        #expect(results.first?.title == "Updated")
        #expect(results.first?.isCompleted == true)
    }

    @Test func deleteTaskDetails() throws {
        let context = makeContext()
        let record = insertRecord(title: "Delete Me", in: context)
        try context.save()

        context.delete(record)
        try context.save()

        #expect(try context.fetch(TaskDetails.fetchRequest()).isEmpty)
    }

    @Test func taskDetailsDefaultValues() {
        let record = TaskDetails(context: makeContext())

        #expect(record.id == nil)
        #expect(record.title == nil)
        #expect(!record.isCompleted)
        #expect(record.dueDate == nil)
    }

    // MARK: - Core Data Stack

    @Test func modelIsLoadedOnceAndMatchesTheShippedSchema() throws {
        let entity = try #require(CoreDataStack.model.entitiesByName[TaskDetails.entityName])

        #expect(CoreDataStack.model === CoreDataStack.model)
        #expect(entity.managedObjectClassName == "TaskDetails")
        #expect(Set(entity.attributesByName.keys) == ["id", "title", "isCompleted", "dueDate"])
    }

    // Moving the model into a package must not move existing users' data.
    @Test func defaultStoreURLMatchesWhereTheContainerUsedToPutIt() throws {
        let legacy = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: CoreDataStack.model)
        let legacyURL = try #require(legacy.persistentStoreDescriptions.first?.url)

        #expect(CoreDataStack.defaultStoreURL.standardizedFileURL == legacyURL.standardizedFileURL)
        #expect(CoreDataStack.defaultStoreURL.lastPathComponent == "TaskDetailsDataModel.sqlite")
    }

    @Test func storeIsConfiguredForLightweightMigration() throws {
        let description = try #require(CoreDataStack(location: .inMemory).container.persistentStoreDescriptions.first)

        #expect(description.shouldMigrateStoreAutomatically)
        #expect(description.shouldInferMappingModelAutomatically)
    }

    @Test func onDiskStoreSurvivesReopening() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "Tasks.sqlite")
        let item = TodoItem(title: "Persisted", dueDate: Date(timeIntervalSince1970: 1000))

        try await CoreDataTodoStore(stack: CoreDataStack(location: .onDisk(url))).insert(item)
        let reopened = CoreDataTodoStore(stack: CoreDataStack(location: .onDisk(url)))

        #expect(try await reopened.fetchItems() == [item])
    }

    @Test func inMemoryStoresAreIsolated() throws {
        let first = makeContext()
        let second = makeContext()
        insertRecord(title: "Only in first", in: first)
        try first.save()

        #expect(try second.fetch(TaskDetails.fetchRequest()).isEmpty)
    }

    @Test func preloadInsertsItems() async throws {
        let stack = CoreDataStack(location: .inMemory)
        let items = [TodoItem(title: "One"), TodoItem(title: "Two")]

        stack.preload(items)

        #expect(try await CoreDataTodoStore(stack: stack).fetchItems().map(\.title) == ["One", "Two"])
    }

    @Test func mappingRoundTrip() {
        let item = TodoItem(title: "Round trip", isCompleted: true, dueDate: Date())
        let record = TaskDetails(context: makeContext())

        record.apply(item)

        #expect(TodoItem(record) == item)
    }
}

// MARK: - Helpers

private extension CoreDataStackTests {
    func makeContext() -> NSManagedObjectContext {
        CoreDataStack(location: .inMemory).container.viewContext
    }

    @discardableResult
    func insertRecord(title: String, isCompleted: Bool = false, in context: NSManagedObjectContext) -> TaskDetails {
        let record = TaskDetails(context: context)
        record.id = UUID()
        record.title = title
        record.isCompleted = isCompleted
        record.dueDate = Date()
        return record
    }
}
