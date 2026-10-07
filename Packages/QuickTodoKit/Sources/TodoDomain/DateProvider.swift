//
//  DateProvider.swift
//  TodoDomain
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation

/// Supplies "now", so overdue checks, default due dates and reminders can be pinned in tests and UI tests.
public struct DateProvider: Sendable {
    private let makeDate: @Sendable () -> Date

    public init(_ makeDate: @escaping @Sendable () -> Date) {
        self.makeDate = makeDate
    }

    public var now: Date {
        makeDate()
    }

    public static let system = DateProvider { Date() }

    public static func fixed(_ date: Date) -> DateProvider {
        DateProvider { date }
    }
}
