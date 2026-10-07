//
//  TaskFilter+Title.swift
//  TaskListFeature
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import TodoDomain

extension TaskFilter {
    var title: String {
        switch self {
        case .all: String(localized: "All", bundle: .module)
        case .active: String(localized: "Active", bundle: .module)
        case .completed: String(localized: "Completed", bundle: .module)
        }
    }
}
