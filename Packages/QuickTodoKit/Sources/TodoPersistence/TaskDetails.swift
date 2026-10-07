//
//  TaskDetails.swift
//  TodoPersistence
//
//  Created by Udhayanila on 05/10/26.
//

import CoreData

// The Objective-C name has to match `representedClassName` in the model, which predates this module.
@objc(TaskDetails)
final class TaskDetails: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var title: String?
    @NSManaged var isCompleted: Bool
    @NSManaged var dueDate: Date?
}

extension TaskDetails {
    static let entityName = "TaskDetails"

    @nonobjc class func fetchRequest() -> NSFetchRequest<TaskDetails> {
        NSFetchRequest<TaskDetails>(entityName: entityName)
    }
}
