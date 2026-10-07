//
//  PrimaryButtonStyle.swift
//  DesignSystem
//
//  Created by Udhayanila on 04/02/25.
//

import SwiftUI

// MARK: - Primary Button Style

/// The filled gradient button used for the main action on a screen.
public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.xxLarge)
            .padding(.vertical, Spacing.small)
            .background(
                LinearGradient(
                    colors: Color.brandGradient(for: colorScheme),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: CornerRadius.control)
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.2), radius: 5, y: 3)
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

// MARK: - Primary Button Style - Preview

#Preview {
    Button("Add Task") {}
        .buttonStyle(.primary)
}
