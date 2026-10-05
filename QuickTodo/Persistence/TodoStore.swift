//
//  TodoStore.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import CoreData
import os

// MARK: - Todo Store

@MainActor
protocol TodoStore {
    func fetchItems() throws -> [TodoItem]
    func insert(_ item: TodoItem) throws
    func update(_ item: TodoItem) throws
    func delete(id: UUID) throws
}

// MARK: - Todo Store Error

enum TodoStoreError: LocalizedError, Equatable {
    case fetchFailed
    case saveFailed
    case itemNotFound

    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            "Your tasks couldn't be loaded. Please try again."
        case .saveFailed:
            "Your changes couldn't be saved. Please try again."
        case .itemNotFound:
            "This task no longer exists."
        }
    }
}

// MARK: - Core Data Todo Store

@MainActor
final class CoreDataTodoStore: TodoStore {
    private let context: NSManagedObjectContext

    nonisolated init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
    }

    func fetchItems() throws -> [TodoItem] {
        let request: NSFetchRequest<TaskDetails> = TaskDetails.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskDetails.dueDate, ascending: true),
            NSSortDescriptor(keyPath: \TaskDetails.title, ascending: true)
        ]

        let records: [TaskDetails]
        do {
            records = try context.fetch(request)
        } catch {
            Logger.persistence.error("Fetch failed: \(error.localizedDescription)")
            throw TodoStoreError.fetchFailed
        }

        try assignMissingIdentifiers(to: records)
        return records.map(TodoItem.init)
    }

    func insert(_ item: TodoItem) throws {
        let record = TaskDetails(context: context)
        record.apply(item)
        try save()
    }

    func update(_ item: TodoItem) throws {
        let record = try existingRecord(id: item.id)
        record.apply(item)
        try save()
    }

    func delete(id: UUID) throws {
        let record = try existingRecord(id: id)
        context.delete(record)
        try save()
    }
}

// MARK: - Core Data Todo Store - Helpers

private extension CoreDataTodoStore {
    func existingRecord(id: UUID) throws -> TaskDetails {
        let request: NSFetchRequest<TaskDetails> = TaskDetails.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let record = try context.fetch(request).first else {
                throw TodoStoreError.itemNotFound
            }
            return record
        } catch let error as TodoStoreError {
            throw error
        } catch {
            Logger.persistence.error("Lookup for \(id) failed: \(error.localizedDescription)")
            throw TodoStoreError.fetchFailed
        }
    }

    // The id attribute is optional in the model, so older records may not have one.
    // Without a stable id they can't be edited or deleted later.
    func assignMissingIdentifiers(to records: [TaskDetails]) throws {
        let recordsWithoutID = records.filter { $0.id == nil }
        guard !recordsWithoutID.isEmpty else { return }

        recordsWithoutID.forEach { $0.id = UUID() }
        try save()
    }

    func save() throws {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            context.rollback()
            Logger.persistence.error("Save failed: \(error.localizedDescription)")
            throw TodoStoreError.saveFailed
        }
    }
}
