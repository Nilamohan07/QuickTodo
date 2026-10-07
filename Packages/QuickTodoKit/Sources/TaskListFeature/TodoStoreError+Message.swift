//
//  TodoStoreError+Message.swift
//  TaskListFeature
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import TodoDomain

extension TodoStoreError {
    var message: String {
        switch self {
        case .fetchFailed:
            String(localized: "Your tasks couldn't be loaded. Please try again.", bundle: .module)
        case .saveFailed:
            String(localized: "Your changes couldn't be saved. Please try again.", bundle: .module)
        case .itemNotFound:
            String(localized: "This task no longer exists.", bundle: .module)
        }
    }
}
