//
//  FloatingAddButton.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import SwiftUI

// MARK: - Floating Add Button

struct FloatingAddButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let action: () -> Void

    private let size: CGFloat = 60
    private let waveDelays: [Duration] = [.zero, .milliseconds(500), .seconds(1)]

    var body: some View {
        Button(action: action) {
            ZStack {
                if !reduceMotion {
                    ForEach(waveDelays, id: \.self) { delay in
                        Wave(delay: delay, color: waveColor, size: size)
                    }
                }

                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: size, height: size)
                    .background(
                        LinearGradient(
                            colors: Color.primaryGradient(for: colorScheme),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: .circle
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add Task")
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

    @State private var progress: CGFloat = 0

    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .frame(width: size, height: size)
            .scaleEffect(1 + progress * 2)
            .opacity(1 - progress)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .task {
                try? await Task.sleep(for: delay)
                withAnimation(.linear(duration: 1.75).repeatForever(autoreverses: false)) {
                    progress = 1
                }
            }
    }
}

#Preview {
    FloatingAddButton {}
        .padding(60)
}
