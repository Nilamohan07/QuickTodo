//
//  CoreDataStack.swift
//  TodoPersistence
//
//  Created by Udhayanila on 30/01/25.
//

import CoreData
import os
import TodoDomain

/// Owns the persistent container for the `TaskDetailsDataModel` store.
public final class CoreDataStack: Sendable {
    /// Where the SQLite store lives.
    public enum StoreLocation: Sendable {
        case onDisk(URL)
        case inMemory
    }

    public static let modelName = "TaskDetailsDataModel"

    /// The location `NSPersistentContainer` picked before the model moved into this package.
    /// Keeping it means existing installs open the same file.
    public static var defaultStoreURL: URL {
        NSPersistentContainer.defaultDirectoryURL().appending(path: "\(modelName).sqlite")
    }

    // Loaded once so several containers (tests, previews) don't register duplicate entity descriptions.
    // The model is never mutated after loading, which is what makes sharing it safe.
    nonisolated(unsafe) static let model: NSManagedObjectModel = {
        guard
            let url = Bundle.module.url(forResource: modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url)
        else {
            preconditionFailure("Missing Core Data model \(modelName).momd in the TodoPersistence bundle")
        }
        return model
    }()

    public let container: NSPersistentContainer

    public init(location: StoreLocation = .onDisk(CoreDataStack.defaultStoreURL)) {
        container = NSPersistentContainer(name: Self.modelName, managedObjectModel: Self.model)

        let description = NSPersistentStoreDescription(url: location.url)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        // A failed load leaves the coordinator without a store, so fetches fail and the UI reports it.
        container.loadPersistentStores { description, error in
            if let error {
                Logger.persistence.error(
                    "Failed to load store at \(description.url?.path() ?? "-"): \(error.localizedDescription)"
                )
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    /// Inserts items synchronously. Used to seed in-memory stores for previews and UI tests.
    public func preload(_ items: [TodoItem]) {
        let context = container.viewContext
        context.performAndWait {
            for item in items {
                TaskDetails(context: context).apply(item)
            }
            do {
                try context.save()
            } catch {
                Logger.persistence.error("Preloading failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Store Location

private extension CoreDataStack.StoreLocation {
    var url: URL {
        switch self {
        case .onDisk(let url): url
        case .inMemory: URL(filePath: "/dev/null")
        }
    }
}
