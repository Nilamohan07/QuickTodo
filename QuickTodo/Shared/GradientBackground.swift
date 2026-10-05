//
//  GradientBackground.swift
//  QuickTodo
//
//  Created by Udhayanila on 05/10/26.
//

import SwiftUI

struct GradientBackground: View {
    var body: some View {
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
