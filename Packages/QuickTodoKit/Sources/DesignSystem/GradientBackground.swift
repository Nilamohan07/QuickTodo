//
//  GradientBackground.swift
//  DesignSystem
//
//  Created by Udhayanila on 05/10/26.
//

import SwiftUI

/// The soft full-screen gradient behind every screen.
public struct GradientBackground: View {
    public init() {}

    public var body: some View {
        LinearGradient(
            colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackground()
}
