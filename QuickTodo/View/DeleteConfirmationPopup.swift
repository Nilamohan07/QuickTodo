//
//  DeleteConfirmationPopup.swift
//  QuickTodo
//
//  Created by Udhayanila on 09/02/25.
//

import SwiftUI

struct DeleteConfirmationPopup: View {
    @Binding var isPresented: Bool
    @Binding var taskToDelete: Task?
    var onDelete: () -> Void

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Popup card
            VStack(spacing: 20) {
                Text("Are you sure you want to delete the task \"\(taskToDelete?.title ?? "-")\"?")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .padding(.horizontal)

                HStack(spacing: 20) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Cancel")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }

                    Button {
                        onDelete()
                        isPresented = false
                    } label: {
                        Text("Delete")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}

#Preview {
    DeleteConfirmationPopup(isPresented: .constant(false), taskToDelete: .constant(nil), onDelete: {})
}
