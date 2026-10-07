//
//  FloatingAddButton.swift
//  DesignSystem
//
//  Created by Udhayanila on 05/10/26.
//

import SwiftUI

// MARK: - Floating Add Button

/// A round add button with a pulsing halo. The halo is dropped when Reduce Motion is on.
public struct FloatingAddButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let accessibilityLabel: Text
    private let action: () -> Void

    private let size: CGFloat = 60
    private let waveDelays: [Duration] = [.zero, .milliseconds(500), .seconds(1)]

    public init(accessibilityLabel: Text, action: @escaping () -> Void) {
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(
                    LinearGradient(
                        colors: Color.brandGradient(for: colorScheme),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: .circle
                )
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        // The halo sits outside the button so its scaling never changes the tap area.
        .background {
            if !reduceMotion {
                ZStack {
                    ForEach(waveDelays, id: \.self) { delay in
                        Wave(delay: delay, color: waveColor, size: size)
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var waveColor: Color {
        colorScheme == .dark ? .white : .purple
    }
}

// MARK: - Wave

private struct Wave: View {
    let delay: Duration
    let color: Color
    let size: CGFloat

    @State private var isExpanded = false

    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .frame(width: size, height: size)
            .scaleEffect(isExpanded ? 3 : 1)
            .opacity(isExpanded ? 0 : 1)
            // Scoped to this view on purpose. A repeating `withAnimation` would also catch any other
            // state change in the same transaction, like the task list loading, and loop it forever.
            .animation(
                .linear(duration: 1.75).repeatForever(autoreverses: false).delay(delay.timeInterval),
                value: isExpanded
            )
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onAppear { isExpanded = true }
    }
}

private extension Duration {
    var timeInterval: TimeInterval {
        let (seconds, attoseconds) = components
        return TimeInterval(seconds) + TimeInterval(attoseconds) / 1e18
    }
}

// MARK: - Floating Add Button - Preview

#Preview {
    FloatingAddButton(accessibilityLabel: Text(verbatim: "Add Task")) {}
        .padding(60)
}
