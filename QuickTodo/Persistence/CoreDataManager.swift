//
//  CoreDataManager.swift
//  QuickTodo
//
//  Created by Udhayanila on 30/01/25.
//

import CoreData
import os

final class CoreDataManager {
    static let shared = CoreDataManager()

    static let modelName = "TaskDetailsDataModel"

    // Loaded once so multiple containers (tests, previews) don't register duplicate entity descriptions.
    private static let model: NSManagedObjectModel = {
        guard
            let url = Bundle(for: CoreDataManager.self).url(forResource: modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url)
        else {
            preconditionFailure("Missing Core Data model \(modelName).momd in the app bundle")
        }
        return model
    }()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: Self.modelName, managedObjectModel: Self.model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // A failed load leaves the context without a store, so fetches fail and the UI reports it.
        container.loadPersistentStores { description, error in
            if let error {
                Logger.persistence.error("Failed to load store at \(description.url?.path() ?? "-"): \(error.localizedDescription)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
