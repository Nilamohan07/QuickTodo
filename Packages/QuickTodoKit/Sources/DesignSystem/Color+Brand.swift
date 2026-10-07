//
//  Color+Brand.swift
//  DesignSystem
//
//  Created by Udhayanila on 04/02/25.
//

import SwiftUI

public extension Color {

    // MARK: - Status

    /// Tint for overdue tasks.
    static let overdue = Color.red

    /// Tint for completed tasks.
    static let completed = Color.green

    // MARK: - Brand

    /// The gradient behind primary actions, tuned per color scheme.
    static func brandGradient(for colorScheme: ColorScheme) -> [Color] {
        colorScheme == .dark
            ? [.purple.opacity(0.85), .black.opacity(0.85)]
            : [.blue, .purple]
    }
}
