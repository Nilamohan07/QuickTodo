//
//  PrimaryButtonStyle.swift
//  QuickTodo
//
//  Created by Udhayanila on 04/02/25.
//

import SwiftUI

// MARK: - Primary Button Style Modifier

struct PrimaryButtonStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        let gradientColors = colorScheme == .dark
            ? [Color.purple.opacity(0.8), Color.black.opacity(0.9)] // Dark mode colors
            : [Color.blue, Color.purple] // Light mode colors

        content
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(12)
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.4) // Adjust shadow for dark mode
                    : Color.black.opacity(0.2),
                radius: 5,
                x: 0,
                y: 3
            )
    }
}
