//
//  DeepLink.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation

/// The `quicktodo://` URLs the app understands.
///
/// - `quicktodo://task/new` opens the editor for a new task.
/// - `quicktodo://task/<uuid>` opens an existing task.
enum DeepLink: Hashable, Sendable {
    case newTask
    case task(UUID)

    static let scheme = "quicktodo"

    init?(url: URL) {
        guard
            url.scheme?.lowercased() == Self.scheme,
            url.host()?.lowercased() == "task"
        else {
            return nil
        }

        let path = url.pathComponents.filter { $0 != "/" }
        guard path.count == 1, let component = path.first else { return nil }

        if component.lowercased() == "new" {
            self = .newTask
        } else if let id = UUID(uuidString: component) {
            self = .task(id)
        } else {
            return nil
        }
    }

    var url: URL {
        let component = switch self {
        case .newTask: "new"
        case .task(let id): id.uuidString
        }
        // Built from constants, so this can't fail.
        return URL(string: "\(Self.scheme)://task/\(component)")!
    }
}
