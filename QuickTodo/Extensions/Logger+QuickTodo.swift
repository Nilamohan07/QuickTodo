//
//  Logger+QuickTodo.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation
import os

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "QuickTodo"

    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    static let tasks = Logger(subsystem: subsystem, category: "Tasks")
}
