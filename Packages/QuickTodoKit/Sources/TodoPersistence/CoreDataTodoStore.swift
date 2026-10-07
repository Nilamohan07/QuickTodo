//
//  CoreDataTodoStore.swift
//  TodoPersistence
//
//  Created by Udhayanila on 05/10/26.
//

import CoreData
import os
import TodoDomain

// MARK: - Core Data Todo Store

/// The production `TodoStore`. Every call runs on its own background context,
/// and only `TodoItem` values cross back to the caller.
public final class CoreDataTodoStore: TodoStore {
    private let container: NSPersistentContainer

    public init(stack: CoreDataStack) {
        container = stack.container
    }

    public func fetchItems() async throws -> [TodoItem] {
        try await perform { context in
            let request = TaskDetails.fetchRequest()
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

            try Self.assignMissingIdentifiers(to: records, in: context)
            return records.map(TodoItem.init)
        }
    }

    public func insert(_ item: TodoItem) async throws {
        try await perform { context in
            TaskDetails(context: context).apply(item)
            try Self.save(context)
        }
    }

    public func update(_ item: TodoItem) async throws {
        try await perform { context in
            try Self.existingRecord(id: item.id, in: context).apply(item)
            try Self.save(context)
        }
    }

    public func delete(id: UUID) async throws {
        try await perform { context in
            let record = try Self.existingRecord(id: id, in: context)
            context.delete(record)
            try Self.save(context)
        }
    }
}

// MARK: - Core Data Todo Store - Helpers

private extension CoreDataTodoStore {
    func perform<Result: Sendable>(
        _ work: @escaping @Sendable (NSManagedObjectContext) throws -> Result
    ) async throws -> Result {
        try await container.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            return try work(context)
        }
    }

    static func existingRecord(id: UUID, in context: NSManagedObjectContext) throws -> TaskDetails {
        let request = TaskDetails.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1

        let record: TaskDetails?
        do {
            record = try context.fetch(request).first
        } catch {
            Logger.persistence.error("Lookup for \(id) failed: \(error.localizedDescription)")
            throw TodoStoreError.fetchFailed
        }

        guard let record else { throw TodoStoreError.itemNotFound }
        return record
    }

    // The id attribute is optional in the model, so records from early versions may not have one.
    // Without a stable id they can't be edited or deleted later.
    static func assignMissingIdentifiers(to records: [TaskDetails], in context: NSManagedObjectContext) throws {
        let recordsWithoutID = records.filter { $0.id == nil }
        guard !recordsWithoutID.isEmpty else { return }

        recordsWithoutID.forEach { $0.id = UUID() }
        try save(context)
    }

    static func save(_ context: NSManagedObjectContext) throws {
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
