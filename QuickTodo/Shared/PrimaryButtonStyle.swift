//
//  PrimaryButtonStyle.swift
//  QuickTodo
//
//  Created by Udhayanila on 04/02/25.
//

import SwiftUI

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: Color.primaryGradient(for: colorScheme),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 12)
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.2), radius: 5, y: 3)
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

// MARK: - Brand Gradient

extension Color {
    static func primaryGradient(for colorScheme: ColorScheme) -> [Color] {
        colorScheme == .dark
            ? [.purple.opacity(0.85), .black.opacity(0.85)]
            : [.blue, .purple]
    }
}

#Preview {
    Button("Add Task") {}
        .buttonStyle(.primary)
}
